//
//  CitySelectionLocationRelatedData.swift
//  CitySelectionFeature
//
//  Created by Igor Nikolaev on 11.07.2025.
//

import Foundation
import Utility

struct CitySelectionLocationRelatedData: Equatable {
  var nearestCity: City? {
    didSet { updateNearestCityRequestState() }
  }
  // dependent by userCoordinateRequestState & nearestCity
  private(set) var nearestCityRequestState = RequestLocationState()

  var userCoordinate: Coordinate?
  var userCoordinateRequestState = RequestLocationState() {
    didSet { updateNearestCityRequestState() }
  }

  mutating private func updateNearestCityRequestState() {
    let value: RequestLocationState
    switch userCoordinateRequestState {
    case .default:
      value = nearestCity == nil ? .processing : .default
    case .processing:
      value = .processing
    case let .error(error):
      value = .error(error)
    }
    nearestCityRequestState = value
  }

  /// Equatable
  static func == (
    lhs: CitySelectionLocationRelatedData,
    rhs: CitySelectionLocationRelatedData
  ) -> Bool {
    lhs.nearestCity == rhs.nearestCity
    && lhs.userCoordinate == rhs.userCoordinate
    && lhs.userCoordinateRequestState == rhs.userCoordinateRequestState
  }
}
