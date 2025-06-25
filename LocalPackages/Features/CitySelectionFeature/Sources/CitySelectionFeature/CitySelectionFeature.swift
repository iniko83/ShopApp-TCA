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

// FIXME: add city selection history

@Reducer
public struct CitySelectionFeature {
  @Dependency(\.mainQueue) var mainQueue
  
  @Dependency(\.citySelectionApi) var api: CitySelectionApi
  @Dependency(\.locationService) var locationService: LocationService
  @Dependency(\.networkConnectionService) var networkConnectionService
  @Dependency(\.openApplicationSettings) var openApplicationSettings
  
  public init() {}
  
  @ObservableState
  public struct State: Equatable {
    @Presents var alert: AlertState<Action.Alert>?
    
    public var selectedCityId: Int?
    
    var isSearchFocused = false
    fileprivate var searchQuery: String = .empty
    fileprivate(set) var queryInvalidSymbols: String = .empty
    
    fileprivate(set) var searchEngineRequestState = RequestState()
    
    private(set) var userCoordinate: Coordinate?
    private(set) var userCoordinateRequestState = RequestLocationState()
    
    private(set) var nearestCity: City?
    
    // dependent
    fileprivate(set) var nearestCityRequestState = RequestLocationState() // by userCoordinateRequestState & nearestCity
    
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
        setUserCoordinateRequestState(.default)
        userCoordinate = coordinate
       
      case let .failure(error):
        setUserCoordinateRequestState(.error(error))
      }
    }
    
    mutating fileprivate func setUserCoordinateRequestState(_ value: RequestLocationState) {
      userCoordinateRequestState = value
      updateNearestCityRequestState()
    }
    
    mutating fileprivate func setNearestCity(_ value: City?) {
      // FIXME: debug log
      if let value {
        print("receive nearest city: id: \(value.id), name: \(value.name)")
      }
      
      nearestCity = value
      updateNearestCityRequestState()
    }
    
    mutating private func updateNearestCityRequestState() {
      let value: RequestLocationState
      switch userCoordinateRequestState {
      case .default:
        value = nearestCity == nil ? .processing : .default
      case .processing:
        value = .processing
      case let .error(error):
        value = .error(error)
      }
      nearestCityRequestState = value
    }
    
    /// Equatable
    public static func == (lhs: State, rhs: State) -> Bool {
      lhs.selectedCityId == rhs.selectedCityId
      && lhs.isSearchFocused == rhs.isSearchFocused
      && lhs.searchQuery == rhs.searchQuery
      && lhs.searchEngineRequestState == rhs.searchEngineRequestState
      && lhs.userCoordinate == rhs.userCoordinate
      && lhs.userCoordinateRequestState == rhs.userCoordinateRequestState
      && lhs.nearestCity == rhs.nearestCity
    }
  }
  
  public enum Action: BindableAction {
    case alert(PresentationAction<Alert>)
    
    case binding(BindingAction<State>)
    
    case changeLocationServiceAuthorizationStatus(CLAuthorizationStatus)
    
    case hideQueryWarningToast
    
    case networkAvailable
    
    case onAppear
    
    case receiveNearestCity(City)
    case receiveSearchValidation(CitySearchValidationResult)
    
    case responseSearch(CitySearchResponse)
    case responseSearchEngine(RequestResult<CitySearchEngine>)
    case responseUserCoordinate(Result<Coordinate, LocationServiceError>)
    
    case tapDefineUserLocation
    case tapRequestSearchEngine
    
    public enum Alert: Int, Equatable, Sendable {
      case cancel
      case openApplicationSettings
    }

    init(action: CityListView.Action) {
      switch action {
      case .tapDefineUserLocation:
        self = .tapDefineUserLocation
      }
    }
  }
  
  enum CancelId {
    case debounceQueryWarningTimeout
    case debounceSearch
  }
  
  public var body: some ReducerOf<Self> {
    BindingReducer()
    Reduce { state, action in
      var result: Effect<Action> = .none
      switch action {
      case let .alert(presentationAction):
        switch presentationAction {
        case let .presented(action):
          state.alert = nil
          
          switch action {
          case .cancel:
            break
            
          case .openApplicationSettings:
            let openApplicationSettings = self.openApplicationSettings
            result = .run { _ in await openApplicationSettings() }
          }
          
        default:
          break
        }
        
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
        
      case .hideQueryWarningToast:
        state.queryInvalidSymbols = .empty
        
        result = .cancel(id: CancelId.debounceQueryWarningTimeout)
        
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
        
      case let .receiveNearestCity(city):
        state.setNearestCity(city)
        
      case let .receiveSearchValidation(validation):
        var effects = [Effect<Action>]()
        if let invalidSymbols = validation.invalidSymbols {
          state.queryInvalidSymbols = invalidSymbols
          
          let hideQueryWarningToastEffect = Effect<Action>
            .run { send in await send(.hideQueryWarningToast) }
            .debounce(
              id: CancelId.debounceQueryWarningTimeout,
              for: .seconds(.queryWarningTimeout),
              scheduler: mainQueue
            )
          
          effects.append(hideQueryWarningToastEffect)
        }
        
        let query = validation.query()
        if state.searchQuery != query {
          state.searchQuery = query
          effects.append(fetchSearchResultEffect(state: &state))
        }
        
        if !effects.isEmpty {
          result = .merge(effects)
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
          // FIXME: big animation lag on launching app first time after install...
          state.isSearchFocused = true
          
          result = .merge([
            fetchSearchResultEffect(state: &state),
            fetchNearestCityEffect(state: &state)
          ])

        case let .failure(error):
          state.searchEngineRequestState = .error(error)
        }
        
      case let .responseUserCoordinate(response):
        state.receiveUserCoordinateResponse(response)
        result = fetchNearestCityEffect(state: &state, isWantUpdate: true)
        
      case .tapDefineUserLocation:
        state.isWantUserCoordinate = true
        
        let isLocationServiceDenied = locationService.authorizationStatus().isDenied
        if isLocationServiceDenied {
          state.alert = .openApplicationSettings
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
    .ifLet(\.$alert, action: \.alert)
  }
  
  private func fetchNearestCityEffect(
    state: inout State,
    isWantUpdate: Bool = false
  ) -> Effect<Action> {
    let engine = state.searchEngine
    let isNeeded = !engine.isEmpty() && (isWantUpdate || state.nearestCity == nil)

    guard
      isNeeded,
      let userCoordinate = state.userCoordinate
    else { return .none }
    
    return .run { send in
      guard let city = await engine.findNearestCity(to: userCoordinate) else { return }
      await send(.receiveNearestCity(city))
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
    state.setUserCoordinateRequestState(.processing)
    
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

extension AlertState where Action == CitySelectionFeature.Action.Alert {
  static let openApplicationSettings = AlertState(
    title: {
      TextState("Для определения Вашего местоположения необхожимо включить геолокацию")
    },
    actions: {
      ButtonState(
        role: .cancel,
        action: .cancel,
        label: { TextState(String.cancellation) }
      )
      ButtonState(
        action: .openApplicationSettings,
        label: { TextState("Открыть настройки") }
      )
    }
  )
}


/// Constants
private extension TimeInterval {
  static let queryWarningTimeout: TimeInterval = 5
}
