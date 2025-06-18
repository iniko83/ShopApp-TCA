// The Swift Programming Language
// https://docs.swift.org/swift-book

import ComposableArchitecture
import CoreLocation
import SwiftUI

import LocationService
import NetworkClient
import Utility

@Reducer
public struct CitySelectionFeature {
  @Dependency(\.citySelectionApi) var api: CitySelectionApi
  
  @ObservableState
  public struct State: Equatable {
    public var selectedCityId: Int?
    
    var citiesRequestState = RequestState()
    
    // ignored
    var cities = [City]()
   
    fileprivate func isNeedRequestCities() -> Bool {
      cities.isEmpty && citiesRequestState != .loading
    }
    
    /// Equatable
    public static func == (lhs: State, rhs: State) -> Bool {
      lhs.selectedCityId == rhs.selectedCityId
      && lhs.citiesRequestState == rhs.citiesRequestState
    }
  }
  
  public enum Action {
    case onAppear
    
    case responseCities(RequestResult<[City]>)
    
    case selectCity(id: Int)
    
    case tapRequestCities
  }
  
  public var body: some ReducerOf<Self> {
    Reduce { state, action in
      var result: Effect<Action> = .none
      switch action {
      case .onAppear:
        if state.isNeedRequestCities() {
          result = requestCitiesEffect(state: &state)
        }
        
      case let .responseCities(response):
        switch response {
        case let .success(value):
          state.citiesRequestState = .default
          state.cities = value
          
        case let .failure(error):
          state.citiesRequestState = .error(error)
        }
        
      case let .selectCity(id):
        state.selectedCityId = id
        
        // FIXME: debug log
        print("select city: \(id)")
        
      case .tapRequestCities:
        if state.isNeedRequestCities() {
          result = requestCitiesEffect(state: &state)
        }
      }
      return result
    }
  }
  
  private func requestCitiesEffect(state: inout State) -> Effect<Action> {
    state.citiesRequestState = .loading
    
    return .run { [loadCities = api.loadCities] send in
      let response = await loadCities()
      await send(.responseCities(response))
    }
  }
}
