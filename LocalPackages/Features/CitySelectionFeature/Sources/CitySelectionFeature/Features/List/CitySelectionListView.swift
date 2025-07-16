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

  @State private var selectedCityId: Int?

  @State private var isKeyboardShown = false

  @State private var bottomPanelFrames = Frames()
  @State private var screenHeight = CGFloat.zero

  public init(store: StoreOf<CitySelectionListFeature>) {
    self.store = store
  }

  public var body: some View {
    let listData = store.state.listData
    let sharedData = store.state.sharedData

    let globalSearchFieldFrame = sharedData.layout.searchFieldFrames.global
    let listTopPadding = sharedData.layout.listTopPadding()

    ZStack(alignment: .top) {
      CitiesPanelView(
        listData: listData,
        userCoordinate: sharedData.locationRelated.userCoordinate,
        listTopPadding: listTopPadding
      )
      EdgeEffectView(globalSearchFieldFrame: globalSearchFieldFrame)

      BottomToastPanelView(toastData: sharedData.toast)
      BottomNearestCityView(locationRelatedData: sharedData.locationRelated)
    }
    .bindShared(store.$sharedData.selectedCityId, to: $selectedCityId)
  }

  @ViewBuilder private func BottomNearestCityView(
    locationRelatedData: CitySelectionLocationRelatedData
  ) -> some View {
    VStack(spacing: 0) {
      Spacer()

      NearestCityPanelView(
        selectedCityId: $selectedCityId,
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

  @ViewBuilder private func BottomToastPanelView(
    toastData: CitySelectionToastData
  ) -> some View {
    let offset = isKeyboardShown ? 0 : bottomPanelFrames.content.height

    VStack(spacing: 0) {
      Spacer()

      CityToastListView(
        toasts: toastData.list,
        onAction: { store.send(.delegate(.toastAction($0))) }
      )
      .padding(.bottom)
      .padding(.bottom, offset)
      .animation(.spring(.keyboard), value: offset)
    }
  }

  @ViewBuilder private func CitiesEmptyView(listTopPadding: CGFloat) -> some View {
    CitySearchEmptyView(
      onTap: { store.send(.delegate(.focusSearch)) }
    )
    .verticalGradientMaskWithPaddings(top: 24)
    .padding(.top, listTopPadding)
    .animation(.smooth, value: listTopPadding)
    .ignoresSafeArea(.container, edges: .bottom)
  }

  @ViewBuilder private func CitiesPanelView(
    listData: CitySelectionListData,
    userCoordinate: Coordinate?,
    listTopPadding: CGFloat
  ) -> some View {
    let isFoundNothing = listData.isFoundNothing

    ZStack(alignment: .top) {
      if isFoundNothing {
        CitiesEmptyView(listTopPadding: listTopPadding)
      } else {
        CitiesView(
          listData: listData,
          userCoordinate: userCoordinate,
          listTopPadding: listTopPadding
        )
      }
    }
    .animation(.smooth, value: isFoundNothing)
    .onGeometryChange(
      for: Bool.self,
      of: { $0.safeAreaInsets.bottom > 100 },
      action: { isKeyboardShown = $0 }
    )
  }

  @ViewBuilder private func CitiesView(
    listData: CitySelectionListData,
    userCoordinate: Coordinate?,
    listTopPadding: CGFloat
  ) -> some View {
    let topPadding = listTopPadding - .scrollAdditionalTopPadding

    CityListView(
      selectedCityId: $selectedCityId,
      sections: listData.sections,
      userCoordinate: userCoordinate,
      insets: scrollInsets(),
      cities: { ids in listData.cities(ids: ids) }
    )
    .padding(.top, topPadding)
    .animation(.smooth, value: topPadding)
    .scrollClipDisabled()
  }

  @ViewBuilder private func EdgeEffectView(globalSearchFieldFrame: CGRect) -> some View {
    Color.clear
      .scrollEdgeEffect(
        edgeEffectScrollConfiguration(globalSearchFieldFrame: globalSearchFieldFrame)
      )
      .onGeometryChange(
        for: CGFloat.self,
        of: { $0.size.height },
        action: { screenHeight = $0 }
      )
      .allowsHitTesting(false)
      .ignoresSafeArea()
  }

  private func edgeEffectScrollConfiguration(
    globalSearchFieldFrame: CGRect
  ) -> EdgeEffect.ScrollConfiguration {
    let contentPadding: CGFloat = 10
    let defaultBottomThreshold: CGFloat = 0.3

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
