//
//  CityToast.swift
//  CitySelectionFeature
//
//  Created by Igor Nikolaev on 01.07.2025.
//

import Foundation

public enum CityToastItem: Hashable {
  case citySelectionRequired
  case nearestCityFetchFailure
}

struct CityToast: Equatable {
  let item: CityToastItem
  let timeoutStamp: TimeInterval?
  
  init(
    item: CityToastItem,
    timeoutStamp: TimeInterval? = nil
  ) {
    self.item = item
    self.timeoutStamp = timeoutStamp
  }
}
