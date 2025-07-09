//
//  UserDefault+PropertyWrapper.swift
//  Utility
//
//  Created by Igor Nikolaev on 04.07.2025.
//

// Based on: [ https://www.avanderlee.com/swift/property-wrappers/ ]

import Foundation

@propertyWrapper
public struct UserDefault<Value> {
  let key: String
  let defaultValue: Value
  let container: UserDefaults
  
  public init(
    key: String,
    defaultValue: Value,
    container: UserDefaults = .standard
  ) {
    self.key = key
    self.defaultValue = defaultValue
    self.container = container
  }
  
  public var wrappedValue: Value {
    get { container.object(forKey: key) as? Value ?? defaultValue }
    set {
      if let optional = newValue as? AnyOptional, optional.isNil() {
        container.removeObject(forKey: key)
      } else {
        container.set(newValue, forKey: key)
      }
    }
  }
  
  public var projectedValue: Bool {
    true
  }
}

extension UserDefault where Value: ExpressibleByNilLiteral {
  public init(
    key: String,
    container: UserDefaults = .standard
  ) {
    self.init(
      key: key,
      defaultValue: nil,
      container: container
    )
  }
}

extension UserDefault where Value: DefaultInitializable {
  public init(
    key: String,
    container: UserDefaults = .standard
  ) {
    self.init(
      key: key,
      defaultValue: .init(),
      container: container
    )
  }
}
