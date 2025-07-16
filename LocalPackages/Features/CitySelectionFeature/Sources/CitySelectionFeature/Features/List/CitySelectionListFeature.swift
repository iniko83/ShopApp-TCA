//
//  CitySelectionListFeature.swift
//  CitySelectionFeature
//
//  Created by Igor Nikolaev on 11.07.2025.
//

import ComposableArchitecture

@Reducer
struct CitySelectionListFeature {
  typealias Action = CitySelectionListAction

  init() {}

  @ObservableState
  struct State: Equatable {
    fileprivate(set) var listData: CitySelectionListData
    fileprivate(set) var sharedData: CitySelectionSharedData

    init(
      listData: CitySelectionListData,
      sharedData: CitySelectionSharedData
    ) {
      self.listData = listData
      self.sharedData = sharedData
    }
  }

  var body: some ReducerOf<Self> {
    Reduce { state, action in .none }
  }
}

public enum CitySelectionListAction {
  case delegate(Delegate)

  public enum Delegate {
    case changeSelectedCityId(Int?)
    case focusSearch
    case tapDefineUserLocation
    case toastAction(CityToastAction)
  }
}
