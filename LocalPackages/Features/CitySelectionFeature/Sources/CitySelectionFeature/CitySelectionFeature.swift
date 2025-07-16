// The Swift Programming Language
// https://docs.swift.org/swift-book

/*
 Sharing State explanations:
  [ https://pointfreeco.github.io/swift-composable-architecture/main/documentation/composablearchitecture/sharingstate/ ]
 */

import ComposableArchitecture
import CoreLocation
import Dependencies
import Sharing
import SwiftUI

import LocationService
import NetworkClient
import NetworkConnectionService
import Utility

// FIXME: dark mode

@Reducer
public struct CitySelectionFeature {
  @Dependency(\.mainQueue) var mainQueue
  
  @Dependency(\.citySelectionApi) var api: CitySelectionApi
  @Dependency(\.citySelectionInteractor) var interactor: CitySelectionInteractor
  @Dependency(\.locationService) var locationService: LocationService
  @Dependency(\.networkConnectionService) var networkConnectionService
  @Dependency(\.openApplicationSettings) var openApplicationSettings
  
  public init() {}
  
  @ObservableState
  public struct State: Equatable {
    @Presents var alert: AlertState<Action.Alert>?
    
    var isSearchFocused: Bool = false

    fileprivate var searchQuery: String = .empty
    fileprivate(set) var queryInvalidSymbols: String = .empty

    fileprivate(set) var searchEngineRequestState = RequestState()

    private var selectionHistoryCityIds = [Int]()

    @Shared fileprivate(set) var sharedData: CitySelectionSharedData

    // ignored
    @Shared fileprivate(set) var historyData: CitySelectionHistoryData
    @Shared fileprivate(set) var listData: CitySelectionListData
    fileprivate(set) var mapCityIds = Set<Int>()

    private(set) var isInitialized = false
    fileprivate(set) var isWantUserCoordinate = false
    private(set) var searchEngine = CitySearchEngine()

    var cities: [City] { searchEngine.cities }

    private(set) var list: CitySelectionListFeature.State
    private(set) var history: CitySelectionHistoryFeature.State

    public init() {
      let historyData = Shared(value: CitySelectionHistoryData())
      let listData = Shared(value: CitySelectionListData())
      let sharedData = Shared(value: CitySelectionSharedData())

      _historyData = historyData
      _listData = listData
      _sharedData = sharedData

      history = .init(
        historyData: historyData,
        sharedData: sharedData
      )
      list = .init(
        listData: listData,
        sharedData: sharedData
      )
    }
    
    func city(id: Int) -> City? {
      cities[safe: id]
    }
    
    func isNeedSelectCity() -> Bool {
      sharedData.selectedCityId == nil
    }
   
    fileprivate func isNeedRequestSearchEngine() -> Bool {
      searchEngine.isEmpty() && searchEngineRequestState != .loading
    }
    
    fileprivate func isNeedRequestUserCoordinate() -> Bool {
      isWantUserCoordinate
      && sharedData.locationRelated.userCoordinateRequestState != .processing
    }
    
    mutating fileprivate func initialize(
      selectedCityId: Int?,
      selectionHistoryCityIds: [Int],
      isLocationServiceAuthorized: Bool
    ) {
      $sharedData.withLock { $0.selectedCityId = selectedCityId }
      setSelectionHistoryCityIds(selectionHistoryCityIds)
      
      isWantUserCoordinate = isLocationServiceAuthorized

      if isNeedSelectCity() {
        $sharedData.withLock { data in
          data.toast.list = [Toast(item: .citySelectionRequired)]
        }
      }
      
      isInitialized = true
    }

    mutating func receiveUserCoordinateResponse(
      _ response: Result<Coordinate, LocationServiceError>
    ) {
      $sharedData.withLock { sharedData in
        var data = sharedData.locationRelated
        switch response {
        case let .success(coordinate):
          data.userCoordinateRequestState = .default
          data.userCoordinate = coordinate

        case let .failure(error):
          data.userCoordinateRequestState = .error(error)
        }
        sharedData.locationRelated = data
      }
    }

    mutating fileprivate func setSearchEngine(_ engine: CitySearchEngine) {
      searchEngine = engine
      updateVisibleSelectionHistoryCityIds()
    }

    // MARK: Selection history support
    mutating fileprivate func setSelectionHistoryCityIds(_ ids: [Int]) {
      selectionHistoryCityIds = ids
      updateVisibleSelectionHistoryCityIds()
    }
    
    mutating fileprivate func updateVisibleSelectionHistoryCityIds() {
      let selectedCityId = sharedData.selectedCityId
      let cityIds = selectionHistoryCityIds.withRemovedFirst(
        where: { $0 == selectedCityId }
      )
      let isVisible = !cityIds.isEmpty
      $historyData.withLock { $0.cityIds = cityIds }
      $sharedData.withLock { $0.layout.isSelectionHistoryVisible = isVisible }
    }

