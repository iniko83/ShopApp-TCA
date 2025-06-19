//
//  ActivityStyle.swift
//  Utility
//
//  Created by Igor Nikolaev on 14.06.2025.
//

import Foundation

public typealias ActivityStyle = Activity.Style

public enum Activity {
  public enum Style {
    case ballRotateChase
    case spinner(configuration: SpinnerConfiguration)
    
    public init() {
      self = .ballRotateChase
    }
    
    public static func spinner(
      thickness: Double = 0.125,
      trackOpacity: Double = 0.2
    ) -> Self {
      .spinner(
        configuration: SpinnerConfiguration(
          thickness: thickness,
          trackOpacity: trackOpacity
        )
      )
    }
  }
}

extension Activity {
  public enum Size {
    case icon
    case screen
    
    public init() {
      self = .icon
    }
    
    public func side() -> CGFloat {
      let result: CGFloat
      switch self {
      case .icon:
        result = 24
      case .screen:
        result = 100
      }
      return result
    }
  }
}

extension Activity {
  public struct SpinnerConfiguration {
    let thickness: Double
    let trackOpacity: Double
  }
}
