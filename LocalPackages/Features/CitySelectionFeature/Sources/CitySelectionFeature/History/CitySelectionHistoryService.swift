//
//  CitySelectionHistoryService.swift
//  CitySelectionFeature
//
//  Created by Igor Nikolaev on 07.07.2025.
//

import Foundation
import os.lock

import Utility

enum CitySelectionHistoryService {
  struct ProtectedData {
    var continuationsByIds = [UUID: AsyncStream<[Int]>.Continuation]()
  }
}

final class CitySelectionHistoryStorageService: @unchecked Sendable {
  private var cityIdsList: LimitedFifoList<Int>
  
  @UserDefaultCodable(key: StorageKey.userCityIdsSelectionHistory)
  private var storedCityIds: [Int]
  
  private let lockedData = OSAllocatedUnfairLock(
    initialState: CitySelectionHistoryService.ProtectedData()
  )
  
  init(cityIdsLimit: Int = .cityIdsLimit) {
    cityIdsList = .init(limit: cityIdsLimit)
    
    // self was initialized, replace empty values with stored
    cityIdsList = .init(
      items: storedCityIds,
      limit: cityIdsLimit
    )
  }
  
  @MainActor
  func appendCityId(_ id: Int) {
    let oldIds = cityIds()
    cityIdsList.insertItem(id)
    
    let ids = cityIds()
    guard oldIds != ids else { return }
    onChangeCityIds(ids)
  }
  
  @MainActor
  func cityIds() -> [Int] {
    cityIdsList.items
  }
  
  func cityIdsStream() -> AsyncStream<[Int]> {
    AsyncStream(bufferingPolicy: .bufferingNewest(1)) { continuation in
      let id = UUID()
      
      lockedData.withLock { data in
        data.continuationsByIds[id] = continuation
      }
      
      continuation.onTermination = { [mutex = lockedData] _ in
        mutex.withLock { data in
          data.continuationsByIds[id] = nil
        }
      }
    }
  }
  
  @MainActor
  func removeCityId(_ id: Int) {
    cityIdsList.removeItem(id)
    let ids = cityIdsList.items
    onChangeCityIds(ids)
  }
  
  @MainActor
  func reset() {
    cityIdsList.removeAll()
    onChangeCityIds([])
  }
  
  @MainActor
  private func onChangeCityIds(_ ids: [Int]) {
    // store
    storedCityIds = ids
    
    // notify subscribers
    Task.detached {
      self.lockedData.withLock { data in
        for (_, continuation) in data.continuationsByIds {
          continuation.yield(ids)
        }
      }
    }
  }
}

final class CitySelectionHistoryMemoryService: @unchecked Sendable {
  private var cityIdsList: LimitedFifoList<Int>
  
  private let lockedData = OSAllocatedUnfairLock(
    initialState: CitySelectionHistoryService.ProtectedData()
  )
  
  init(
    cityIds: [Int] = [],
    cityIdsLimit: Int = .cityIdsLimit
  ) {
    cityIdsList = .init(
      items: cityIds,
      limit: cityIdsLimit
    )
  }
  
  @MainActor
  func appendCityId(_ id: Int) {
    let oldIds = cityIds()
    cityIdsList.insertItem(id)
    
    let ids = cityIds()
    guard oldIds != ids else { return }
    onChangeCityIds(ids)
  }
  
  @MainActor
  func cityIds() -> [Int] {
    cityIdsList.items
  }
  
  func cityIdsStream() -> AsyncStream<[Int]> {
    AsyncStream(bufferingPolicy: .bufferingNewest(1)) { continuation in
      let id = UUID()
      
      lockedData.withLock { data in
        data.continuationsByIds[id] = continuation
      }
      
      continuation.onTermination = { [mutex = lockedData] _ in
        mutex.withLock { data in
          data.continuationsByIds[id] = nil
        }
      }
    }
  }
  
  @MainActor
  func removeCityId(_ id: Int) {
    cityIdsList.removeItem(id)
    let ids = cityIdsList.items
    onChangeCityIds(ids)
  }
  
  @MainActor
  func reset() {
    cityIdsList.removeAll()
    onChangeCityIds([])
  }
  
  @MainActor
  private func onChangeCityIds(_ ids: [Int]) {
    // notify subscribers
    Task.detached {
      self.lockedData.withLock { data in
        for (_, continuation) in data.continuationsByIds {
          continuation.yield(ids)
        }
      }
    }
  }
}


/// Constants
private extension Int {
  static let cityIdsLimit = 4
}
