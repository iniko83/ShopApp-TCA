//
//  OpenApplicationSettings.swift
//  Utility
//
//  Created by Igor Nikolaev on 25.06.2025.
//

// NOTE: [ https://github.com/pointfreeco/swift-composable-architecture/blob/main/Examples/SyncUps/SyncUps/Dependencies/OpenSettings.swift ]

import Dependencies
import UIKit

extension DependencyValues {
  public var openApplicationSettings: @Sendable () async -> Void {
    get { self[OpenApplicationSettingsKey.self] }
    set { self[OpenApplicationSettingsKey.self] = newValue }
  }
  
  private enum OpenApplicationSettingsKey: DependencyKey {
    typealias Value = @Sendable () async -> Void
    
    static let liveValue: Value = {
      await MainActor.run {
        let url = URL(string: UIApplication.openSettingsURLString)!
        UIApplication.shared.open(url)
      }
    }
  }
}
