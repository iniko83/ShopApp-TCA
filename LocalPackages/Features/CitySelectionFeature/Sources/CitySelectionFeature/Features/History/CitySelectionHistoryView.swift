//
//  CitySelectionHistoryView.swift
//  CitySelectionFeature
//
//  Created by Igor Nikolaev on 16.07.2025.
//

import ComposableArchitecture
import SwiftUI
import Utility

struct CitySelectionHistoryView: View {
  let store: StoreOf<CitySelectionHistoryFeature>

  @State private var selectedCityId: Int?
  @State private var selectionHistoryHeight = CGFloat.zero

  public init(store: StoreOf<CitySelectionHistoryFeature>) {
    self.store = store
  }

  public var body: some View {
    let historyData = store.state.historyData
    let sharedData = store.state.sharedData

    let height = sharedData.layout.searchFieldFrames.content.height
    let isListVisible = historyData.isVisible

    VStack(spacing: 0) {
      Spacer()
        .frame(height: height)

      if isListVisible {
        ListView(
          cities: historyData.cities(),
          userCoordinate: sharedData.locationRelated.userCoordinate
        )
        .transition(.opacity.combined(with: .move(edge: .top)))
      }

      Spacer()
    }
    .animation(.smooth, value: selectionHistoryHeight)
    .frame(maxWidth: .infinity)
    .animation(.smooth, value: isListVisible)
    .verticalGradientMaskWithPaddings(top: height)
    .animation(.smooth, value: height)
    .bindShared(store.$sharedData.selectedCityId, to: $selectedCityId)
  }

  @ViewBuilder private func ListView(
    cities: [City],
    userCoordinate: Coordinate?
  ) -> some View {
    let padding: CGFloat = 12

    ZStack(alignment: .top) {
      Color.white
        .opacity(0.4)
        .frame(height: selectionHistoryHeight)

        .background(.ultraThinMaterial)
        .verticalGradientMaskWithPaddings(
          top: 0.5 * padding,
          bottom: padding
        )

      CitySelectionHistoryListView(
        selectedCityId: $selectedCityId,
        cities: cities,
        userCoordinate: userCoordinate,
        onRemoveCityId: { cityId in
          store.send(.delegate(.removeCityIdFromSelectionHistory(cityId)))
        }
      )
      .padding(.bottom, padding)
      .geometryGroup()
      .onGeometryChange(
        for: CGFloat.self,
        of: { $0.size.height },
        action: { value in
          selectionHistoryHeight = value
          store.$sharedData.withLock { $0.layout.selectionHistoryHeight = value }
        }
      )
    }
  }
}
