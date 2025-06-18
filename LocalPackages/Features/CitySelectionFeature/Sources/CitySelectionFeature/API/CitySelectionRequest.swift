//
//  CitySelectionRequest.swift
//  CitySelectionFeature
//
//  Created by Igor Nikolaev on 18.06.2025.
//

import RestClient

enum CitySelectionRequest {
  case cities
}

extension CitySelectionRequest: RestRequestConvertible {
  func restRequest() -> RestRequest {
    let result: RestRequest
    switch self {
    case .cities:
      // FIXME: insert path from github
      result = .init(path: "/path")
    }
    return result
  }
}
