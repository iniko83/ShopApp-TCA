//
//  HttpMethod.swift
//  RestClient
//
//  Created by Igor Nikolaev on 17.06.2025.
//

import Foundation

public enum HttpMethod {
  case get
  case post
  case put
  case delete
  case patch
  
  public func operation() -> String {
    let result: String
    switch self {
    case .get:
      result = "GET"
    case .post:
      result = "POST"
    case .put:
      result = "PUT"
    case .delete:
      result = "DELETE"
    case .patch:
      result = "PATCH"
    }
    return result
  }
}
