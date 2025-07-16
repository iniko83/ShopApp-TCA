//
//  CitySelectionListFeature.swift
//  CitySelectionFeature
//
//  Created by Igor Nikolaev on 11.07.2025.
//

import ComposableArchitecture
import Sharing

@Reducer
struct CitySelectionListFeature {
  typealias Action = CitySelectionListAction

  init() {}

  @ObservableState
  struct State: Equatable {
    @Shared fileprivate(set) var listData: CitySelectionListData
    @Shared fileprivate(set) var sharedData: CitySelectionSharedData

    init(
      listData: Shared<CitySelectionListData>,
      sharedData: Shared<CitySelectionSharedData>
    ) {
      _listData = listData
      _sharedData = sharedData
    }
  }

  var body: some ReducerOf<Self> {
    Reduce { state, action in .none }
  }
}

public enum CitySelectionListAction {
  case delegate(Delegate)

  public enum Delegate {
    case focusSearch
    case tapDefineUserLocation
    case toastAction(CityToastAction)
  }
}
