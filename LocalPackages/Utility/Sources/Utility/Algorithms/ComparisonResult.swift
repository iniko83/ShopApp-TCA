//
//  ComparisonResult.swift
//  Utility
//
//  Created by Igor Nikolaev on 20.06.2025.
//

public enum ComparisonResult: Int {
  case less
  case equal
  case greater
}

extension Comparable {
  public func compare(_ other: Self) -> ComparisonResult {
    self == other
      ? .equal
      : self < other
        ? .less
        : .greater
  }
}
