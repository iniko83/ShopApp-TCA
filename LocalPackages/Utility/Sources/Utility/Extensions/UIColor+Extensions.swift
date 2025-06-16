//
//  UIColor+Extensions.swift
//  Utility
//
//  Created by Igor Nikolaev on 16.06.2025.
//

import UIKit

extension UIColor {
  public convenience init(rgbHex hex: UInt) {
    self.init(
      redBits: hex >> 16,
      greenBits: hex >> 08,
      blueBits: hex,
      alpha: 1
    )
  }

  public convenience init(rgbaHex hex: UInt) {
    self.init(
      redBits: hex >> 24,
      greenBits: hex >> 16,
      blueBits: hex >> 08,
      alpha: CGFloat(hex & 0xff) * .factor
    )
  }

  private convenience init(
    redBits: UInt,
    greenBits: UInt,
    blueBits: UInt,
    alpha: CGFloat = 1
  ) {
    self.init(
      red: CGFloat(redBits & 0xff) * .factor,
      green: CGFloat(greenBits & 0xff) * .factor,
      blue: CGFloat(blueBits & 0xff) * .factor,
      alpha: alpha
    )
  }
}


/// Constants
private extension CGFloat {
  static let factor: CGFloat = 1 / 255
}
