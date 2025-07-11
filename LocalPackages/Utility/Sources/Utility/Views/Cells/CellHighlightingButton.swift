//
//  CellHighlightingButton.swift
//  CitySelectionFeature
//
//  Created by Igor Nikolaev on 10.07.2025.
//

import SwiftUI

public struct CellHighlightingButton: View {
  let action: () -> Void

  public init(action: @escaping () -> Void) {
    self.action = action
  }

  public var body: some View {
    Button(
      action: action,
      label: { Color.clear }
    )
    .buttonStyle(.highlightingCell)
  }
}
