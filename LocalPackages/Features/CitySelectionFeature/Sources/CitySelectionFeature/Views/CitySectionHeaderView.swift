//
//  CitySectionHeaderView.swift
//  CitySelectionFeature
//
//  Created by Igor Nikolaev on 24.06.2025.
//

import SwiftUI

// Based on: [ https://www.reddit.com/r/iOSProgramming/comments/1ejoppj/cool_swiftui_gradient_that_users_love/ ]

struct CitySectionHeaderView: View {
  let text: String
  let isLeading: Bool
  let gradientColor: Color
  
  init(
    text: String,
    isLeading: Bool = false,
    gradientColor: Color = .mainAccent
  ) {
    self.text = text
    self.isLeading = isLeading
    self.gradientColor = gradientColor
  }
  
  init(kind: ListSection.Kind) {
    let text = kind.headerTitle()
    self.init(text: text)
  }
  
  var body: some View {
    if text.isEmpty {
      Color.clear
        .frame(height: .zero)
    } else {
      let alignment: Alignment = isLeading ? .leading : .trailing
      let textAlignment: TextAlignment = isLeading ? .leading : .trailing
      
      ZStack {
        Color.clear
          .background(.ultraThinMaterial)
          .mask(BackgroundView(isSemitransparent: false))
        
        Text(text)
          .fontWeight(.medium)
          .foregroundStyle(.black.opacity(0.8))
          .multilineTextAlignment(textAlignment)
          .frame(maxWidth: .infinity, alignment: alignment)
          .padding(EdgeInsets(horizontal: 16, vertical: 4))
          .background(BackgroundView(isSemitransparent: true))
      }
    }
  }
  
  @ViewBuilder private func BackgroundView(isSemitransparent: Bool) -> some View {
    let opacity: Double = isSemitransparent ? 0.4 : 1
    let color = gradientColor.opacity(opacity)
    let anchor: UnitPoint = isLeading ? .bottomLeading : .bottomTrailing
    
    GradientBackgroundView(
      color: color,
      anchor: anchor
    )
  }
}

struct GradientBackgroundView: View {
  let color: Color
  let anchor: UnitPoint
  
  init(
    color: Color = .mainAccent,
    anchor: UnitPoint = .bottomTrailing
  ) {
    self.color = color
    self.anchor = anchor
  }
  
  var body: some View {
    ZStack {
      let stops: [Gradient.Stop] = [
        .init(color: color, location: 0),
        .init(color: .clear, location: 0.9),
        .init(color: .clear, location: 1)
      ]
      let endRadius = 0.7 * UIScreen.main.bounds.size.minSide()
      
      RadialGradient(
        stops: stops,
        center: anchor,
        startRadius: 5,
        endRadius: endRadius
      )
    }
  }
}

private extension ListSection.Kind {
  func headerTitle() -> String {
    let result: String
    switch self {
    case let .combinedSizes(sizes):
      switch sizes {
      case .bigAndMiddle:
        result = "Крупные города"
      case .others:
        result = "Небольшие города"
      }
      
    case .bigCities:
      result = "Крупнейшие города"
    
    case .untitled:
      result = .empty
    }
    return result
  }
}


#Preview {
  VStack {
    Spacer()
    
    CitySectionHeaderView(kind: .bigCities)
      .border(Color.blue.opacity(0.1))
   
    GradientBackgroundView()
      .frame(height: 200)
      .border(Color.blue.opacity(0.1))
    
    GradientBackgroundView(anchor: .bottomLeading)
      .frame(height: 200)
      .background(.blue.opacity(0.2))
      .border(Color.blue.opacity(0.2))
    
    Spacer()
  }
  .padding()
  .ignoresSafeArea(.all)
}
