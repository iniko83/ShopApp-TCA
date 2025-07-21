//
//  Interpolatable.swift
//  Utility
//
//  Created by Igor Nikolaev on 18.07.2025.
//

import Foundation

public protocol Interpolatable {
  func interpolate(to: Self, progress: Double) -> Self
}

extension CGFloat: Interpolatable {
  public func interpolate(to: CGFloat, progress: Double) -> CGFloat {
    self + (to - self) * Self(progress)
  }
}

extension Double: Interpolatable {
  public func interpolate(to: Double, progress: Double) -> Double {
    self + (to - self) * Self(progress)
  }
}
