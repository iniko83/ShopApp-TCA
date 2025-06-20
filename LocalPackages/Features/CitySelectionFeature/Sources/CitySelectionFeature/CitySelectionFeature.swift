// The Swift Programming Language
// https://docs.swift.org/swift-book

import ComposableArchitecture
import CoreLocation
import Dependencies
import SwiftUI

import LocationService
import NetworkClient
import NetworkConnectionService
import Utility

@Reducer
public struct CitySelectionFeature {
  @Dependency(\.citySelectionApi) var api: CitySelectionApi
  @Dependency(\.locationService) var locationService: LocationService
  @Dependency(\.networkConnectionService) var networkConnectionService
  
  public init() {}
  
  @ObservableState
  public struct State: Equatable {
    public var selectedCityId: Int?
    
    fileprivate(set) var citiesRequestState = RequestState()
    
    private(set) var userCoordinate: Coordinate?
    fileprivate(set) var userCoordinateRequestState = RequestLocationState()
    
    // dependent
    private(set) var nearestCity: City?
    
    // ignored
    fileprivate(set) var cities = [City]()
    private(set) var isInitialized = false
    fileprivate(set) var isWantUserCoordinate = false
    
    public init() {}
   
    fileprivate func isNeedRequestCities() -> Bool {
      cities.isEmpty && citiesRequestState != .loading
    }
    
    fileprivate func isNeedRequestUserCoordinate() -> Bool {
      isWantUserCoordinate && userCoordinateRequestState != .processing
    }
    
    mutating fileprivate func initialize(isLocationServiceAuthorized: Bool) {
      isWantUserCoordinate = isLocationServiceAuthorized
      isInitialized = true
    }
    
    mutating fileprivate func receiveUserCoordinateResponse(
      _ response: Result<Coordinate, LocationServiceError>
    ) {
      switch response {
      case let .success(coordinate):
        userCoordinateRequestState = .default
        userCoordinate = coordinate
       
      case let .failure(error):
        userCoordinateRequestState = .error(error)
      }
    }
    
    /// Equatable
    public static func == (lhs: State, rhs: State) -> Bool {
      lhs.selectedCityId == rhs.selectedCityId
      && lhs.citiesRequestState == rhs.citiesRequestState
      && lhs.userCoordinate == rhs.userCoordinate
      && lhs.userCoordinateRequestState == rhs.userCoordinateRequestState
    }
  }
  
  public enum Action {
    case changeLocationServiceAuthorizationStatus(CLAuthorizationStatus)
    
    case networkAvailable
    
    case onAppear
    
    case responseCities(RequestResult<[City]>)
    case responseUserCoordinate(Result<Coordinate, LocationServiceError>)
    
    case selectCity(id: Int)
    
    case tapDefineUserLocation
    case tapRequestCities

    init(action: CityListView.Action) {
      switch action {
      case let .selectCity(id):
        self = .selectCity(id: id)
      case .tapDefineUserLocation:
        self = .tapDefineUserLocation
      }
    }
  }
  
  public var body: some ReducerOf<Self> {
    Reduce { state, action in
      var result: Effect<Action> = .none
      switch action {
      case let .changeLocationServiceAuthorizationStatus(status):
        if status.isAuthorized && state.isNeedRequestUserCoordinate() {
          result = requestUserCoordinateEffect(state: &state)
        } else {
          state.isWantUserCoordinate = false
        }
        
      case .networkAvailable:
        if state.citiesRequestState.isRetryableError() {
          result = requestCitiesEffect(state: &state)
        }
        
      case .onAppear:
        let isStateUninitialized = !state.isInitialized
        if isStateUninitialized {
          let status = locationService.authorizationStatus()
          state.initialize(isLocationServiceAuthorized: status.isAuthorized)
        }
        
        var effects = [Effect<Action>]()
        if isStateUninitialized {
          effects += [
            locationServiceAuthorizationStatusStreamEffect(),
            networkAvailabilityStreamEffect()
          ]
        }
        if state.isNeedRequestCities() {
          effects.append(requestCitiesEffect(state: &state))
        }
        if state.isNeedRequestUserCoordinate() {
          effects.append(requestUserCoordinateEffect(state: &state))
        }
        if !effects.isEmpty {
          result = .merge(effects)
        }
        
      case let .responseCities(response):
        switch response {
        case let .success(cities):
          state.citiesRequestState = .default
          state.cities = cities
          
        case let .failure(error):
          state.citiesRequestState = .error(error)
        }
        
      case let .responseUserCoordinate(response):
        state.receiveUserCoordinateResponse(response)
        
      case let .selectCity(id):
        state.selectedCityId = id
        
        // FIXME: debug log
        print("select city: \(id)")
        
      case .tapDefineUserLocation:
        state.isWantUserCoordinate = true
        
        let isLocationServiceDenied = locationService.authorizationStatus().isDenied
        if isLocationServiceDenied {
          // FIXME: add showing alert "open application settings"
        } else if state.isNeedRequestUserCoordinate() {
          result = requestUserCoordinateEffect(state: &state)
        }
        
      case .tapRequestCities:
        if state.isNeedRequestCities() {
          result = requestCitiesEffect(state: &state)
        }
      }
      return result
    }
  }
  
  private func locationServiceAuthorizationStatusStreamEffect() -> Effect<Action> {
    let authorizationStatusStream = locationService.authorizationStatusStream
    return .run { send in
      for await status in authorizationStatusStream() {
        await send(.changeLocationServiceAuthorizationStatus(status))
      }
    }
  }
  
  private func networkAvailabilityStreamEffect() -> Effect<Action> {
    let connectionStream = networkConnectionService.connectionStream
    return .run { send in
      for await isConnected in connectionStream(.cellularOrWifi) {
        if isConnected {
          await send(.networkAvailable)
        }
      }
    }
  }
  
  private func requestCitiesEffect(state: inout State) -> Effect<Action> {
    state.citiesRequestState = .loading
    
    return .run { [loadCities = api.loadCities] send in
      let response = await loadCities()
      await send(.responseCities(response))
    }
  }
  
  private func requestUserCoordinateEffect(state: inout State) -> Effect<Action> {
    state.isWantUserCoordinate = false
    state.userCoordinateRequestState = .processing
    
    return .run { [requestLocation = locationService.requestLocation] send in
      let locationResult = await requestLocation()
      
      let response: Result<Coordinate, LocationServiceError>
      switch locationResult {
      case let .success(location):
        let coordinate = Coordinate(coordinate: location.coordinate)
        response = .success(coordinate)
        
      case let .failure(error):
        response = .failure(error)
      }
      
      await send(.responseUserCoordinate(response))
    }
  }
}
