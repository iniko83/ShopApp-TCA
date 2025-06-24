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
  @Dependency(\.mainQueue) var mainQueue
  
  @Dependency(\.citySelectionApi) var api: CitySelectionApi
  @Dependency(\.locationService) var locationService: LocationService
  @Dependency(\.networkConnectionService) var networkConnectionService
  
  public init() {}
  
  @ObservableState
  public struct State: Equatable {
    public var selectedCityId: Int?
    
    var isSearchFocused = false
    fileprivate var searchQuery: String = .empty
    
    fileprivate(set) var searchEngineRequestState = RequestState()
    
    private(set) var userCoordinate: Coordinate?
    fileprivate(set) var userCoordinateRequestState = RequestLocationState()
    
    // dependent
    private(set) var nearestCity: City?
    
    // ignored
    public var tableSections = [CityTableSection]()
    fileprivate(set) var cityIds = Set<Int>()
    fileprivate var searchEngine = CitySearchEngine()
    private(set) var isInitialized = false
    fileprivate(set) var isWantUserCoordinate = false
    
    var cities: [City] { searchEngine.cities }
    
    public init() {}
   
    fileprivate func isNeedRequestSearchEngine() -> Bool {
      searchEngine.isEmpty() && searchEngineRequestState != .loading
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
      && lhs.isSearchFocused == rhs.isSearchFocused
      && lhs.searchQuery == rhs.searchQuery
      && lhs.searchEngineRequestState == rhs.searchEngineRequestState
      && lhs.userCoordinate == rhs.userCoordinate
      && lhs.userCoordinateRequestState == rhs.userCoordinateRequestState
    }
  }
  
  public enum Action: BindableAction {
    case binding(BindingAction<State>)
    
    case changeLocationServiceAuthorizationStatus(CLAuthorizationStatus)
    
    case networkAvailable
    
    case onAppear
    
    case receiveSearchValidation(CitySearchValidationResult)
    
    case responseSearch(CitySearchResponse)
    case responseSearchEngine(RequestResult<CitySearchEngine>)
    case responseUserCoordinate(Result<Coordinate, LocationServiceError>)
    
    case tapDefineUserLocation
    case tapRequestSearchEngine

    init(action: CityListView.Action) {
      switch action {
      case .tapDefineUserLocation:
        self = .tapDefineUserLocation
      }
    }
  }
  
  enum CancelId {
    case debounceSearch
  }
  
  public var body: some ReducerOf<Self> {
    BindingReducer()
    Reduce { state, action in
      var result: Effect<Action> = .none
      switch action {
      case let .binding(action):
        switch action {
        case \.selectedCityId:
          if let cityId = state.selectedCityId {
            // FIXME: debug log
            print("select city with id: \(cityId)")
          }
          break
          
        default:
          break
        }
        
      case let .changeLocationServiceAuthorizationStatus(status):
        if status.isAuthorized && state.isNeedRequestUserCoordinate() {
          result = requestUserCoordinateEffect(state: &state)
        } else {
          state.isWantUserCoordinate = false
        }
        
      case .networkAvailable:
        if state.searchEngineRequestState.isRetryableError() {
          result = requestSearchEngineEffect(state: &state)
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
        if state.isNeedRequestSearchEngine() {
          effects.append(requestSearchEngineEffect(state: &state))
        }
        if state.isNeedRequestUserCoordinate() {
          effects.append(requestUserCoordinateEffect(state: &state))
        }
        if !effects.isEmpty {
          result = .merge(effects)
        }
        
      case let .receiveSearchValidation(validation):
        if let invalidSymbols = validation.invalidSymbols {
          // FIXME: add temporary toast under search bar
        }
        
        let query = validation.query()
        if state.searchQuery != query {
          state.searchQuery = query
          result = fetchSearchResultEffect(state: &state)
        }
        
      case let .responseSearch(response):
        if state.searchQuery == response.query {
          state.cityIds = response.result.ids
          state.tableSections = response.result.sections
        }
        
      case let .responseSearchEngine(response):
        switch response {
        case let .success(value):
          state.searchEngineRequestState = .default
          state.searchEngine = value
          
          result = fetchSearchResultEffect(state: &state)
          
        case let .failure(error):
          state.searchEngineRequestState = .error(error)
        }
        
      case let .responseUserCoordinate(response):
        state.receiveUserCoordinateResponse(response)
        
      case .tapDefineUserLocation:
        state.isWantUserCoordinate = true
        
        let isLocationServiceDenied = locationService.authorizationStatus().isDenied
        if isLocationServiceDenied {
          // FIXME: add showing alert "open application settings"
        } else if state.isNeedRequestUserCoordinate() {
          result = requestUserCoordinateEffect(state: &state)
        }
        
      case .tapRequestSearchEngine:
        if state.isNeedRequestSearchEngine() {
          result = requestSearchEngineEffect(state: &state)
        }
      }
      return result
    }
  }
  
  private func fetchSearchResultEffect(state: inout State) -> Effect<Action> {
    let query = state.searchQuery
    
    let result: Effect<Action>
    if query.isEmpty {
      let response = state.searchEngine.defaultResponse
      
      result = .merge(
        .cancel(id: CancelId.debounceSearch),
        .send(.responseSearch(response))
      )
    } else {
      result = .run { [engine = state.searchEngine] send in
        let response = await engine
          .search(unemptyQuery: query)
          .makeResponse(query: query)
        await send(.responseSearch(response))
      }
      .debounce(
        id: CancelId.debounceSearch,
        for: .seconds(.searchDelay),
        scheduler: mainQueue
      )
    }
    return result
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
  
  private func requestSearchEngineEffect(state: inout State) -> Effect<Action> {
    state.searchEngineRequestState = .loading
    
    return .run { [loadCities = api.loadCities] send in
      let responseCities = await loadCities()
      let response: RequestResult<CitySearchEngine>
      switch responseCities {
      case let .success(cities):
        let searchEngine = CitySearchEngine(cities: cities)
        response = .success(searchEngine)
        
      case let .failure(error):
        response = .failure(error)
      }
      await send(.responseSearchEngine(response))
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
