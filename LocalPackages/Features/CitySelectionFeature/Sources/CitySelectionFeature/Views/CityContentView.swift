//
//  CityContentView.swift
//  CitySelectionFeature
//
//  Created by Igor Nikolaev on 18.06.2025.
//

import SwiftUI
import Utility

struct CityContentView: View, Identifiable {
  private let city: City
  private let isSelected: Bool

  /// Identifiable
  nonisolated var id: Int { city.id }

  init(
    city: City,
    isSelected: Bool
  ) {
    self.city = city
    self.isSelected = isSelected
  }
  
  var body: some View {
    HStack {
      if isSelected {
        Image(systemName: "checkmark.circle.fill")
          .resizable()
          .aspectRatio(contentMode: .fit)
          .frame(maxWidth: 24, maxHeight: 24)
          .symbolRenderingMode(.palette)
          .foregroundStyle(Color.white, Color.citySelection)
      }
      
      TextView()
      
      Spacer()
    }
    .frame(minHeight: 24)
    .animation(.smooth, value: isSelected)
  }
  
  @ViewBuilder private func TextView() -> some View {
    VStack(
      alignment: .leading,
      spacing: 0,
      content: {
        Text(city.name)
          .fontWeight(fontWeight())
        
        if let subject = city.subject {
          Text(subject)
            .font(.footnote)
            .foregroundStyle(.secondary)
        }
      }
    )
  }
  
  private func fontWeight() -> Font.Weight {
    let result: Font.Weight
    switch city.size {
    case .big:
      result = .bold
    case .middle:
      result = .semibold
    case .small:
      result = .medium
    case .tiny:
      result = .regular
    }
    return result
  }
}


#Preview {
  struct ContentView: View {
    static let cities: [City] = [
      .moscow,
      .saintPetersburg,
      .blagoveshchensk
    ]
    
    @State private var isDarkTheme = false
    @State private var isSelected = false
    
    
    var body: some View {
      VStack {
        Toggle("isDarkTheme", isOn: $isDarkTheme)
        Toggle("isSelected", isOn: $isSelected)
        
        ScrollView {
          VStack(spacing: 2) {
            ForEach(ContentView.cities, id: \.id) { city in
              CityContentView(
                city: city,
                isSelected: isSelected
              )
              .border(Color.blue.opacity(0.15))
            }
          }
        }
        .scrollBounceBehavior(.basedOnSize, axes: .vertical)
      }
      .preferredColorScheme(isDarkTheme ? .dark : .light)
      .padding()
    }
  }
  
  return ContentView()
}
