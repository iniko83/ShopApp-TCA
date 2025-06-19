//
//  CLAuthorizationStatus+Extensions.swift
//  Utility
//
//  Created by Igor Nikolaev on 18.06.2025.
//

import CoreLocation

extension CLAuthorizationStatus {
  public var isAuthorized: Bool {
    self == .authorizedWhenInUse || self == .authorizedAlways
  }
  
  public var isDenied: Bool {
    self == .denied || self == .restricted
  }
}
