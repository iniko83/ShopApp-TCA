//
//  CitySelectionHistoryFeature.swift
//  CitySelectionFeature
//
//  Created by Igor Nikolaev on 16.07.2025.
//

import ComposableArchitecture
import Sharing

@Reducer
struct CitySelectionHistoryFeature {
  typealias Action = CitySelectionHistoryAction

  init() {}

  @ObservableState
  struct State: Equatable {
    @Shared fileprivate(set) var historyData: CitySelectionHistoryData
    @Shared fileprivate(set) var sharedData: CitySelectionSharedData

    init(
      historyData: Shared<CitySelectionHistoryData>,
      sharedData: Shared<CitySelectionSharedData>
    ) {
      _historyData = historyData
      _sharedData = sharedData
    }
  }

  var body: some ReducerOf<Self> {
    Reduce { state, action in .none }
  }
}

public enum CitySelectionHistoryAction {
  case delegate(Delegate)

  public enum Delegate {
    case removeCityIdFromSelectionHistory(Int)
  }
}
