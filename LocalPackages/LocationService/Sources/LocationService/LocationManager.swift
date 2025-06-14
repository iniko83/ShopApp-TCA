//
//  LocationManager.swift
//  LocationService
//
//  Created by Igor Nikolaev on 14.06.2025.
//

import CoreLocation
import os.lock

/* Предназначен для использования в главном потоке, поэтому код несколько упрощен. */

/*
 Possible async/await problems explanation here:
 https://forums.swift.org/t/bridging-the-delegate-pattern-to-asyncstream-with-swift6-and-sendability-issues/75754/6
 */

fileprivate typealias RequestLocationContinuation = UnsafeContinuation<RequestLocationResult, Never>
fileprivate typealias RequestLocationResult = Result<CLLocation, LocationServiceError>

final class LocationManager: NSObject, @unchecked Sendable {
  private(set) var authorizationStatus: CLAuthorizationStatus = .notDetermined
  private(set) var coordinate: CLLocationCoordinate2D?
  
  private let locationManager = CLLocationManager()
  
  private let authStatusLockedData = OSAllocatedUnfairLock(initialState: ProtectedData.AuthorizationStatus())
  private let coordinateLockedData = OSAllocatedUnfairLock(initialState: ProtectedData.Coordinate())
  private let requestLocationLockedData = OSAllocatedUnfairLock(initialState: ProtectedData.RequestLocation())
  
  private var coordinateStreamsCounter: Int = 0 {
    didSet {
      isMonitoringLocationChanges = coordinateStreamsCounter > 0
    }
  }
  
  private var coordinateStreamsCounterUpdateTimer: Timer?
  
  private var isMonitoringLocationChanges = false {
    didSet {
      guard isMonitoringLocationChanges != oldValue else { return }
      updateMonitoringLocationChangesState(isMonitoringLocationChanges)
    }
  }
  
  override init() {
    super.init()
    
    authorizationStatus = locationManager.authorizationStatus
    
    // configure locationManager
    locationManager.activityType = .other
    locationManager.allowsBackgroundLocationUpdates = false
    locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
    locationManager.distanceFilter = 50
    locationManager.delegate = self
  }
  
  deinit {
    isMonitoringLocationChanges = false
  }
  
  func authorizationStatusStream() -> AsyncStream<CLAuthorizationStatus> {
    AsyncStream(bufferingPolicy: .bufferingNewest(1)) { continuation in
      let id = UUID()
      
      continuation.onTermination = { [mutex = authStatusLockedData] _ in
        mutex.withLock {
          $0.continuationsByIds[id] = nil
        }
      }
      
      authStatusLockedData.withLock {
        $0.continuationsByIds[id] = continuation
      }
      
      continuation.yield(locationManager.authorizationStatus)
    }
  }
  
  func coordinateStream() -> AsyncStream<CLLocationCoordinate2D> {
    requestPermissionsIfNeeded()
    
    return AsyncStream(bufferingPolicy: .bufferingNewest(1)) { [mutex = coordinateLockedData] continuation in
      let id = UUID()
      
      continuation.onTermination = { _ in
        mutex.withLock {
          $0.continuationsByIds[id] = nil
        }
      }
      
      coordinateStreamsCounter = mutex.withLock {
        $0.continuationsByIds[id] = continuation
        return $0.continuationsByIds.count
      }
      
      guard let coordinate else { return }
      continuation.yield(coordinate)
    }
  }
  
  func requestLocation() async -> Result<CLLocation, LocationServiceError> {
    await withUnsafeContinuation { continuation in
      let (isNeedRequestLocation, isNeedRequestPermissions) = requestLocationLockedData.withLock {
        $0.continuations.append(continuation)
        
        let isNeedRequestLocation = !$0.isLocationRequested
        
        let isNeedRequestPermissions: Bool
        if isNeedRequestLocation {
          isNeedRequestPermissions = self.isNeedRequestPermissions()
          $0.isRequestLocationOnAuthorization = isNeedRequestPermissions
          $0.isLocationRequested = !isNeedRequestPermissions
        } else {
          isNeedRequestPermissions = false
        }
        return (isNeedRequestLocation, isNeedRequestPermissions)
      }
      
      if isNeedRequestPermissions {
        locationManager.requestWhenInUseAuthorization()
      } else if isNeedRequestLocation {
        locationManager.requestLocation()
      }
    }
  }
  
