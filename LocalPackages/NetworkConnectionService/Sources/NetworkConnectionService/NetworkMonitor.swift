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
  private var status: NetworkStatus?
  
  private let monitor = NWPathMonitor()
  private let monitorQueue = DispatchQueue(label: "ShopApp.NetworkMonitor")

  private var streamsCounter: Int = 0 {
    didSet {
      isMonitoring = streamsCounter > 0
    }
  }
  
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
      
      let status = lockedData.withLock {
        $0.itemsByIds[id] = item
        self.streamsCounter = $0.itemsByIds.count
        return self.status
      }
      
      continuation.onTermination = { [mutex = lockedData] _ in
        mutex.withLock {
          $0.itemsByIds[id] = nil
          self.streamsCounter = $0.itemsByIds.count
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
      status = nil
    }
  }
  
  private func receiveStatus(_ status: NetworkStatus) {
    lockedData.withLock { data in
      self.status = status
      
      for (_, item) in data.itemsByIds {
        let isConnected = status.isConnected(item.types)
        item.continuation.yield(isConnected)
      }
    }
  }
}

private struct Item {
  let continuation: AsyncStream<Bool>.Continuation
  let types: Set<NetworkType>
}

private struct ProtectedData {
  var itemsByIds = [UUID: Item]()
}
