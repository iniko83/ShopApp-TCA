//
//  Color+Extensions.swift
//  Utility
//
//  Created by Igor Nikolaev on 16.06.2025.
//

import SwiftUI

extension Color {
  public init(rgbHex hex: UInt) {
    self.init(
      redBits: hex >> 16,
      greenBits: hex >> 08,
      blueBits: hex,
      opacity: 1
    )
  }
  
  public init(rgbaHex hex: UInt) {
    self.init(
      redBits: hex >> 24,
      greenBits: hex >> 16,
      blueBits: hex >> 08,
      opacity: Double(hex & 0xff) * .factor
    )
  }
  
  private init(
    redBits: UInt,
    greenBits: UInt,
    blueBits: UInt,
    opacity: Double = 1
  ) {
    self.init(
      .sRGB,
      red: Double(redBits & 0xff) * .factor,
      green: Double(greenBits & 0xff) * .factor,
      blue: Double(blueBits & 0xff) * .factor,
      opacity: opacity
    )
  }
}

extension Color {
  // Based on: [ https://tanaschita.com/swiftui-dynamic-colors/ ]
  // NOTE: Color func resolve(in:) used outside standard behavior.
  public static func dynamic(dark: UIColor, light: UIColor) -> Color {
    let uiColor = UIColor { traitCollection -> UIColor in
      return traitCollection.userInterfaceStyle == .dark ? dark : light
    }
    return Color(uiColor)
  }
  
  public static func dynamicRgbaHex(dark: UInt, light: UInt) -> Color {
    dynamic(
      dark: .init(rgbaHex: dark),
      light: .init(rgbaHex: light)
    )
  }
  
  public static func dynamicRgbHex(dark: UInt, light: UInt) -> Color {
    dynamic(
      dark: .init(rgbHex: dark),
      light: .init(rgbHex: light)
    )
  }
}

extension Color {
  // Based on: [ https://stackoverflow.com/a/71689567 ]
  public func adjust(
    hue: Double = 0,
    saturation: Double = 0,
    brightness: Double = 0,
    opacity: Double = 1
  ) -> Color {
    let color = UIColor(self)
    var colorHue = CGFloat.zero
    var colorSaturation = CGFloat.zero
    var colorBrigthness = CGFloat.zero
    var colorOpacity = CGFloat.zero
    
    guard
      color.getHue(
        &colorHue,
        saturation: &colorSaturation,
        brightness: &colorBrigthness,
        alpha: &colorOpacity
      )
    else { return self }
    
    let finalOpacity = max(0, min(1, colorOpacity + opacity))
    
    return Color(
      hue: colorHue + hue,
      saturation: colorSaturation + saturation,
      brightness: colorBrigthness + brightness,
      opacity: finalOpacity
    )
  }
}

extension Color: Interpolatable {
  public func interpolate(to color: Color, progress: Double) -> Self {
    let from = UIColor(self)
    let to = UIColor(color)
    let uiColor = from.interpolate(to: to, progress: progress)
    return Color(uiColor)
  }
}


/// Constants
private extension Double {
  static let factor: Double = 1 / 255
}
