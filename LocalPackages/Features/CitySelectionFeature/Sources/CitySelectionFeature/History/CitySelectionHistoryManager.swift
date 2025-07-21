//
//  CitySelectionHistoryManager.swift
//  CitySelectionFeature
//
//  Created by Igor Nikolaev on 07.07.2025.
//

// Similar to CityManager

import Dependencies
import Foundation

struct CitySelectionHistoryManager: Sendable {
  let ids: @MainActor @Sendable () -> [Int]
  let idsStream: @Sendable () -> AsyncStream<[Int]>
  let performAction: @MainActor @Sendable (CitySelectionHistoryService.Action) -> Void
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
      performAction: { action in service.performAction(action) }
    )
  }
  
  static func memory(cityIds: [Int] = []) -> Self {
    let service = CitySelectionHistoryMemoryService(cityIds: cityIds)
    
    return .init(
      ids: service.cityIds,
      idsStream: service.cityIdsStream,
      performAction: { action in service.performAction(action) }
    )
  }
}

extension DependencyValues {
  var citySelectionHistoryManager: CitySelectionHistoryManager {
    get { self[CitySelectionHistoryManager.self] }
    set { self[CitySelectionHistoryManager.self] = newValue }
  }
}
