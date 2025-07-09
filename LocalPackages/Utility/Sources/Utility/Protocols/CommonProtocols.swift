//
//  CommonProtocols.swift
//  Utility
//
//  Created by Igor Nikolaev on 04.07.2025.
//

import Foundation

public protocol AnyOptional {
  func isNil() -> Bool
}

extension Optional: AnyOptional {
  public func isNil() -> Bool {
    self == nil
  }
}


public protocol DefaultInitializable {
  init()
}

extension Array: DefaultInitializable {}
extension Dictionary: DefaultInitializable {}
