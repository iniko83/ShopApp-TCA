//
//  CitySelectionToast.swift
//  CitySelectionFeature
//
//  Created by Igor Nikolaev on 01.07.2025.
//

import Foundation
import Utility

struct CitySelectionToast: Equatable, Identifiable {
  let item: CitySelectionToastItem
  let timeoutStamp: TimeInterval?

  /// Identifiable
  var id: Int { item.id }

  init(
    item: CitySelectionToastItem,
    timeoutStamp: TimeInterval? = nil
  ) {
    self.item = item
    self.timeoutStamp = timeoutStamp
  }
}

public enum CitySelectionToastItem {
  case citySelectionRequired
  case nearestCityFetchFailure
  case undoRemoveSelectionHistoryCity(City)

  public func timeout() -> TimeInterval? {
    let result: TimeInterval?
    switch self {
    case .citySelectionRequired:
      result = nil
    case .nearestCityFetchFailure:
      result = .warningTimeout
    case .undoRemoveSelectionHistoryCity:
      result = .undoTimeout
    }
    return result
  }
}

extension CitySelectionToastItem: Hashable {
  public func hash(into hasher: inout Hasher) {
    hasher.combine(id)
  }
}

extension CitySelectionToastItem: Identifiable {
  public var id: Int {
    let result: Int
    switch self {
    case .citySelectionRequired:
      result = -2
    case .nearestCityFetchFailure:
      result = -1
    case let .undoRemoveSelectionHistoryCity(city):
      result = city.id
    }
    return result
  }
}
