//
//  RequestLocationState.swift
//  Utility
//
//  Created by Igor Nikolaev on 18.06.2025.
//

import LocationService

@frozen public enum RequestLocationState: Equatable {
  case `default`
  case processing
  case error(LocationServiceError)
  
  public var isError: Bool {
    guard case .error = self else { return false }
    return true
  }
  
  public var isProcessing: Bool { self == .processing }
  
  public init() {
    self = .default
  }
}
