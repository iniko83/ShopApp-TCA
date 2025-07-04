//
//  ActivitySpinnerView.swift
//  Utility
//
//  Created by Igor Nikolaev on 14.06.2025.
//

import SwiftUI

// Inspired by: [ https://youtu.be/K3wvbZ2gh5o ]

extension ActivitySpinnerView {
  typealias Configuration = Activity.SpinnerConfiguration
}

struct ActivitySpinnerView: View {
  @State private var isAnimated = false

  @State private var rotation: Double = 0
  @State private var extraRotation: Double = 0
  
  let configuration: Configuration
  
  init(configuration: Configuration) {
    self.configuration = configuration
  }
  
  var body: some View {
    GeometryReader { geometry in
      let opacity = configuration.trackOpacity
      
      let side = geometry.size.minSide()
      let lineWidth = configuration.thickness * side
      let circleSide = side - lineWidth
      let paddingSide = 0.5 * lineWidth
      let padding = EdgeInsets(
        horizontal: 0.5 * (geometry.size.width - side) + paddingSide,
        vertical: 0.5 * (geometry.size.height - side) + paddingSide
      )
      
      ZStack {
        Circle()
          .stroke(.tint.opacity(opacity), style: .init(lineWidth: lineWidth))
        
        Circle()
          .trim(from: 0, to: 0.3)
          .stroke(.tint, style: .init(lineWidth: lineWidth, lineCap: .round, lineJoin: .round))
          .rotationEffect(.degrees(isAnimated ? 360 : 0))
          .animation(.linear(duration: 0.7).speed(1.2).repeatForever(autoreverses: false), value: isAnimated)
          .rotationEffect(.degrees(isAnimated ? 360 : 0))
          .animation(.linear(duration: 1).speed(1.2).delay(1).repeatForever(autoreverses: false), value: isAnimated)
      }
      .frame(square: circleSide)
      .compositingGroup()
      .padding(padding)
    }
    .onAppear { isAnimated = true }
  }
}


#Preview {
  ActivitySpinnerView(configuration: .init(thickness: 0.125, trackOpacity: 0.2))
    .tint(.red)
    .opacity(0.5)
    .background(.blue.opacity(0.2).gradient)
    .frame(square: 240)
}
