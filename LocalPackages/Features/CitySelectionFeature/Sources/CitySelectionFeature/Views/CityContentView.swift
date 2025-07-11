//
//  CityContentView.swift
//  CitySelectionFeature
//
//  Created by Igor Nikolaev on 18.06.2025.
//

import SwiftUI
import Utility

struct CityContentView: View {
  let city: City
  let isSelected: Bool
  let distanceText: String?

  init(
    city: City,
    isSelected: Bool = false,
    userCoordinate: Coordinate? = nil
  ) {
    self.city = city
    self.isSelected = isSelected

    distanceText = Self.distanceText(from: city.coordinate, to: userCoordinate)
  }
  
  var body: some View {
    HStack {
      if isSelected {
        CheckmarkView()
      }
      
      DescriptionView()

      Spacer()
      
      if let distanceText {
        DistanceView(distanceText)
          .frame(minWidth: 68, alignment: .trailing)
          .layoutPriority(1)
      }
    }
    .frame(minHeight: 24)
    .geometryGroup()
    .animation(.smooth, value: distanceText)
    .allowsHitTesting(false)
  }

  @ViewBuilder private func CheckmarkView() -> some View {
    Image(systemName: "checkmark.circle.fill")
      .resizable()
      .aspectRatio(contentMode: .fit)
      .frame(maxSquare: 24)
      .symbolRenderingMode(.palette)
      .foregroundStyle(Color.white, Color.citySelection)
  }

  @ViewBuilder private func DistanceView(_ distanceText: String) -> some View {
    Text(distanceText)
      .font(.footnote)
      .foregroundStyle(Color.secondary)
  }

  @ViewBuilder private func DescriptionView() -> some View {
    VStack(alignment: .leading, spacing: 0) {
      Text(city.name)
        .fontWeight(fontWeight())

      if let subject = city.subject {
        Text(subject)
          .font(.footnote)
          .foregroundStyle(.secondary)
      }
    }
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

extension CityContentView {
  private static func distanceText(from: Coordinate, to: Coordinate?) -> String? {
    guard let to else { return nil }
    let distance = 0.001 * from.distance(to: to)
    let measurement = Measurement(value: distance, unit: UnitLength.kilometers)
    return measurementFormatter.string(from: measurement)
  }
  
  private static let measurementFormatter = {
    let result = MeasurementFormatter()
    result.locale = .russian
    result.numberFormatter.maximumFractionDigits = 0
    result.unitStyle = .short
    return result
  }()
}


#Preview {
  struct ContentView: View {
    @State private var isDarkTheme = false
    @State private var isSelected = false
    let cities: [City]

    var body: some View {
      VStack {
        Toggle("isDarkTheme", isOn: $isDarkTheme)
        Toggle("isSelected", isOn: $isSelected)
        
        ScrollView {
          VStack(spacing: 2) {
            ForEach(cities, id: \.id) { city in
              CityContentView(
                city: city,
                isSelected: isSelected
              )
              .border(Color.blue.opacity(0.15))
            }
          }
        }
        .scrollBounceBehavior(.basedOnSize, axes: .vertical)
        .animation(.rowSelection, value: isSelected)
      }
      .preferredColorScheme(isDarkTheme ? .dark : .light)
      .padding()
    }
  }

  let cities: [City] = [
    .moscow,
    .saintPetersburg,
    .blagoveshchensk
  ]
  return ContentView(cities: cities)
}
