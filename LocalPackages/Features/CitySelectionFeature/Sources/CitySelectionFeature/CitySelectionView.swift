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

  @State private var isKeyboardShown = false

  @State private var screenHeight = CGFloat.zero
  @State private var selectionHistoryHeight = CGFloat.zero

  @State private var bottomPanelFrames = Frames()
  @State private var searchFieldFrames = Frames()
    
  public init(store: StoreOf<CitySelectionFeature>) {
    self.store = store
  }
  
  public var body: some View {
    ZStack {
      switch store.state.searchEngineRequestState {
      case .default:
        ZStack(alignment: .top) {
          CitiesView()
          EdgeEffectView()
          HistorySelectionPanelView()
          SearchPanelView()
          BottomPanelView()
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
  
  @ViewBuilder private func BottomPanelView() -> some View {
    ZStack {
      BottomToastPanelView()
      BottomNearestCityView()
    }
  }
  
  @ViewBuilder private func BottomNearestCityView() -> some View {
    VStack(spacing: 0) {
      Spacer()
      
      NearestCityPanelView(
        selectedCityId: $store.selectedCityId,
        nearestCity: store.state.nearestCity,
        nearestCityRequestState: store.state.nearestCityRequestState,
        userCoordinate: store.state.userCoordinate,
        onTapDefineUserLocation: { store.send(.tapDefineUserLocation) }
      )
      .onGeometryChange(
        for: Frames.self,
        of: { geometry in
          Frames(
            content: geometry.frame(in: .named(CoordinateSpaces.content)),
            global: geometry.frame(in: .global)
          )
        },
        action: { bottomPanelFrames = $0 }
      )
    }
    .ignoresSafeArea(.keyboard)
  }
  
  @ViewBuilder private func BottomToastPanelView() -> some View {
    let offset = isKeyboardShown ? 0 : -bottomPanelFrames.content.height
    
    VStack(spacing: 0) {
      Spacer()
      
      CityToastListView(
        items: store.toastItems,
        onAction: { action in store.send(.toastAction(action)) }
      )
      .padding(.bottom)
    }
    .offset(y: offset)
    .animation(.keyboard, value: offset)
  }
  
  @ViewBuilder private func CitiesView() -> some View {
    let topPadding = scrollTopPadding()
    
    CityListView(
      selectedCityId: $store.selectedCityId,
      sections: $store.tableSections,
      cities: store.state.cities,
      userCoordinate: store.state.userCoordinate,
      insets: scrollInsets()
    )
    .padding(.top, topPadding)
    .animation(.smooth, value: topPadding)
    .scrollClipDisabled()
    .onGeometryChange(
      for: Bool.self,
      of: { $0.safeAreaInsets.bottom > 100 },
      action: { isKeyboardShown = $0 }
    )
  }
  
  @ViewBuilder private func EdgeEffectView() -> some View {
    Color.clear
      .scrollEdgeEffect(edgeEffectScrollConfiguration())
      .onGeometryChange(
        for: CGFloat.self,
        of: { $0.size.height },
        action: { screenHeight = $0 }
      )
      .allowsHitTesting(false)
      .ignoresSafeArea()
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
  
  @ViewBuilder private func HistorySelectionPanelView() -> some View {
    let height = searchFieldFrames.content.height
    let isSelectionHistoryVisible = store.state.isSelectionHistoryVisible
    let padding: CGFloat = 12

    VStack(spacing: 0) {
      Spacer()
        .frame(height: height)
      
      if isSelectionHistoryVisible {
        ZStack(alignment: .top) {
          Color.white
            .frame(height: selectionHistoryHeight)
            .animation(.smooth, value: selectionHistoryHeight)
            .verticalGradientMaskWithPaddings(
              top: 0.5 * padding,
              bottom: padding
            )
          
          CitySelectionHistoryView(
            selectedCityId: $store.selectedCityId,
            cities: store.state.visibleSelectionHistoryCities,
            userCoordinate: store.state.userCoordinate,
            onRemoveCityId: { store.send(.removeCityIdFromSelectionHistory($0)) }
          )
          .padding(.bottom, padding)
          .geometryGroup()
          .onGeometryChange(
            for: CGFloat.self,
            of: { $0.size.height },
            action: { selectionHistoryHeight = $0 }
          )
        }
        .transition(.opacity.combined(with: .move(edge: .top)))
      }
      
      Spacer()
    }
    .frame(maxWidth: .infinity)
    .animation(.smooth, value: isSelectionHistoryVisible)
    .verticalGradientMaskWithPaddings(top: height)
    .animation(.smooth, value: height)
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
          action: { searchFieldFrames = $0 }
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
  
  private func edgeEffectScrollConfiguration() -> EdgeEffect.ScrollConfiguration {
    let contentPadding: CGFloat = 10
    let defaultBottomThreshold: CGFloat = 0.3
    
    let topHeight = searchFieldFrames.global.maxY + contentPadding
    let bottomHeight: CGFloat = screenHeight > .zero
      ? screenHeight - (bottomPanelFrames.global.minY + contentPadding)
      : .zero
    
    let thresholdLocation: CGFloat = isKeyboardShown
      ? defaultBottomThreshold * bottomPanelFrames.global.height / bottomHeight
      : defaultBottomThreshold
    
    return .init(
      topEdgeConfiguration: .init(height: topHeight),
      bottomEdgeConfiguration: .init(
        height: bottomHeight,
        thresholdLocation: thresholdLocation
      )
    )
  }
  
  private func scrollInsets() -> EdgeInsets {
    .init(
      top: .scrollAdditionalTopPadding,
      bottom: isKeyboardShown ? 0 : bottomPanelFrames.content.height
    )
  }
  
  private func scrollTopPadding() -> CGFloat {
    let isHistoryVisible = store.state.isSelectionHistoryVisible
    let historyHeight = isHistoryVisible ? selectionHistoryHeight : 0
    let blockHeight = searchFieldFrames.content.height + historyHeight
    let result = blockHeight - .scrollAdditionalTopPadding
    return result
  }
}

extension CitySelectionView {
  private enum CoordinateSpaces {
    case content
  }

  private struct Frames: Equatable {
    let content: CGRect
    let global: CGRect
    
    init(
      content: CGRect,
      global: CGRect
    ) {
      self.content = content
      self.global = global
    }
    
    init() {
      self.init(
        content: .zero,
        global: .zero
      )
    }
  }
}


/// Constants
private extension CGFloat {
  static let scrollAdditionalTopPadding: CGFloat = 200
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
