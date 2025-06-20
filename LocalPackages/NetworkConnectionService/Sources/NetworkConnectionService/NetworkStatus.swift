//
//  NetworkStatus.swift
//  NetworkStatusObserver
//
//  Created by Igor Nikolaev on 20.06.2025.
//

import Network

struct NetworkStatus {
  let isConnected: Bool
  let types: Set<NetworkType>
  
  init(path: NWPath) {
    let isConnected = path.status == .satisfied
    
    self.isConnected = isConnected
    types = isConnected
      ? Set(path.availableInterfaces.map { $0.type })
      : .init()
  }
  
  func isConnected(_ types: Set<NetworkType>) -> Bool {
    isConnected && !self.types.intersection(types).isEmpty
  }
}
