//
//  LocationServiceError.swift
//  LocationService
//
//  Created by Igor Nikolaev on 14.06.2025.
//

import CoreLocation

public enum LocationServiceError: Error {
  case unauthorized(status: CLAuthorizationStatus)
  case unknown(error: Error?)
}

extension LocationServiceError: Equatable {
  public static func == (lhs: LocationServiceError, rhs: LocationServiceError) -> Bool {
    let result: Bool
    switch (lhs, rhs) {
    case let (.unauthorized(leftStatus), .unauthorized(rightStatus)):
      result = leftStatus.rawValue == rightStatus.rawValue
    default:
      result = false
    }
    return result
  }
}
