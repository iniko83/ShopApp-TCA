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
  
  public var body: some View {
    ZStack {
      switch store.citiesRequestState {
      case .default:
        ScrollView {
          LazyVStack(
            spacing: 0,
            content: {
              ForEach(store.state.cities, id: \.id) { city in
                let isSelected = city.id == store.state.selectedCityId
                CityContentView(city: city, isSelected: isSelected)
              }
            }
          )
          .animation(.smooth, value: store.state.cities)
        }
        .scrollBounceBehavior(.basedOnSize, axes: [.vertical])
        
      case .loading:
        ActivityView(style: .ballRotateChase)
          .activitySize(.screen)
          .tint(.blue)
          .opacity(0.5)
        
      case let .error(error):
        // FIXME: добавить error view
        Text("Не удалось загрузить список городов.")
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
