//
//  Task+Extensions.swift
//  Utility
//
//  Created by Igor Nikolaev on 04.07.2025.
//

import Foundation

// Copied from: [ https://forums.swift.org/t/async-await-is-it-possible-to-start-a-task-on-mainactor-synchronously/52862/16 ]
public extension Task where Failure == Never {
  @discardableResult
  static func onMainActor(
    priority: TaskPriority? = nil,
    @_implicitSelfCapture operation: @escaping @MainActor () async -> Success
  ) -> Task where Failure == Never {
    .init(priority: priority) {
      await operation()
    }
  }
}
