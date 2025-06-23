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
  
  @FocusState private var isSearchFocused: Bool
  
  public init(store: StoreOf<CitySelectionFeature>) {
    self.store = store
  }
  
  public var body: some View {
    ZStack {
      switch store.citiesRequestState {
      case .default:
        VStack(spacing: 0) {
          SearchFieldView()
          
          CityListView(
            cities: store.state.cities,
            selectedCityId: store.state.selectedCityId,
            nearestCity: store.state.nearestCity,
            userCoordinate: store.state.userCoordinate,
            userCoordinateRequestState: store.state.userCoordinateRequestState,
            onAction: { store.send(.init(action: $0)) }
          )
        }
        
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
  
  @ViewBuilder private func SearchFieldView() -> some View {
    ZStack {
      Button(
        action: { isSearchFocused = true },
        label: { Color.clear }
      )
      .buttonStyle(
        InputFieldButtonStyle.defaultStyle(isFocused: $store.isSearchFocused)
      )
      
      ClearableInputView(
        isClearHidden: Binding<Bool>(
          get: { store.searchText.isEmpty },
          set: { _ in }
        ),
        onClear: { store.send(.binding(.set(\.searchText, .empty))) },
        content: {
          TextField("Поиск города", text: $store.searchText)
            .focused($isSearchFocused)
            .bind($store.isSearchFocused, to: $isSearchFocused)
            .padding(EdgeInsets(top: 8, leading: 8, bottom: 8, trailing: 0))
        }
      )
    }
    .fixedSize(horizontal: false, vertical: true)
    .padding(EdgeInsets(top: 0, leading: 16, bottom: 2, trailing: 16))
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
