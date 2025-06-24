//
//  CitySectionHeaderView.swift
//  CitySelectionFeature
//
//  Created by Igor Nikolaev on 24.06.2025.
//

import SwiftUI

// FIXME: add gradient
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
        .foregroundStyle(.black.opacity(0.8))
        .multilineTextAlignment(.trailing)
        .frame(maxWidth: .infinity, alignment: .trailing)
        .padding(EdgeInsets(horizontal: 16, vertical: 4))
        .background(Color.gray.opacity(0.2))
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
