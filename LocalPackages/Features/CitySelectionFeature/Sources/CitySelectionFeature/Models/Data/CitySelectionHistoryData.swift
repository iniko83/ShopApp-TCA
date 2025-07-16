//
//  CitySelectionHistoryData.swift
//  CitySelectionFeature
//
//  Created by Igor Nikolaev on 16.07.2025.
//

import Foundation
import Utility

struct CitySelectionHistoryData: Equatable {
  var cityIds: [Int]

  // ignored in equatable
  var allCities: [City]

  var isVisible: Bool { !cityIds.isEmpty }

  init(
    cityIds: [Int] = [],
    allCities: [City] = []
  ) {
    self.cityIds = cityIds
    self.allCities = allCities
  }

  func cities() -> [City] {
    cityIds.compactMap { allCities[safe: $0] }
  }

  /// Equatable
  static func == (lhs: CitySelectionHistoryData, rhs: CitySelectionHistoryData) -> Bool {
    lhs.cityIds == rhs.cityIds
  }
}
