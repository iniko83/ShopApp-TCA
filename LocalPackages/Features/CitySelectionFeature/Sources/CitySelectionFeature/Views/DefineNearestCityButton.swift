//
//  DefineNearestCityButton.swift
//  CitySelectionFeature
//
//  Created by Igor Nikolaev on 19.06.2025.
//

import SwiftUI
import Utility

struct DefineNearestCityButton: View {
  private let isProcessing: Bool
  private let action: () -> Void
  
  init(
    isProcessing: Bool,
    action: @escaping () -> Void
  ) {
    self.isProcessing = isProcessing
    self.action = action
  }
  
  var body: some View {
    Button(action: action) {
      Text("Определить ближайший город")
        .multilineTextAlignment(.center)
        .opacity(isProcessing ? 0.8 : 1)
        .blur(radius: isProcessing ? 5 : 0)
        .shimmering(
          isActive: !isProcessing,
          animation: Shimmer.animation(delay: 4),
          gradient: Shimmer.gradient(opacity: 0.7)
        )
    }
    .buttonStyle(
      MainButtonStyle(style: .blue, shape: .capsule)
    )
    .overlay {
      ActivityView(style: .spinner())
        .tint(.white)
        .frame(maxHeight: 40)
        .padding(6)
        .opacity(isProcessing ? 1 : 0)
    }
    .animation(.smooth, value: isProcessing)
    .allowsHitTesting(!isProcessing)
    .preventPassthoughTouches()
  }
}


#Preview {
  @Previewable @State var isProcessing = false
  
  VStack {
    Toggle("isProcessing", isOn: $isProcessing)
    
    DefineNearestCityButton(isProcessing: isProcessing) {
      isProcessing = true
    }
  }
  .padding()
}
