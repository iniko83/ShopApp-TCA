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
  @State private var searchText = String.empty
  
  public init(store: StoreOf<CitySelectionFeature>) {
    self.store = store
  }
  
  public var body: some View {
    ZStack {
      switch store.state.searchEngineRequestState {
      case .default:
        let invalidSymbols = store.state.queryInvalidSymbols
        let isShowQueryToast = !invalidSymbols.isEmpty
        
        VStack(spacing: 0) {
          SearchFieldView()
          
          ZStack(alignment: .top) {
            CityListView(
              selectedCityId: $store.selectedCityId,
              sections: $store.tableSections,
              cities: store.state.cities,
              nearestCity: store.state.nearestCity,
              nearestCityRequestState: store.state.nearestCityRequestState,
              userCoordinate: store.state.userCoordinate,
              onAction: { store.send(.init(action: $0)) }
            )

            // FIXME: add mask
            VStack {
              if isShowQueryToast {
                QueryToastView(invalidSymbols: invalidSymbols)
              }
            }
            .frame(maxWidth: .infinity, minHeight: 50)
            .clipped()
            .padding(.horizontal)
          }
          .animation(.smooth, value: isShowQueryToast)
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
          retryAction: { store.send(.tapRequestSearchEngine) }
        )
        .padding()
      }
    }
    .if(store.state.isInitialized) { content in
      content.animation(.smooth, value: store.state.searchEngineRequestState)
    }
    .alert($store.scope(state: \.alert, action: \.alert))
    .onAppear {
      store.send(.onAppear)
    }
  }
  
  @ViewBuilder private func QueryToastView(invalidSymbols: String) -> some View {
    let style = ToastStyle.warning
    let message = "Удалены недопустимые символы: **\(invalidSymbols)**"
    
    ClosableToastContentView(
      style: style,
      onClose: { store.send(.hideQueryWarningToast) },
      content: {
        ToastContentView(
          style: style,
          content: {
            Text(message.markdown()!)
              .font(.subheadline)
              .opacity(0.7)
          }
        )
      }
    )
    .toast(
      style,
      cornerRadius: 10,
      padding: EdgeInsets(horizontal: 8, vertical: 4)
    )
    .transition(
      .opacity.combined(with: .move(edge: .top))
    )
  }
  
  @ViewBuilder private func SearchFieldView() -> some View {
    let animation: Animation = .smooth
    let isSearchFocused = store.state.isSearchFocused
    
    HStack(spacing: 0) {
      ZStack {
        Button(
          action: { self.isSearchFocused = true },
          label: { Color.clear }
        )
        .buttonStyle(
          InputFieldButtonStyle.defaultStyle(
            isFocused: $store.isSearchFocused,
            animation: animation
          )
        )
        
        ClearableInputView(
          isClearHidden: Binding<Bool>(
            get: { searchText.isEmpty },
            set: { _ in }
          ),
          onClear: { searchText = .empty },
          content: {
            TextField("Поиск города", text: $searchText)
              .focused($isSearchFocused)
              .bind($store.isSearchFocused, to: $isSearchFocused)
              .onChange(of: searchText) { from, to in
                let validation = CitySearch.validate(text: to)
                store.send(.receiveSearchValidation(validation))

                guard to != validation.text else { return }
                searchText = validation.text
              }
              .padding(EdgeInsets(top: 8, leading: 8, bottom: 8, trailing: 0))
          }
        )
      }
        
      if isSearchFocused {
        Button(
          action: { self.isSearchFocused = false },
          label: {
            Text(String.cancellation)
              .tint(.black)
          }
        )
        .allowsHitTesting(isSearchFocused)
        .fixedSize()
        .padding(.leading, 8)
        .transition(
          .opacity
            .combined(with: .move(edge: .trailing))
        )
      }
    }
    .fixedSize(horizontal: false, vertical: true)
    .animation(animation, value: isSearchFocused)
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
