//
//  UserDefaults+Extensions.swift
//  Utility
//
//  Created by Igor Nikolaev on 08.07.2025.
//

import Foundation

public extension UserDefaults {
  func setValue<Value: Encodable>(_ value: Value, forKey key: String) {
    if let optional = value as? AnyOptional, optional.isNil() {
      removeObject(forKey: key)
    } else {
      let data = try? JSONEncoder().encode(value)
      set(data, forKey: key)
    }
  }
  
  func value<Value: Decodable>(forKey key: String) -> Value? {
    guard
      let data = object(forKey: key) as? Data,
      let result = try? JSONDecoder().decode(Value.self, from: data)
    else { return nil }
    
    return result
  }
}
