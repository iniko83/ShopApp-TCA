//
//  RequestState.swift
//  Utility
//
//  Created by Igor Nikolaev on 17.06.2025.
//

import NetworkClient

public enum RequestState: Equatable {
  case `default`
  case loading
  case error(RequestError)
  
  public init() {
    self = .default
  }
  
  public func isRetryableError() -> Bool {
    guard case let .error(error) = self else { return false }
    return error.isRetryable()
  }
}

public enum RequestListState: Equatable {
  case `default`
  case loading
  case empty
  case error(RequestError)
  
  public init() {
    self = .default
  }
}
