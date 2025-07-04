//
//  CitySelectionApi.swift
//  CitySelectionFeature
//
//  Created by Igor Nikolaev on 17.06.2025.
//

import Dependencies
import Foundation

import NetworkClient
import RestClient
import Utility

public struct CitySelectionApi: Sendable {
  public var loadCities: @Sendable () async -> RequestResult<[City]>
}

extension CitySelectionApi: DependencyKey {
  public static var liveValue: Self {
    online
  }
  
  public static var previewValue: Self {
    online
  }
  
  public static var testValue: Self {
    online
  }
  
  static var empty: Self {
    .init(
      loadCities: { .success([]) }
    )
  }
  
  static var offline: Self {
    .init(
      loadCities: { .failure(.connectionLost) }
    )
  }
  
  static var online: Self {
    let client = NetworkClient(
      authorizationToken: .constant(nil),
      client: RestClient(baseUrl: .baseUrl)
    )
    
    return .init(
      loadCities: {
        let citiesResult: RequestResult<Cities> = await client.request(CitySelectionRequest.cities)
        let result: RequestResult<[City]>
        switch citiesResult {
        case let .success(cities):
          result = .success(cities.list)
        case let .failure(error):
          result = .failure(error)
        }
        return result
      }
    )
  }
}

extension DependencyValues {
  public var citySelectionApi: CitySelectionApi {
    get { self[CitySelectionApi.self] }
    set { self[CitySelectionApi.self] = newValue }
  }
}


/// Constants
private extension URL {
  // NOTE: how get path to raw file: [ https://stackoverflow.com/a/78631033 ]
  static let baseUrl = URL(string: "https://raw.githubusercontent.com/iniko83/ShopApp/develop/ResourcesOnline")!
}
