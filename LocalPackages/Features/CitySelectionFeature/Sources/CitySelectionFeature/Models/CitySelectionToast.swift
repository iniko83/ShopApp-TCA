//
//  CitySelectionToast.swift
//  CitySelectionFeature
//
//  Created by Igor Nikolaev on 01.07.2025.
//

import Foundation

struct CitySelectionToast: Equatable {
  let item: CitySelectionToastItem
  let timeoutStamp: TimeInterval?
  
  init(
    item: CitySelectionToastItem,
    timeoutStamp: TimeInterval? = nil
  ) {
    self.item = item
    self.timeoutStamp = timeoutStamp
  }
}

public enum CitySelectionToastItem: Hashable {
  case citySelectionRequired
  case nearestCityFetchFailure
}
