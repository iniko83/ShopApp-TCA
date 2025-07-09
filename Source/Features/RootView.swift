//
//  RootView.swift
//  ShopApp
//
//  Created by Igor Nikolaev on 14.06.2025.
//

/* NOTE:
 While application trying support Swift6, most libraries (include TCA) still don't have full support yet,
 so during this period code sometimes will looks ugly in places of initialization / configuration.
*/

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
