//
//  CitySelectionListData.swift
//  CitySelectionFeature
//
//  Created by Igor Nikolaev on 11.07.2025.
//

import Foundation
import Utility

struct CitySelectionListData: Equatable {
  var isFoundNothing: Bool
  var sections: [ListSection]

  var searchQuery: String // used only for equatable

  // ignored in equatable
  var allCities: [City]

  init(
    isFoundNothing: Bool = false,
    sections: [ListSection] = [],
    searchQuery: String = .empty,
    allCities: [City] = []
  ) {
    self.isFoundNothing = isFoundNothing
    self.sections = sections
    self.searchQuery = searchQuery
    self.allCities = allCities
  }

  func cities(ids: [Int]) -> [City] {
    ids.compactMap { allCities[safe: $0] }
  }

  static func == (lhs: CitySelectionListData, rhs: CitySelectionListData) -> Bool {
    lhs.searchQuery == rhs.searchQuery
  }
}

extension CitySelectionListData {
  mutating func applyResponse(_ response: CitySearchResponse) {
    isFoundNothing = response.isFoundNothing()
    sections = response.result.listSections
    searchQuery = response.query
  }
}
