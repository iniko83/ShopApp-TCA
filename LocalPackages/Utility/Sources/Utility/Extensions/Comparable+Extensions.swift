//
//  Comparable+Extensions.swift
//  Utility
//
//  Created by Igor Nikolaev on 18.07.2025.
//

public extension Comparable {
  func clamped(to limits: ClosedRange<Self>) -> Self {
    min(max(self, limits.lowerBound), limits.upperBound)
  }
}
