//
//  Constants.swift
//  Utility
//
//  Created by Igor Nikolaev on 18.06.2025.
//

import SwiftUI

public extension Animation {
  static let keyboard = Animation.interpolatingSpring(.keyboard)
}

public extension Color {
  static let backgroundShadow = Color.dynamicRgbaHex(dark: 0xffffff54, light: 0x00000054)

  static let cellHighlighted = Color.dynamicRgbaHex(dark: 0xd9d9d919, light: 0xcdcdcd19)

  static let mainAccent = Color.dynamicRgbHex(dark: 0xe3546d, light: 0xf8395a)
  static let mainBackground = Color.dynamicRgbHex(dark: 0x2181ff, light: 0x4392f9)
  
  /// used for buttons, with .clear would be pressed only near visible content (not by edges)
  static let transparent = Color(white: 0, opacity: 0.00001)
}

public extension Double {
  static let searchDelay = 0.3
}

public extension EdgeInsets {
  static let buttonDefaultPadding = EdgeInsets(horizontal: 16, vertical: 8)
  static let zero = EdgeInsets(value: .zero)
}

public extension Locale {
  static let russian = Locale(identifier: "ru_RU")
}

public extension Spring {
  static let keyboard = Spring(mass: 3, stiffness: 1000, damping: 500)
}

public extension String {
  static let empty = ""
  static let space = " "

  static let lowercasedRussianAlphabet = "абвгдеёжзийклмнопрстуфхцчшщъыьэюя"
  static let russianAlphabet = lowercasedRussianAlphabet + lowercasedRussianAlphabet.uppercased()

  static let cancellation = "Отмена"
  static let retry = "Повторить"
}


/// Keys
public enum StorageKey {
  public static let userCity = "userCity"
  public static let userCityIdsSelectionHistory = "userCityIdsSelectionHistory"
}
