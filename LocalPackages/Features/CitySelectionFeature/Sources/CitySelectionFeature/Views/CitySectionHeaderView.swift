//
//  CitySectionHeaderView.swift
//  CitySelectionFeature
//
//  Created by Igor Nikolaev on 24.06.2025.
//

import SwiftUI

// Based on: https://www.reddit.com/r/iOSProgramming/comments/1ejoppj/cool_swiftui_gradient_that_users_love/

struct CitySectionHeaderView: View {
  private let text: String
  
  init(kind: CityTableSection.Kind) {
    text = kind.headerTitle()
  }
  
  var body: some View {
    if text.isEmpty {
      Color.clear
        .frame(height: .zero)
    } else {
      Text(text)
        .fontWeight(.medium)
        .foregroundStyle(.black.opacity(0.8))
        .multilineTextAlignment(.trailing)
        .frame(maxWidth: .infinity, alignment: .trailing)
        .padding(EdgeInsets(horizontal: 16, vertical: 4))
        .background(
          GradientBackgroundView()
        )
    }
  }
}

struct GradientBackgroundView: View {
  var body: some View {
    ZStack {
      let stops: [Gradient.Stop] = [
        .init(color: .mainAccent.opacity(0.4), location: 0),
        .init(color: .clear, location: 0.9),
        .init(color: .clear, location: 1)
      ]
      let endRadius = 0.7 * UIScreen.main.bounds.size.minSide()
      
      RadialGradient(
        stops: stops,
        center: .bottomTrailing,
        startRadius: 5,
        endRadius: endRadius
      )
    }
  }
}

private extension CityTableSection.Kind {
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
    
    GradientBackgroundView()
      .frame(height: 200)
      .background(.blue.opacity(0.2))
      .border(Color.blue.opacity(0.2))
    
    Spacer()
  }
  .padding()
  .ignoresSafeArea(.all)
}
