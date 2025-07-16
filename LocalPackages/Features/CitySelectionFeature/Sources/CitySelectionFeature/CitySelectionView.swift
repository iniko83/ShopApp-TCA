//
//  CitySelectionView.swift
//  CitySelectionFeature
//
//  Created by Igor Nikolaev on 17.06.2025.
//

import ComposableArchitecture
import Dependencies
import SwiftUI

import NetworkClient
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
        ZStack(alignment: .top) {
          TabsView()
          SearchPanelView()
        }
        .coordinateSpace(name: CoordinateSpaces.content)

      case .loading:
        LoadingCitiesView()
        
      case let .error(error):
        ErrorView(error: error)
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

  @ViewBuilder private func TabsView() -> some View {
    TabView {
      ZStack {
        CitySelectionListView(store: store.scope(state: \.list, action: \.list))
        CitySelectionHistoryView(store: store.scope(state: \.history, action: \.history))
      }
        .tabItem { Color.clear }
        .toolbar(.hidden, for: .tabBar)
    }
  }

  @ViewBuilder private func ErrorView(error: RequestError) -> some View {
    RequestErrorView(
      configuration: .init(
        error: error,
        message: "Не удалось загрузить список городов."
      ),
      retryAction: { store.send(.tapRequestSearchEngine) }
    )
    .padding()
  }

  @ViewBuilder private func LoadingCitiesView() -> some View {
    ActivityView(style: .ballRotateChase)
      .activitySize(.screen)
      .tint(.blue)
      .opacity(0.5)
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
        .transition(.opacity.combined(with: .move(edge: .trailing)))
      }
    }
    .fixedSize(horizontal: false, vertical: true)
    .animation(animation, value: isSearchFocused)
    .padding(EdgeInsets(top: 0, leading: 16, bottom: 2, trailing: 16))
  }
  
  @ViewBuilder private func SearchPanelView() -> some View {
    let invalidSymbols = store.state.queryInvalidSymbols
    let isShowQueryToast = !invalidSymbols.isEmpty
    
    VStack(spacing: 0) {
      SearchFieldView()
        .onGeometryChange(
          for: Frames.self,
          of: { geometry in
            Frames(
              content: geometry.frame(in: .named(CoordinateSpaces.content)),
              global: geometry.frame(in: .global)
            )
          },
          action: { frames in
            store.send(
              .changeSearchFieldFrames(
                content: frames.content,
                global: frames.global
              )
            )
          }
        )
      
      VStack {
        if isShowQueryToast {
          CityQueryToastView(
            invalidSymbols: invalidSymbols,
            onClose: { store.send(.hideQueryWarningToast) }
          )
          .padding(.top, 6)
          .transition(.opacity.combined(with: .move(edge: .top)))
        }
      }
      .frame(maxWidth: .infinity, minHeight: 80, alignment: .top)
      .padding(.horizontal)
      .verticalGradientMaskWithPaddings(top: 12, topOpacity: 0.5)
      
      Spacer()
    }
    .animation(.smooth, value: isShowQueryToast)
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
