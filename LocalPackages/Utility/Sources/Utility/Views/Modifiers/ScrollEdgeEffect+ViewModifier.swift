//
//  ScrollEdgeEffect+ViewModifier.swift
//  Utility
//
//  Created by Igor Nikolaev on 26.06.2025.
//

import SwiftUI

public enum EdgeEffect {
  public struct Configuration {
    let height: CGFloat
    let gradientColor: Color
    let thresholdLocation: CGFloat
    
    public init(
      height: CGFloat,
      gradientColor: Color = Color.gray.opacity(0.2),
      thresholdLocation: CGFloat = 0.2
    ) {
      self.height = height
      self.gradientColor = gradientColor
      self.thresholdLocation = thresholdLocation
    }
  }
  
  public struct ScrollConfiguration {
    let blurRadius: CGFloat
    
    let topEdgeConfiguration: Configuration
    let bottomEdgeConfiguration: Configuration
    
    public init(
      blurRadius: CGFloat = 3,
      topEdgeConfiguration: Configuration,
      bottomEdgeConfiguration: Configuration
    ) {
      self.blurRadius = blurRadius
      self.topEdgeConfiguration = topEdgeConfiguration
      self.bottomEdgeConfiguration = bottomEdgeConfiguration
    }
  }
}

public extension View {
  func edgeEffect(
    blurRadius: CGFloat,
    configuration: EdgeEffect.Configuration,
    isTop: Bool
  ) -> some View {
    modifier(
      EdgeEffectModifier(
        blurRadius: blurRadius,
        configuration: configuration,
        isTop: isTop
      )
    )
  }
  
  func scrollEdgeEffect(
    _ configuration: EdgeEffect.ScrollConfiguration
  ) -> some View {
    modifier(ScrollEdgeEffectModifier(configuration: configuration))
  }
}


struct EdgeEffectModifier: ViewModifier {
  let blurRadius: CGFloat
  let configuration: EdgeEffect.Configuration
  let isTop: Bool
  
  func body(content: Content) -> some View {
    content
      .overlay {
        EdgeEffectView(
          blurRadius: blurRadius,
          configuration: configuration,
          isTop: isTop
        )
        .frame(height: configuration.height)
        .allowsHitTesting(false)
      }
  }
}

struct ScrollEdgeEffectModifier: ViewModifier {
  let configuration: EdgeEffect.ScrollConfiguration
  
  func body(content: Content) -> some View {
    content
      .overlay {
        ScrollEdgeEffectView(configuration: configuration)
          .allowsHitTesting(false)
      }
  }
}

struct EdgeEffectView: View {
  private let blurRadius: CGFloat
  private let configuration: EdgeEffect.Configuration
  
  private let startPoint: UnitPoint
  private let endPoint: UnitPoint

  init(
    blurRadius: CGFloat,
    configuration: EdgeEffect.Configuration,
    isTop: Bool
  ) {
    self.blurRadius = blurRadius
    self.configuration = configuration
    
    if isTop {
      startPoint = .bottom
      endPoint = .top
    } else {
      startPoint = .top
      endPoint = .bottom
    }
  }
  
  var body: some View {
    BackdropBlurView(radius: 0)
      .blur(radius: blurRadius, opaque: true)
      .frame(height: configuration.height)
      .background(
        LinearGradient(
          colors: [.clear, configuration.gradientColor],
          startPoint: startPoint,
          endPoint: endPoint
        )
      )
      .mask {
        LinearGradient(
          stops: [
            .init(color: .clear, location: 0),
            .init(color: .black, location: configuration.thresholdLocation),
            .init(color: .black, location: 1),
          ],
          startPoint: startPoint,
          endPoint: endPoint
        )
      }
  }
}

struct ScrollEdgeEffectView: View {
  private let configuration: EdgeEffect.ScrollConfiguration
  
  init(configuration: EdgeEffect.ScrollConfiguration) {
    self.configuration = configuration
  }
  
  var body: some View {
    VStack(spacing: 0) {
      EdgeEffectView(
        blurRadius: configuration.blurRadius,
        configuration: configuration.topEdgeConfiguration,
        isTop: true
      )
      
      Spacer()
      
      EdgeEffectView(
        blurRadius: configuration.blurRadius,
        configuration: configuration.bottomEdgeConfiguration,
        isTop: false
      )
    }
  }
}
