//
//  Timestamp.swift
//  Utility
//
//  Created by Igor Nikolaev on 01.07.2025.
//

import Foundation

public enum Timestamp {
  public static func now() -> TimeInterval {
    Date().timeIntervalSinceReferenceDate
  }
  
  public static func timeout(_ value: TimeInterval) -> TimeInterval {
    now() + value
  }
}
