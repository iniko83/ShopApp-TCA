//
//  Frames.swift
//  CitySelectionFeature
//
//  Created by Igor Nikolaev on 14.07.2025.
//

import SwiftUI

struct Frames: Equatable {
  let content: CGRect
  let global: CGRect

  init(
    content: CGRect,
    global: CGRect
  ) {
    self.content = content
    self.global = global
  }

  init() {
    self.init(
      content: .zero,
      global: .zero
    )
  }
}
