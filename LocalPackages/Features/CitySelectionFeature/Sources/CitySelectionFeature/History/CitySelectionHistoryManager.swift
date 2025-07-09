//
//  CitySelectionHistoryManager.swift
//  CitySelectionFeature
//
//  Created by Igor Nikolaev on 07.07.2025.
//

// NOTE: Similar to CityManager

import Dependencies
import Foundation

struct CitySelectionHistoryManager: Sendable {
  var ids: @MainActor @Sendable () -> [Int]
  var idsStream: @Sendable () -> AsyncStream<[Int]>
  
  var insertId: @MainActor @Sendable (Int) -> Void
  var reset: @MainActor @Sendable () -> Void
}

extension CitySelectionHistoryManager: DependencyKey {
  static var liveValue: Self {
    storage
  }
  
  static var previewValue: Self {
    test
  }
  
  static var testValue: Self {
    test
  }
  
  static var test: Self {
    memory(
      cityIds: [
        0,  // moscow
        1   // saintPetersburg
      ]
    )
  }
  
  static var storage: Self {
    let service = CitySelectionHistoryStorageService()
    
    return .init(
      ids: service.cityIds,
      idsStream: service.cityIdsStream,
      insertId: { id in service.appendCityId(id) },
      reset: service.reset
    )
  }
  
  static func memory(cityIds: [Int] = []) -> Self {
    let service = CitySelectionHistoryMemoryService(cityIds: cityIds)
    
    return .init(
      ids: service.cityIds,
      idsStream: service.cityIdsStream,
      insertId: { id in service.appendCityId(id) },
      reset: service.reset
    )
  }
}

extension DependencyValues {
  var citySelectionHistoryManager: CitySelectionHistoryManager {
    get { self[CitySelectionHistoryManager.self] }
    set { self[CitySelectionHistoryManager.self] = newValue }
  }
}
