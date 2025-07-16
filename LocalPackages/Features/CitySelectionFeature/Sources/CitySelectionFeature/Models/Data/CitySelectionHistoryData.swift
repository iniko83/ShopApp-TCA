//
//  CitySelectionHistoryData.swift
//  CitySelectionFeature
//
//  Created by Igor Nikolaev on 16.07.2025.
//

import Foundation
import Utility

struct CitySelectionHistoryData: Equatable {
  var cities: [City]

  init(cities: [City] = []) {
    self.cities = cities
  }

  func isVisible() -> Bool {
    !cities.isEmpty
  }
}
