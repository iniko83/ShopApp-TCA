//
//  EdgeInsets+Extensions.swift
//  Utility
//
//  Created by Igor Nikolaev on 14.06.2025.
//

import SwiftUI

extension EdgeInsets {
  public init(horizontal: CGFloat, vertical: CGFloat) {
    self.init(
      top: vertical,
      leading: horizontal,
      bottom: vertical,
      trailing: horizontal
    )
  }
}
