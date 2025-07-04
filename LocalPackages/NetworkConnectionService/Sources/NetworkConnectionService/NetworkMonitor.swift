//
//  NetworkMonitor.swift
//  NetworkStatusObserver
//
//  Created by Igor Nikolaev on 20.06.2025.
//

import Foundation
import Network
import os.lock

final class NetworkMonitor: @unchecked Sendable {
  private let monitor = NWPathMonitor()
  private let monitorQueue = DispatchQueue(label: "ShopApp.NetworkMonitor")

  private var isMonitoring = false {
    didSet {
      guard isMonitoring != oldValue else { return }
      updateMonitoringState()
    }
  }
  
  private let lockedData = OSAllocatedUnfairLock(initialState: ProtectedData())
  
  deinit {
    isMonitoring = false
  }
  
  func connectionStream(types: Set<NetworkType>) -> AsyncStream<Bool> {
    AsyncStream(bufferingPolicy: .bufferingNewest(1)) { continuation in
      let id = UUID()
      let item = Item(
        continuation: continuation,
        types: types
      )
      
      let status = lockedData.withLock { data in
        data.appendItem(item, id: id)
        self.isMonitoring = data.isMonitoring()
        return data.status
      }
      
      continuation.onTermination = { [mutex = lockedData] _ in
        mutex.withLock { data in
          data.removeItem(id: id)
          self.isMonitoring = data.isMonitoring()
        }
      }
      
      if let status {
        let isConnected = status.isConnected(types)
        continuation.yield(isConnected)
      }
    }
  }

  private func updateMonitoringState() {
    if isMonitoring {
      monitor.pathUpdateHandler = { path in
        let status = NetworkStatus(path: path)
        self.receiveStatus(status)
      }
      monitor.start(queue: monitorQueue)
    } else {
      monitor.cancel()
      monitor.pathUpdateHandler = nil
    }
  }
  
  private func receiveStatus(_ status: NetworkStatus) {
    lockedData.withLock { data in
      data.status = status
      
      for (_, var item) in data.itemsByIds {
        let isConnected = status.isConnected(item.types)
        
        guard item.isConnected != isConnected else { continue }
        item.isConnected = isConnected
        
        item.continuation.yield(isConnected)
      }
    }
  }
}

private struct Item {
  let continuation: AsyncStream<Bool>.Continuation
  let types: Set<NetworkType>
  
  var isConnected: Bool?
}

private struct ProtectedData {
  var status: NetworkStatus?

  private(set) var itemsByIds = [UUID: Item]()

  func isMonitoring() -> Bool {
    itemsByIds.count > 0
  }
  
  mutating func appendItem(_ item: Item, id: UUID) {
    itemsByIds[id] = item
  }
  
  mutating func removeItem(id: UUID) {
    itemsByIds[id] = nil
    
    guard !itemsByIds.isEmpty else { return }
    status = nil
  }
}