    // MARK: Toast support
    mutating fileprivate func displayToastNearestCityFailure() {
      $sharedData.withLock {
        $0.toast.displayToast(
          Toast(
            item: .nearestCityFetchFailure,
            timeoutStamp: Timestamp.timeout(3)
          )
        )
      }
    }

    mutating fileprivate func removeToast(item: ToastItem) {
      $sharedData.withLock {
        $0.toast.removeToast(item: item)
      }
    }

    /// Equatable
    public static func == (lhs: State, rhs: State) -> Bool {
      lhs.selectionHistoryCityIds == rhs.selectionHistoryCityIds
      && lhs.isSearchFocused == rhs.isSearchFocused
      && lhs.searchQuery == rhs.searchQuery
      && lhs.searchEngineRequestState == rhs.searchEngineRequestState
      && lhs.sharedData == rhs.sharedData
    }
  }
  
  public enum Action: BindableAction {
    case alert(PresentationAction<Alert>)
    
    case binding(BindingAction<State>)
    
    case changeLocationServiceAuthorizationStatus(CLAuthorizationStatus)
    case changeSelectedCityId(Int?)
    case changeSelectionHistoryCityIds([Int])

    case hideQueryWarningToast

    case history(CitySelectionHistoryAction)
    case list(CitySelectionListAction)

    case networkAvailable
    
    case onAppear
    
    case receiveNearestCity(City)
    case receiveSearchValidation(CitySearchValidationResult)

    case responseSearch(CitySearchResponse)
    case responseSearchEngine(RequestResult<CitySearchEngine>)
    case responseUserCoordinate(Result<Coordinate, LocationServiceError>)
    
    case tapRequestSearchEngine
    
    case toastExpirationTick
    
    public enum Alert: Int, Equatable, Sendable {
      case cancel
      case openApplicationSettings
    }
  }
  
  enum CancelId {
    case debounceQueryWarningTimeout
    case debounceSearch
    case toastTimeout
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
        case \.isSearchFocused:
          if !state.isSearchFocused {
            result = .send(.hideQueryWarningToast)
          }

        default:
          break
        }

      case let .changeLocationServiceAuthorizationStatus(status):
        if status.isAuthorized && state.isNeedRequestUserCoordinate() {
          result = requestUserCoordinateEffect(state: &state)
        } else {
          state.isWantUserCoordinate = false
        }

      case let .changeSelectedCityId(id):
        if let id {
          state.removeToast(item: .citySelectionRequired)

          if let city = state.city(id: id) {
            let interactor = self.interactor
            Task.onMainActor { interactor.selectCity(city) }
          }
        }

      case let .changeSelectionHistoryCityIds(ids):
        state.setSelectionHistoryCityIds(ids)
        
      case .hideQueryWarningToast:
        state.queryInvalidSymbols = .empty
        
        result = .cancel(id: CancelId.debounceQueryWarningTimeout)

      case let .history(historyAction):
        switch historyAction {
        case let .delegate(delegateAction):
          switch delegateAction {
          case let .removeCityIdFromSelectionHistory(id):
            let interactor = self.interactor
            Task.onMainActor { interactor.removeCityIdFromSelectionHistory(id) }
          }
        }

      case let .list(listAction):
        switch listAction {
        case let .delegate(delegateAction):
          switch delegateAction {
          case .focusSearch:
            state.isSearchFocused = true

          case .tapDefineUserLocation:
            result = onTapDefineUserLocation(state: &state)

          case let .toastAction(toastAction):
            result = onToastAction(toastAction, state: &state)
          }
        }

      case .networkAvailable:
        if state.searchEngineRequestState.isRetryableError() {
          result = requestSearchEngineEffect(state: &state)
        }
        
      case .onAppear:
        let isStateUninitialized = !state.isInitialized
        if isStateUninitialized {
          var selectedCityId: Int?
          var selectionHistoryCityIds = [Int]()
          try? MainActor.assumeIsolated { [interactor = self.interactor] in
            selectedCityId = interactor.selectedCityId()
            selectionHistoryCityIds = interactor.historyCityIds()
          }

          let isLocationServiceAuthorized = locationServiceAuthorizationStatus().isAuthorized

          state.initialize(
            selectedCityId: selectedCityId,
            selectionHistoryCityIds: selectionHistoryCityIds,
            isLocationServiceAuthorized: isLocationServiceAuthorized
          )
        }
        
