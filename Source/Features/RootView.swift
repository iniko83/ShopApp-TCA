//
//  RootView.swift
//  ShopApp
//
//  Created by Igor Nikolaev on 14.06.2025.
//

import ComposableArchitecture
import SwiftUI

import CitySelectionFeature

struct RootView: View {
  var body: some View {
    CitySelectionFeatureView()
  }
  
  @ViewBuilder private func StubView() -> some View {
    Text("Root")
  }
  
  // FIXME: debug purpose
  @ViewBuilder private func CitySelectionFeatureView() -> some View {
    CitySelectionView(
      store: Store(
        initialState: CitySelectionFeature.State(),
        reducer: { CitySelectionFeature() }
      )
    )
  }
}

#Preview {
  RootView()
}
