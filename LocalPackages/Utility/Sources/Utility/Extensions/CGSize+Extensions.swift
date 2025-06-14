//
//  CGSize+Extensions.swift
//  Utility
//
//  Created by Igor Nikolaev on 14.06.2025.
//

import CoreFoundation

extension CGSize {
  public func minSide() -> CGFloat {
    min(width, height)
  }
}
