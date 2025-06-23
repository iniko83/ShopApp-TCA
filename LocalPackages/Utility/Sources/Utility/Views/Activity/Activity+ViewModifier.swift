//
//  Activity+ViewModifier.swift
//  Utility
//
//  Created by Igor Nikolaev on 18.06.2025.
//

import SwiftUI

extension View {
  public func activitySize(_ size: Activity.Size) -> some View {
    modifier(ActivitySizeModifier(size: size))
  }
}

struct ActivitySizeModifier: ViewModifier {
  private let size: Activity.Size
  
  init(size: Activity.Size) {
    self.size = size
  }
  
  func body(content: Content) -> some View {
    let side = size.side()
    return content.frame(square: side)
  }
}
