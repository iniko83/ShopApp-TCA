//
//  CitySelectionHistoryFeature.swift
//  CitySelectionFeature
//
//  Created by Igor Nikolaev on 16.07.2025.
//

import ComposableArchitecture
import Foundation
import Utility

@Reducer
struct CitySelectionHistoryFeature {
  typealias Action = CitySelectionHistoryAction

  init() {}

  @ObservableState
  struct State: Equatable {
    fileprivate(set) var cities: [City]
    fileprivate(set) var sharedData: CitySelectionSharedData

    init(
      cities: [City],
      sharedData: CitySelectionSharedData
    ) {
      self.cities = cities
      self.sharedData = sharedData
    }

    func isCitiesVisible() -> Bool {
      !cities.isEmpty
    }
  }

  var body: some ReducerOf<Self> {
    Reduce { state, action in .none }
  }
}

public enum CitySelectionHistoryAction {
  case delegate(Delegate)

  public enum Delegate {
    case changeSelectedCityId(Int?)
    case changeSelectionHistoryHeight(CGFloat)
    case removeCityIdFromSelectionHistory(Int)
  }
}
