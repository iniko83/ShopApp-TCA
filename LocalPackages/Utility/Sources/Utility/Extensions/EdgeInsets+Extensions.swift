//
//  EdgeInsets+Extensions.swift
//  Utility
//
//  Created by Igor Nikolaev on 14.06.2025.
//

import SwiftUI

public extension EdgeInsets {
  init(horizontal: CGFloat, vertical: CGFloat) {
    self.init(
      top: vertical,
      leading: horizontal,
      bottom: vertical,
      trailing: horizontal
    )
  }
  
  init(top: CGFloat, bottom: CGFloat) {
    self.init(top: top, leading: 0, bottom: bottom, trailing: 0)
  }
  
  init(value: CGFloat) {
    self.init(
      top: value,
      leading: value,
      bottom: value,
      trailing: value
    )
  }
}

public extension EdgeInsets {
  func with(leading: CGFloat) -> Self {
    .init(top: top, leading: leading, bottom: bottom, trailing: trailing)
  }

  func with(trailing: CGFloat) -> Self {
    .init(top: top, leading: leading, bottom: bottom, trailing: trailing)
  }

  func with(top: CGFloat, bottom: CGFloat) -> Self {
    .init(top: top, leading: leading, bottom: bottom, trailing: trailing)
  }

  func with(vertical: CGFloat) -> Self {
    with(top: vertical, bottom: vertical)
  }
}
