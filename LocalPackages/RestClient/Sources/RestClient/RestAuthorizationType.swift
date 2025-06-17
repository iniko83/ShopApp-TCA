//
//  RestAuthorizationType.swift
//  RestClient
//
//  Created by Igor Nikolaev on 17.06.2025.
//

import Foundation

public enum RestAuthorizationType: Int {
  case bearer
  
  public init() {
    self = .bearer
  }
  
  func authorizeRequest(_ request: inout URLRequest, token: String) {
    request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
  }
}
