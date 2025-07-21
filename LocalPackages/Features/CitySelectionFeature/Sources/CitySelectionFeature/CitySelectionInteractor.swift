//
//  CitySelectionInteractor.swift
//  CitySelectionFeature
//
//  Created by Igor Nikolaev on 08.07.2025.
//

/*
 Use Cases, or Model input/output in MVVM.
 For ease of setup, I created a separate structure.
 */

/* NOTE:
 In usual manner you write UseCases like:
    protocol FeatureUseCases: AnyObject {
      var selectedCityId: Int? { get }
 
      // or via reactive
 
      var selectedCityId: AnyPublisher<Int?, Never> { get }
    }
  
 In point-freeco Dependencies similar functionality would seen like this:
    struct FeatureUseCases: Sendable {
      let selectedCityId: @Sendable () -> Int?
    }
 
 Also they usually use asyncStreams instead publisher, making stream for each subscriber.
 It's not very flexible like reactive publishers.
 */

import Dependencies
import Foundation

import CityManager
import Utility

public struct CitySelectionInteractor: Sendable {
  // inputs
  public let selectedCityId: @MainActor @Sendable () -> Int?

  public let historyCityIds: @MainActor @Sendable () -> [Int]
  public let historyCityIdsStream: @Sendable () -> AsyncStream<[Int]>

  // outputs
  public let historyAction: @MainActor @Sendable (CitySelectionHistoryService.Action) -> Void
  public let selectCity: @MainActor @Sendable (City) -> Void
}

extension CitySelectionInteractor: DependencyKey {
  public static var liveValue: Self {
    storage(cityKey: StorageKey.userCity)
  }
  
  public static var previewValue: Self {
    test
  }
  
  public static var testValue: Self {
    test
  }
  
  static var test: Self {
    memory(
      selectedCity: .moscow,
      historyCityIds: [0, 1]
    )
  }
  
  static func memory(
    selectedCity: City? = nil,
    historyCityIds: [Int] = []
  ) -> Self {
    let cityService = CityManager.memory(city: selectedCity)
    let historyService = CitySelectionHistoryManager.memory(cityIds: historyCityIds)
    
    return .init(
      selectedCityId: { cityService.city()?.id },
      historyCityIds: historyService.ids,
      historyCityIdsStream: historyService.idsStream,
      historyAction: { action in historyService.performAction(action) },
      selectCity: { city in
        cityService.changeCity(city)
        historyService.performAction(.insertId(city.id))
      }
    )
  }
  
  public static func storage(cityKey: String) -> Self {
    let cityService = CityManager.storage(key: cityKey)
    let historyService = CitySelectionHistoryManager.storage
    
    return .init(
      selectedCityId: { cityService.city()?.id },
      historyCityIds: historyService.ids,
      historyCityIdsStream: historyService.idsStream,
      historyAction: { action in historyService.performAction(action) },
      selectCity: { city in
        cityService.changeCity(city)
        historyService.performAction(.insertId(city.id))
      }
    )
  }
}

extension DependencyValues {
  public var citySelectionInteractor: CitySelectionInteractor {
    get { self[CitySelectionInteractor.self] }
    set { self[CitySelectionInteractor.self] = newValue }
  }
}
