//
//  ToastStyle.swift
//  Utility
//
//  Created by Igor Nikolaev on 16.06.2025.
//

import SwiftUI

public enum ToastStyle: Int {
  case error
  case information
  case success
  case warning
  
  public init() {
    self = .information
  }
  
  public func color() -> Color {
    let result: Color
    switch self {
    case .error:
      result = .toastError
    case .information:
      result = .toastInformation
    case .success:
      result = .toastSuccess
    case .warning:
      result = .toastWarning
    }
    return result
  }
  
  public func iconSystemName() -> String {
    let result: String
    switch self {
    case .error:
      result = "exclamationmark.triangle"
    case .information:
      result = "info.circle"
    case .success:
      result = "checkmark.circle"
    case .warning:
      result = "exclamationmark.circle"
    }
    return result
  }
}


/// Constants
private extension Color {
  static let toastError = Color.dynamicRgbHex(dark: 0xf5542c, light: 0xff3300)
  static let toastInformation = Color.dynamicRgbHex(dark: 0x1d88f2, light: 0x0080ff)
  static let toastSuccess = Color.dynamicRgbHex(dark: 0x24ed24, light: 0x00ff00)
  static let toastWarning = Color.dynamicRgbHex(dark: 0xe38424, light: 0xff8000)
}
