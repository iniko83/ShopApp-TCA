//
//  CitySelectionView.swift
//  CitySelectionFeature
//
//  Created by Igor Nikolaev on 17.06.2025.
//

import ComposableArchitecture
import Dependencies
import SwiftUI

import Utility

public struct CitySelectionView: View {
  @Bindable public var store: StoreOf<CitySelectionFeature>
  
  public init(store: StoreOf<CitySelectionFeature>) {
    self.store = store
  }
  
  public var body: some View {
    ZStack {
      switch store.citiesRequestState {
      case .default:
        CityListView(
          cities: store.state.cities,
          selectedCityId: store.state.selectedCityId,
          nearestCity: store.state.nearestCity,
          userCoordinateRequestState: store.state.userCoordinateRequestState,
          onAction: { store.send(.init(action: $0)) }
        )
        
      case .loading:
        ActivityView(style: .ballRotateChase)
          .activitySize(.screen)
          .tint(.blue)
          .opacity(0.5)
        
      case let .error(error):
        RequestErrorView(
          configuration: .init(
            error: error,
            message: "Не удалось загрузить список городов."
          ),
          retryAction: { store.send(.tapRequestCities) }
        )
        .padding()
      }
    }
    .onAppear {
      store.send(.onAppear)
    }
  }
}


#Preview("Online") {
  let _ = prepareDependencies {
    $0.citySelectionApi = .online
  }
  
  CitySelectionView(
    store: Store(
      initialState: CitySelectionFeature.State(),
      reducer: { CitySelectionFeature() }
    )
  )
}

#Preview("Offline") {
  let _ = prepareDependencies {
    $0.citySelectionApi = .offline
  }
  
  CitySelectionView(
    store: Store(
      initialState: CitySelectionFeature.State(),
      reducer: { CitySelectionFeature() }
    )
  )
}

#Preview("Empty") {
  let _ = prepareDependencies {
    $0.citySelectionApi = .empty
  }
  
  CitySelectionView(
    store: Store(
      initialState: CitySelectionFeature.State(),
      reducer: { CitySelectionFeature() }
    )
  )
}