  private func isNeedRequestPermissions() -> Bool {
    locationManager.authorizationStatus == .notDetermined
  }
  
  private func receiveAuthorizationStatusChange(_ status: CLAuthorizationStatus) {
    authorizationStatus = status
    
    authStatusLockedData
      .withLock { $0.continuationsByIds.values }
      .forEach { $0.yield(status) }
    
    let isNeedRequestLocation = requestLocationLockedData.withLock {
      let result = $0.isRequestLocationOnAuthorization && !$0.isLocationRequested
      $0.isRequestLocationOnAuthorization = false
      if result {
        $0.isLocationRequested = true
      }
      return result
    }
    
    guard isNeedRequestLocation else { return }
    
    locationManager.requestLocation()
  }
  
  private func receiveCoordinate(_ coordinate: CLLocationCoordinate2D) {
    self.coordinate = coordinate
    
    coordinateLockedData
      .withLock { $0.continuationsByIds.values }
      .forEach { $0.yield(coordinate) }
  }
  
  private func receiveLocationResult(_ value: RequestLocationResult) {
    requestLocationLockedData.withLock {
      $0.continuations.forEach { $0.resume(returning: value) }
      $0.continuations.removeAll()
      $0.isLocationRequested = false
    }
  }
  
  @discardableResult
  private func requestPermissionsIfNeeded() -> Bool {
    let result = isNeedRequestPermissions()
    if result {
      locationManager.requestWhenInUseAuthorization()
    }
    return result
  }
  
  @objc private func coordinateStreamsCounterTimerTick() {
    coordinateStreamsCounter = coordinateLockedData.withLock {
      $0.continuationsByIds.count
    }
  }
  
  private func updateCoordinateStreamsCounterUpdateTimerState(isEnabled: Bool) {
    if let timer = coordinateStreamsCounterUpdateTimer {
      timer.invalidate()
      coordinateStreamsCounterUpdateTimer = nil
    }
    
    guard isEnabled else { return }
    
    let timer = Timer(
      timeInterval: 1,
      target: self,
      selector: #selector(coordinateStreamsCounterTimerTick),
      userInfo: nil,
      repeats: true
    )
    coordinateStreamsCounterUpdateTimer = timer
    
    RunLoop.current.add(timer, forMode: .common)
  }
  
  private func updateMonitoringLocationChangesState(_ isMonitoring: Bool) {
    if Platform.isSimulator {
      if isMonitoring {
        locationManager.startUpdatingLocation()
      } else {
        locationManager.stopUpdatingLocation()
      }
    } else {
      if isMonitoring {
        locationManager.startMonitoringSignificantLocationChanges()
      } else {
        locationManager.stopMonitoringSignificantLocationChanges()
      }
    }
    
    updateCoordinateStreamsCounterUpdateTimerState(isEnabled: isMonitoring)
  }
}

extension LocationManager: CLLocationManagerDelegate {
  func locationManager(
    _ manager: CLLocationManager,
    didUpdateLocations locations: [CLLocation]
  ) {
    guard let location = locations.last else { return }
    receiveCoordinate(location.coordinate)
    receiveLocationResult(.success(location))
  }
  
  func locationManager(
    _ manager: CLLocationManager,
    didFailWithError error: Error
  ) {
    let status = locationManager.authorizationStatus
    
    let failureError: LocationServiceError
    switch status {
    case .denied, .restricted:
      failureError = .unauthorized(status: status)
    default:
      failureError = .unknown(error: error)
    }
    
    receiveLocationResult(.failure(failureError))
  }
  
  func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
    receiveAuthorizationStatusChange(manager.authorizationStatus)
  }
}

private struct ProtectedData {
  fileprivate struct AuthorizationStatus {
    var continuationsByIds = [UUID: AsyncStream<CLAuthorizationStatus>.Continuation]()
  }
  
  fileprivate struct Coordinate {
    var continuationsByIds = [UUID: AsyncStream<CLLocationCoordinate2D>.Continuation]()
  }
  
  fileprivate struct RequestLocation {
    var continuations = [RequestLocationContinuation]()
    var isLocationRequested = false
    var isRequestLocationOnAuthorization = false
  }
}
