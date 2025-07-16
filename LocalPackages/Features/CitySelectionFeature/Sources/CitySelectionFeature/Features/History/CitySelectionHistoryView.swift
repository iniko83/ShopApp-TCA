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

  @State private var animated = false

  public init(store: StoreOf<CitySelectionHistoryFeature>) {
    self.store = store
  }

  public var body: some View {
    let layout = store.state.sharedData.layout

    let height = layout.searchFieldFrames.content.height
    let historyHeight = layout.selectionHistoryHeight
    let isListVisible = store.state.isCitiesVisible()

    VStack(spacing: 0) {
      Spacer()
        .frame(height: height)

      if isListVisible {
        ListView()
          .transition(.opacity.combined(with: .move(edge: .top)))
      }

      Spacer()
    }
    .frame(maxWidth: .infinity)
    .verticalGradientMaskWithPaddings(top: height)
    .if(animated) { content in
      content
        .animation(.smooth, value: historyHeight)
        .animation(.smooth, value: isListVisible)
        .animation(.smooth, value: height)
    }
    .onAppear { animated = true }
  }

  @ViewBuilder private func ListView() -> some View {
    let historyHeight = store.state.sharedData.layout.selectionHistoryHeight
    let padding: CGFloat = 12

    ZStack(alignment: .top) {
      Color.white
        .opacity(0.4)
        .frame(height: historyHeight)

        .background(.ultraThinMaterial)
        .verticalGradientMaskWithPaddings(
          top: 0.5 * padding,
          bottom: padding
        )

      CitySelectionHistoryListView(
        selectedCityId: bindingSelectedCityId(),
        cities: store.state.cities,
        userCoordinate: store.state.sharedData.locationRelated.userCoordinate,
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
          guard historyHeight != value else { return }
          store.send(.delegate(.changeSelectionHistoryHeight(value)))
        }
      )
    }
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
}
