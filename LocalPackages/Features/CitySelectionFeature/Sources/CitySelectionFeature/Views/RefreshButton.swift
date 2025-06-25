//
//  RefreshButton.swift
//  CitySelectionFeature
//
//  Created by Igor Nikolaev on 19.06.2025.
//

import SwiftUI
import Utility

struct RefreshButton: View {
  private let isProcessing: Bool
  private let paddingPart: CGFloat

  private let action: () -> Void
  
  init(
    isProcessing: Bool,
    paddingPart: CGFloat = 0.3,
    action: @escaping () -> Void
  ) {
    self.isProcessing = isProcessing
    self.paddingPart = paddingPart
    self.action = action
  }
  
  var body: some View {
    Button(
      action: action,
      label: {
        GeometryReader { geometry in
          let side = geometry.size.minSide()
          let paddedSide = side * (1 - paddingPart)
          let horizontalPaddedSide = isProcessing
            ? paddedSide
            : min(side, paddedSide * .iconFactor)
          let padding = EdgeInsets(
            horizontal: 0.5 * (geometry.size.width - horizontalPaddedSide),
            vertical: 0.5 * (geometry.size.height - paddedSide)
          )
          
          ZStack(alignment: .center) {
            if isProcessing {
              ActivityView(style: .spinner())
                .padding(padding)
                .transition(.blurReplace.combined(with: .opacity))
            } else {
              Image(systemName: "arrow.trianglehead.2.clockwise.rotate.90")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .padding(padding)
                .transition(.blurReplace.combined(with: .opacity))
            }
          }
          .tint(.white)
          .animation(.smooth, value: isProcessing)
        }
      }
    )
    .buttonStyle(
      MainButtonStyle(style: .blue, contentPadding: .zero)
    )
    .allowsHitTesting(!isProcessing)
    .preventPassthoughTouches()
    .clipShape(.circle)
  }
}


/// Constants
private extension CGFloat {
  static let iconFactor: CGFloat = 140.0 / 117.0
}


#Preview {
  @Previewable @State var isProcessing = false
  
  VStack {
    Toggle("isProcessing", isOn: $isProcessing)
    
    RefreshButton(
      isProcessing: isProcessing,
      action: { isProcessing = true }
    )
    .frame(width: 300, height: 240)
    .border(.blue.opacity(0.15))
  }
  .padding()
}
