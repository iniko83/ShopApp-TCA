//
//  Constants.swift
//  CitySelectionFeature
//
//  Created by Igor Nikolaev on 18.06.2025.
//

import SwiftUI
import Utility

extension Color {
  public static let citySelection = Color.dynamicRgbHex(dark: 0xe3546d, light: 0xf8395a)
}

/// Preview support
extension Coordinate {
  static let moscow = Coordinate(latitude: 37.620405, longitude: 55.7540471)
  static let saintPetersburg = Coordinate(latitude: 59.943646, longitude: 30.2851863)
  static let blagoveshchensk = Coordinate(latitude: 50.25778, longitude: 127.53639)
}

extension City {
  static let moscow = City(
    id: 0,
    name: "Москва",
    coordinate: .moscow,
    size: .big,
    subject: nil
  )
  
  static let saintPetersburg = City(
    id: 1,
    name: "Санкт-Петербург",
    coordinate: .saintPetersburg,
    size: .big,
    subject: nil
  )
  
  static let blagoveshchensk = City(
    id: 2,
    name: "Благовещенск",
    coordinate: Coordinate(latitude: 50.25778, longitude: 127.53639),
    size: .small,
    subject: "Амурская область"
  )
}
