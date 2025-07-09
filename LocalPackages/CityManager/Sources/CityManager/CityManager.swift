// The Swift Programming Language
// https://docs.swift.org/swift-book

import Dependencies
import Foundation

import Utility

public struct CityManager: Sendable {
  public var city: @MainActor @Sendable () -> City?
  public var cityStream: @Sendable () -> AsyncStream<City>
  
  public var changeCity: @MainActor @Sendable (City) -> Void
}

extension CityManager: DependencyKey {
  public static var liveValue: Self {
    storage(key: StorageKey.userCity)
  }
  
  public static var previewValue: Self {
    test
  }
  
  public static var testValue: Self {
    test
  }
  
  static var test: Self {
    memory(city: .moscow)
  }
  
  public static func memory(city: City? = nil) -> Self {
    let service = CityMemoryService(city: city)
    
    return .init(
      city: { service.city },
      cityStream: service.stream,
      changeCity: { city in service.city = city }
    )
  }
  
  public static func storage(key: String) -> Self {
    let service = CityStorageService(storageKey: key)
    
    return .init(
      city: { service.city },
      cityStream: service.stream,
      changeCity: { city in service.city = city }
    )
  }
}

extension DependencyValues {
  public var cityManager: CityManager {
    get { self[CityManager.self] }
    set { self[CityManager.self] = newValue }
  }
}
