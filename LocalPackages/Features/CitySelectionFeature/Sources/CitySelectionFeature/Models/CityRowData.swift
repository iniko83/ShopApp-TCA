//
//  CityRowData.swift
//  CitySelectionFeature
//
//  Created by Igor Nikolaev on 21.06.2025.
//

import Foundation
import Utility

struct CityRowData: Equatable, Identifiable {
  let city: City
  let isSelected: Bool
  let userCoordinate: Coordinate?
  
  /// Identifiable
  var id: Int { city.id }
}
