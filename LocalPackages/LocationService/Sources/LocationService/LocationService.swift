// The Swift Programming Language
// https://docs.swift.org/swift-book

import CoreLocation
import Dependencies

public struct LocationService: Sendable {
  public let authorizationStatus: @MainActor @Sendable () -> CLAuthorizationStatus
  public let authorizationStatusStream: @Sendable () -> AsyncStream<CLAuthorizationStatus>
  public let coordinateStream: @Sendable () -> AsyncStream<CLLocationCoordinate2D>
  public let requestLocation: @Sendable () async -> Result<CLLocation, LocationServiceError>
}

extension LocationService: DependencyKey {
  public static var liveValue: Self {
    let manager = LocationManager()
    
    return Self(
      authorizationStatus: { manager.authorizationStatus },
      authorizationStatusStream: { manager.authorizationStatusStream() },
      coordinateStream: { manager.coordinateStream() },
      requestLocation: { await manager.requestLocation() }
    )
  }
  
  public static var previewValue: Self {
    allowedLocation(.moscow)
  }
  
  public static var testValue: Self {
    allowedLocation(.moscow)
  }
  
  public static var denied: Self {
    .init(
      authorizationStatus: { .denied },
      authorizationStatusStream: {
        AsyncStream(bufferingPolicy: .bufferingNewest(1)) { continuation in
          continuation.yield(.denied)
        }
      },
      coordinateStream: {
        AsyncStream(bufferingPolicy: .bufferingNewest(1)) { _ in }
      },
      requestLocation: {
        await Task { .failure(.unauthorized(status: .denied)) }
          .value
      }
    )
  }
  
  private static func allowedLocation(_ location: CLLocation) -> Self {
    .init(
      authorizationStatus: { .authorizedWhenInUse },
      authorizationStatusStream: {
        AsyncStream(bufferingPolicy: .bufferingNewest(1)) { continuation in
          continuation.yield(.authorizedWhenInUse)
        }
      },
      coordinateStream: {
        AsyncStream(bufferingPolicy: .bufferingNewest(1)) { continuation in
          continuation.yield(location.coordinate)
        }
      },
      requestLocation: {
        await Task { .success(location) }
          .value
      }
    )
  }
}

extension DependencyValues {
  public var locationService: LocationService {
    get { self[LocationService.self] }
    set { self[LocationService.self] = newValue }
  }
}


/// Constants
private extension CLLocationCoordinate2D {
  static let moscow = CLLocationCoordinate2D(latitude: 55.755864, longitude: 37.617698)
}

private extension CLLocation {
  static let moscow = CLLocation(coordinate: .moscow)
  
  private convenience init(coordinate: CLLocationCoordinate2D) {
    self.init(
      latitude: coordinate.latitude,
      longitude: coordinate.longitude
    )
  }
}
