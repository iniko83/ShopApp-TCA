//
//  ActivityBallRotateChaseView.swift
//  Utility
//
//  Created by Igor Nikolaev on 14.06.2025.
//

import SwiftUI

/* Inspired by:
 https://github.com/ninjaprox/NVActivityIndicatorView
 https://stackoverflow.com/a/59171234
 */

struct ActivityBallRotateChaseView: View {
  @State private var isAnimating = false
  
  var body: some View {
    GeometryReader { geometry in
      let side = geometry.size.minSide()
      let itemSide = 0.2 * side
      
      let shiftFactor: CGFloat = -19/45
      let elementOffsetY = shiftFactor * side
      let finalOffsetY = -(shiftFactor + 0.4) * side
      
      let padding = EdgeInsets(
        horizontal: 0.5 * (geometry.size.width - side),
        vertical: 0.5 * (geometry.size.height - side)
      )
    
      Group {
        ForEach(0 ..< 5) { index in
          let itemAnimation = Animation
            .timingCurve(0.5, 0.15 + 0.2 * Double(index), 0.25, 1, duration: 1.7)
            .repeatForever(autoreverses: false)
          
          Group {
            Circle()
              .fill(.tint)
              .frame(square: itemSide)
              .scaleEffect(calculateScale(index: index))
              .offset(y: elementOffsetY)
          }
          .frame(square: side)
          .rotationEffect(.degrees(isAnimating ? 360 : 0))
          .animation(itemAnimation, value: isAnimating)
        }
        .offset(y: finalOffsetY)
      }
      .padding(padding)
    }
    .drawingGroup()
    .onAppear { isAnimating = true }
  }
  
  private func calculateScale(index: Int) -> CGFloat {
    isAnimating
      ? 0.2 * CGFloat(1 + index)
      : 1 - 0.2 * CGFloat(index)
  }
}


#Preview {
  ActivityBallRotateChaseView()
    .tint(.red)
    .opacity(0.5)
    .background(.blue.opacity(0.2).gradient)
    .frame(square: 240)
}
