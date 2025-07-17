//
//  CitySelectionListFoundNothingView.swift
//  CitySelectionFeature
//
//  Created by Igor Nikolaev on 11.07.2025.
//

import SwiftUI
import Utility

struct CitySelectionListFoundNothingView: View {
  let onTap: () -> Void

  var body: some View {
    Button(
      action: onTap,
      label: {
        EmptyContentView(
          iconSystemName: "magnifyingglass",
          message: "Поиск не дал результатов"
        )
        .padding(.cityCell)
      }
    )
    .buttonStyle(.highlightingCell)
  }
}


#Preview {
  CitySelectionListFoundNothingView(onTap: {})
    .ignoresSafeArea()
}
