//
//  CityService.swift
//  CityManager
//
//  Created by Igor Nikolaev on 04.07.2025.
//

import Foundation
import os.lock

import Utility

enum CityService {
  struct ProtectedData {
    var continuationsByIds = [UUID: AsyncStream<City>.Continuation]()
  }
}

final class CityStorageService: @unchecked Sendable {
  @MainActor
  var city: City? {
    didSet {
      guard let city, oldValue != city else { return }
      onChangeCity(city)
    }
  }
  
  private let storage: UserDefaults
  private let storageKey: String
  
  private let lockedData = OSAllocatedUnfairLock(initialState: CityService.ProtectedData())
  
  init(
    storage: UserDefaults = .standard,
    storageKey: String
  ) {
    city = storage.value(forKey: storageKey)
    
    self.storage = storage
    self.storageKey = storageKey
  }
  
  func stream() -> AsyncStream<City> {
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
  private func onChangeCity(_ city: City) {
    storage.setValue(city, forKey: storageKey)
    
    Task.detached {
      self.notifySubscribers(city: city)
    }
  }
  
  private func notifySubscribers(city: City) {
    lockedData.withLock { data in
      for (_, continuation) in data.continuationsByIds {
        continuation.yield(city)
      }
    }
  }
}

final class CityMemoryService: @unchecked Sendable {
  @MainActor
  var city: City? {
    didSet {
      guard let city, city != oldValue else { return }
      
      Task.detached {
        self.notifySubscribers(city: city)
      }
    }
  }
  
  private let lockedData = OSAllocatedUnfairLock(initialState: CityService.ProtectedData())
  
  init(city: City? = nil) {
    self.city = city
  }
  
  func stream() -> AsyncStream<City> {
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
  
  private func notifySubscribers(city: City) {
    lockedData.withLock { data in
      for (_, continuation) in data.continuationsByIds {
        continuation.yield(city)
      }
    }
  }
}
