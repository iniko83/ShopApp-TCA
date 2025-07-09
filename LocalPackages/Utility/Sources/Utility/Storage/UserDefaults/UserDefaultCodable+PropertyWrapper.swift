//
//  UserDefaultCodable+PropertyWrapper.swift
//  Utility
//
//  Created by Igor Nikolaev on 04.07.2025.
//

import Foundation

@propertyWrapper
public struct UserDefaultCodable<Value: Codable> {
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
    get { container.value(forKey: key) ?? defaultValue }
    set { container.setValue(newValue, forKey: key) }
  }
  
  public var projectedValue: Bool {
    true
  }
}

extension UserDefaultCodable where Value: ExpressibleByNilLiteral {
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

extension UserDefaultCodable where Value: DefaultInitializable {
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
