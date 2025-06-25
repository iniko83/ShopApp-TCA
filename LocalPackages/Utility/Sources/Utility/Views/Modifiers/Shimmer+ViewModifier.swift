//
//  Shimmer+ViewModifier.swift
//  Utility
//
//  Created by Igor Nikolaev on 25.06.2025.
//

// Based on: https://github.com/markiv/SwiftUI-Shimmer
// Include improvement: https://github.com/markiv/SwiftUI-Shimmer/pull/18

import SwiftUI

public enum Shimmer {
  public enum Mode {
    case mask
    case overlay(blendMode: BlendMode = .sourceAtop)
    case background
  }
  
  public static let defaultAnimation = animation()
  
  public static let defaultGradient: Gradient = gradient(opacity: 0.3)
  
  public static func animation(
    duration: TimeInterval = 1.5,
    delay: TimeInterval = 0.25
  ) -> Animation {
    Animation
    .linear(duration: duration)
    .delay(delay)
    .repeatForever(autoreverses: false)
  }
  
  public static func gradient(opacity: Double) -> Gradient {
    let opaque = Color.black
    let translucent = Color.black.opacity(opacity)
    return .init(colors: [translucent, opaque, translucent])
  }
}

struct ShimmerModifier: ViewModifier {
  @Environment(\.layoutDirection) private var layoutDirection
  
  @State private var isInitialState = true

  private let isActive: Bool
  private let animation: Animation
  private let gradient: Gradient
  private let mode: Shimmer.Mode
  private let min, max: CGFloat
  
  init(
    isActive: Bool = true,
    animation: Animation = Shimmer.defaultAnimation,
    gradient: Gradient = Shimmer.defaultGradient,
    bandSize: CGFloat = 0.3,
    mode: Shimmer.Mode = .mask
  ) {
    self.isActive = isActive
    self.animation = animation
    self.gradient = gradient
    self.mode = mode
    
    min = 0 - bandSize
    max = 1 + bandSize
  }
  
  private func startPoint() -> UnitPoint {
    let result: UnitPoint
    if layoutDirection == .rightToLeft {
      result = isInitialState ? .init(x: max, y: min) : .init(x: 0, y: 1)
    } else {
      result = isInitialState ? .init(x: min, y: min) : .init(x: 1, y: 1)
    }
    return result
  }
  
  private func endPoint() -> UnitPoint {
    let result: UnitPoint
    if layoutDirection == .rightToLeft {
      result = isInitialState ? .init(x: 1, y: 0) : .init(x: min, y: max)
    } else {
      result = isInitialState ? .init(x: 0, y: 0) : .init(x: max, y: max)
    }
    return result
  }
  
  func body(content: Content) -> some View {
    let animation: Animation = isActive
      ? self.animation
      : .linear(duration: 0)
    
    applyingGradient(to: content)
      .animation(animation, value: isInitialState)
      .onChange(of: isActive) { (_, newValue) in
        isInitialState = !newValue
      }
      .task {
        isInitialState = !isActive
      }
  }
  
  @ViewBuilder private func applyingGradient(to content: Content) -> some View {
    let gradient = LinearGradient(
      gradient: gradient,
      startPoint: startPoint(),
      endPoint: endPoint()
    )
    
    switch mode {
    case .mask:
      content.mask(gradient)
      
    case let .overlay(blendMode):
      content
        .overlay {
          gradient.blendMode(blendMode)
        }
        .mask(content)
      
    case .background:
      content.background(gradient)
    }
  }
}

public extension View {
  @ViewBuilder func shimmering(
    isActive: Bool = true,
    animation: Animation = Shimmer.defaultAnimation,
    gradient: Gradient = Shimmer.defaultGradient,
    bandSize: CGFloat = 0.3,
    mode: Shimmer.Mode = .mask
  ) -> some View {
    modifier(
      ShimmerModifier(
        isActive: isActive,
        animation: animation,
        gradient: gradient,
        bandSize: bandSize,
        mode: mode
      )
    )
  }
}


#Preview {
  @Previewable @State var isShimmering = true

  VStack {
    Toggle("isShimmering", isOn: $isShimmering)
    
    Group {
      Text("SwiftUI Shimmer").preferredColorScheme(.light)
      Text("SwiftUI Shimmer").preferredColorScheme(.dark)
      VStack(alignment: .leading) {
        Text("Loading...").font(.title)
        Text(String(repeating: "Shimmer", count: 12))
          .redacted(reason: .placeholder)
      }.frame(maxWidth: 200)
    }
    .shimmering(isActive: isShimmering)
    
    VStack(alignment: .leading) {
      Text("← Right-to-left layout direction").font(.body)
    }
    .font(.largeTitle)
    .shimmering(isActive: isShimmering)
    .environment(\.layoutDirection, .rightToLeft)
    
    Text("Custom Gradient Mode")
      .bold()
      .font(.title)
      .shimmering(
        isActive: isShimmering,
        gradient: Gradient(colors: [.clear, .orange, .white, .green, .clear]),
        bandSize: 0.5,
        mode: .overlay()
      )
  }
  .padding()
}
