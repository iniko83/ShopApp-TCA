//
//  CitySelectionListView.swift
//  CitySelectionFeature
//
//  Created by Igor Nikolaev on 11.07.2025.
//

import ComposableArchitecture
import Dependencies
import SwiftUI

import NetworkClient
import Utility

struct CitySelectionListView: View {
  let store: StoreOf<CitySelectionListFeature>

  @State private var isKeyboardShown = false

  @State private var bottomPanelFrames = Frames()
  @State private var screenHeight = CGFloat.zero

  public init(store: StoreOf<CitySelectionListFeature>) {
    self.store = store
  }

  public var body: some View {
    ZStack(alignment: .top) {
      CitiesPanelView()
      EdgeEffectView()

      BottomToastPanelView()
      BottomNearestCityView()
    }
  }

  @ViewBuilder private func BottomNearestCityView() -> some View {
    let locationRelatedData = store.state.sharedData.locationRelated

    VStack(spacing: 0) {
      Spacer()

      NearestCityPanelView(
        selectedCityId: bindingSelectedCityId(),
        city: locationRelatedData.nearestCity,
        isProcessing: locationRelatedData.nearestCityRequestState.isProcessing,
        userCoordinate: locationRelatedData.userCoordinate,
        onTapDefineUserLocation: { store.send(.delegate(.tapDefineUserLocation)) }
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
    let offset = isKeyboardShown ? 0 : bottomPanelFrames.content.height

    VStack(spacing: 0) {
      Spacer()

      CityToastListView(
        toasts: store.state.sharedData.toast.list,
        onAction: { store.send(.delegate(.toastAction($0))) }
      )
      .padding(.bottom)
      .padding(.bottom, offset)
      .animation(.spring(.keyboard), value: offset)
    }
  }

  @ViewBuilder private func CitiesEmptyView(topPadding: CGFloat) -> some View {
    CitySearchEmptyView(
      onTap: { store.send(.delegate(.focusSearch)) }
    )
    .verticalGradientMaskWithPaddings(top: 24)
    .padding(.top, topPadding)
    .animation(.smooth, value: topPadding)
    .ignoresSafeArea(.container, edges: .bottom)
  }

  @ViewBuilder private func CitiesPanelView() -> some View {
    let isFoundNothing = store.state.listData.isFoundNothing
    let topPadding = store.state.sharedData.layout.listTopPadding()

    ZStack(alignment: .top) {
      if isFoundNothing {
        CitiesEmptyView(topPadding: topPadding)
      } else {
        CitiesView(listTopPadding: topPadding)
      }
    }
    .animation(.smooth, value: isFoundNothing)
    .onGeometryChange(
      for: Bool.self,
      of: { $0.safeAreaInsets.bottom > 100 },
      action: { isKeyboardShown = $0 }
    )
  }

  @ViewBuilder private func CitiesView(listTopPadding: CGFloat) -> some View {
    let topPadding = listTopPadding - .scrollAdditionalTopPadding

    CityListView(
      selectedCityId: bindingSelectedCityId(),
      sections: store.state.listData.sections,
      userCoordinate: store.state.sharedData.locationRelated.userCoordinate,
      insets: scrollInsets()
    )
    .padding(.top, topPadding)
    .animation(.smooth, value: topPadding)
    .scrollClipDisabled()
  }

  @ViewBuilder private func EdgeEffectView() -> some View {
    Color.clear
      .scrollEdgeEffect(
        edgeEffectScrollConfiguration()
      )
      .onGeometryChange(
        for: CGFloat.self,
        of: { $0.size.height },
        action: { screenHeight = $0 }
      )
      .allowsHitTesting(false)
      .ignoresSafeArea()
  }

  private func edgeEffectScrollConfiguration() -> EdgeEffect.ScrollConfiguration {
    let contentPadding: CGFloat = 10
    let defaultBottomThreshold: CGFloat = 0.3

    let globalSearchFieldFrame = store.state.sharedData.layout.searchFieldFrames.global
    let topHeight = globalSearchFieldFrame.maxY + contentPadding
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

  private func bindingSelectedCityId() -> Binding<Int?> {
    .init(
      get: { store.sharedData.selectedCityId },
      set: { cityId in
        guard store.sharedData.selectedCityId != cityId else { return }
        store.send(.delegate(.changeSelectedCityId(cityId)))
      }
    )
  }

  private func scrollInsets() -> EdgeInsets {
    .init(
      top: .scrollAdditionalTopPadding,
      bottom: isKeyboardShown ? 0 : bottomPanelFrames.content.height
    )
  }
}


/// Constants
private extension CGFloat {
  static let scrollAdditionalTopPadding: CGFloat = 200
}
