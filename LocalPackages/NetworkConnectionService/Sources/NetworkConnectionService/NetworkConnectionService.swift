// The Swift Programming Language
// https://docs.swift.org/swift-book

import Dependencies
import Network

public struct NetworkConnectionService: Sendable {
  public let connectionStream: @Sendable (_ types: Set<NetworkType>) -> AsyncStream<Bool>
}

extension NetworkConnectionService {
  public var anyConnectionStream: @Sendable () -> AsyncStream<Bool> {
    return { self.connectionStream(.any) }
  }
}

extension NetworkConnectionService: DependencyKey {
  public static var liveValue: Self {
    online
  }
  
  public static var previewValue: Self {
    online
  }
  
  public static var testValue: Self {
    online
  }
  
  public static var online: Self {
    let manager = NetworkMonitor()
    
    return Self(
      connectionStream: { types in manager.connectionStream(types: types) }
    )
  }
  
  public static var offline: Self {
    return Self(
      connectionStream: { types in
        AsyncStream(bufferingPolicy: .bufferingNewest(1)) { continuation in
          continuation.yield(false)
        }
      }
    )
  }
}

extension DependencyValues {
  public var networkConnectionService: NetworkConnectionService {
    get { self[NetworkConnectionService.self] }
    set { self[NetworkConnectionService.self] = newValue }
  }
}
