//
//  Constants.swift
//  Utility
//
//  Created by Igor Nikolaev on 18.06.2025.
//

import SwiftUI

public extension Color {
  static let mainAccent = Color.dynamicRgbHex(dark: 0xe3546d, light: 0xf8395a)
  static let mainBackground = Color.dynamicRgbHex(dark: 0x2181ff, light: 0x4392f9)
  
  /// used for buttons, with .clear would be pressed only near visible content (not by edges)
  static let transparent = Color(white: 0, opacity: 0.00001)
}

public extension EdgeInsets {
  static let buttonDefaultPadding = EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16)
  static let zero = EdgeInsets(value: .zero)
}

public extension String {
  static let empty = ""
  static let space = " "
  
  static let retry = "Повторить"
}
