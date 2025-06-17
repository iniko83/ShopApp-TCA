//
//  RestClientError.swift
//  RestClient
//
//  Created by Igor Nikolaev on 17.06.2025.
//

import Foundation

public enum RestClientError: Error {
  case builder(BuilderErrorType)
  case statusCode(StatusCodeData)
}

extension RestClientError {
  public enum BuilderErrorType: Sendable {
    case unauthorized
    case wrongUrl
    
    public func isUnauthorized() -> Bool {
      self == .unauthorized
    }
  }
  
  public struct StatusCodeData: Sendable {
    public let code: Int
    public let data: Data?
  }
}
