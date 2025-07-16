//
//  CitySelectionToastData.swift
//  CitySelectionFeature
//
//  Created by Igor Nikolaev on 11.07.2025.
//

import Foundation
import Utility

struct CitySelectionToastData: Equatable {
  var list = [Toast]()

  mutating func displayToast(_ toast: Toast) {
    list = list.filter { $0.item != toast.item }
    list.append(toast)
  }

  mutating func removeToast(item: ToastItem) {
    list.removeAll { $0.item == item }
  }

  func nearestTimeoutDelay() -> TimeInterval? {
    let timeout = list.reduce(nil) { (partialResult, toast) -> TimeInterval? in
      guard let timestamp = toast.timeoutStamp else { return partialResult }

      let result: TimeInterval
      if let partialResult {
        result = min(timestamp, partialResult)
      } else {
        result = timestamp
      }
      return result
    }

    guard let timeout else { return nil }
    return max(0, timeout - Timestamp.now())
  }

  mutating func removeExpiredToasts() {
    let timestamp = Timestamp.now()
    list.removeAll { toast -> Bool in // isShouldBeRemoved
      guard let timeout = toast.timeoutStamp else { return false }
      return timeout < timestamp
    }
  }
}
