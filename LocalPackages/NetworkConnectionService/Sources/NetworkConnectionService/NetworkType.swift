//
//  NetworkType.swift
//  NetworkConnectionService
//
//  Created by Igor Nikolaev on 20.06.2025.
//

import Network

public typealias NetworkType = NWInterface.InterfaceType

extension Set where Element == NetworkType {
  public static let cellularOrWifi = Set([.wifi, .cellular])
  
  static let any: Set<NetworkType> = Set([
    .wifi,
    .cellular,
    .wiredEthernet,
    .loopback,
    .other
  ])
}