        var effects = [Effect<Action>]()
        if isStateUninitialized {
          effects += [
            locationServiceAuthorizationStatusStreamEffect(),
            networkAvailabilityStreamEffect(),
            observeSelectionCityIdEffect(sharedData: state.$sharedData),
            selectionHistoryCityIdsStreamEffect()
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
        state.$sharedData.withLock {
          $0.locationRelated.nearestCity = city
        }

      case let .receiveSearchValidation(validation):
        var effects = [Effect<Action>]()
        if let invalidSymbols = validation.invalidSymbols {
          state.queryInvalidSymbols = invalidSymbols
          
          let hideQueryWarningToastEffect = Effect<Action>
            .send(.hideQueryWarningToast)
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
          state.$listData.withLock { $0.applyResponse(response) }
          state.mapCityIds = response.result.mapIds
        }
        
      case let .responseSearchEngine(response):
        switch response {
        case let .success(value):
          state.searchEngineRequestState = .default
          state.setSearchEngine(value)
          state.$historyData.withLock { $0.allCities = value.cities }
          state.$listData.withLock { $0.allCities = value.cities }
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
        
      case .tapRequestSearchEngine:
        if state.isNeedRequestSearchEngine() {
          result = requestSearchEngineEffect(state: &state)
        }
        
      case .toastExpirationTick:
        result = toastExpirationTimerEffect(state: &state)
      }
      return result
    }
    .ifLet(\.$alert, action: \.alert)
  }

  private func onTapDefineUserLocation(state: inout State) -> Effect<Action> {
    state.isWantUserCoordinate = true

    var result: Effect<Action> = .none
    let isLocationServiceDenied = locationServiceAuthorizationStatus().isDenied
    if isLocationServiceDenied {
      state.alert = .openApplicationSettings
    } else if state.isNeedRequestUserCoordinate() {
      result = requestUserCoordinateEffect(state: &state)
    }
    return result
  }

  private func onToastAction(
    _ action: CityToastAction,
    state: inout State
  ) -> Effect<Action> {
    let result: Effect<Action>
    switch action {
    case let .removeItem(toastItem):
      state.removeToast(item: toastItem)
      result = toastExpirationTimerEffect(state: &state)
    }
    return result
  }

  private func locationServiceAuthorizationStatus() -> CLAuthorizationStatus {
    // NOTE: during TCA migration to Swift6 we need to explicitly tell the compiler that this code will be executed on MainActor
    var result = CLAuthorizationStatus.notDetermined
    let authorizationStatus = locationService.authorizationStatus
    try? MainActor.assumeIsolated {
      result = authorizationStatus()
    }
    return result
  }

  private func fetchNearestCityEffect(
    state: inout State,
    isWantUpdate: Bool = false
  ) -> Effect<Action> {
    let engine = state.searchEngine
    let isNeeded = !engine.isEmpty()
    && (isWantUpdate || state.sharedData.locationRelated.nearestCity == nil)

    guard isNeeded else { return .none }
      
    let result: Effect<Action>
    if let userCoordinate = state.sharedData.locationRelated.userCoordinate {
      result = .run { send in
        guard let city = await engine.findNearestCity(to: userCoordinate) else { return }
        await send(.receiveNearestCity(city))
      }
    } else {
      if isWantUpdate {
        state.displayToastNearestCityFailure()
        result = toastExpirationTimerEffect(state: &state)
      } else {
        result = .none
      }
    }
    return result
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
  
  private func toastExpirationTimerEffect(state: inout State) -> Effect<Action> {
    let delay = state.$sharedData.withLock { sharedData in
      sharedData.toast.removeExpiredToasts()
      return sharedData.toast.nearestTimeoutDelay()
    }

    let result: Effect<Action>
    if let delay {
      result = .send(.toastExpirationTick)
        .debounce(
          id: CancelId.toastTimeout,
          for: .seconds(delay),
          scheduler: mainQueue
        )
    } else {
      result = .cancel(id: CancelId.toastTimeout)
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

  private func observeSelectionCityIdEffect(
    sharedData: Shared<CitySelectionSharedData>
  ) -> Effect<Action> {
    .run { send in
      let selectedCityIdPublisher = sharedData.publisher
        .map { $0.selectedCityId }
        .removeDuplicates()
        .values
      for await id in selectedCityIdPublisher {
        await send(.changeSelectedCityId(id))
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
    state.$sharedData.withLock {
      $0.locationRelated.userCoordinateRequestState = .processing
    }

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
  
  private func selectionHistoryCityIdsStreamEffect() -> Effect<Action> {
    let cityIdsStream = interactor.historyCityIdsStream
    return .run { send in
      for await cityIds in cityIdsStream() {
        await send(.changeSelectionHistoryCityIds(cityIds))
      }
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
