//
//  TimeoutData.swift
//  Utility
//
//  Created by Igor Nikolaev on 18.07.2025.
//

import Foundation

/* NOTE: Phases must contain cumulative progress in ascending order like here:
 phases: [Phase<Color>] = [
   .init(progress: 0.0, value: .red)     // ... 0.4 - 0.0, moving towards: .red
   .init(progress: 0.4, value: .orange), // this stage would have duration: period * (1.0 - 0.4), moving from .white to .orange color
   .init(progress: 1.0, value: .white)
 ]
 */

public struct TimeoutData<Value: Equatable & Interpolatable>: Equatable {
  public let period: TimeInterval
  public let phases: [Phase]

  public init(
    period: TimeInterval,
    phases: [Phase]
  ) {
    self.period = period
    self.phases = phases
  }

  func animationData(timeout: TimeInterval) -> AnimationData {
    let progress = timeout / period
    let initialProgress = progress.clamped(to: 0...1)
    let upperBound = phases.upperBound(compare: { $0.progress.compare(progress) })
    let initialValue = initialValue(
      progress: initialProgress,
      upperBound: upperBound
    )
    let initialPhase = Phase(progress: initialProgress, value: initialValue)
    let items = animationItems(
      initialPhase: Phase(progress: progress, value: initialValue),
      upperBound: upperBound
    )
    return .init(initial: initialPhase, items: items)
  }

  private func animationItem(from: Phase, to: Phase) -> AnimationItem? {
    let progressDifference = from.progress - to.progress
    guard progressDifference > 0 else { return nil }
    let duration = period * progressDifference
    return .init(
      duration: duration,
      phase: to
    )
  }

  private func animationItems(
    initialPhase: Phase,
    upperBound: Int
  ) -> [AnimationItem] {
    guard var to = phases.first else { return [] }
    var result = [AnimationItem]()

    for index in 1 ..< upperBound {
      guard let from = phases[safe: index] else { break }
      if let animationItem = animationItem(from: from, to: to) {
        result.append(animationItem)
      }
      to = from
    }

    if let animationItem = animationItem(from: initialPhase, to: to) {
      result.append(animationItem)
    }

    return result
  }

  private func initialValue(progress: Double, upperBound: Int) -> Value {
    let result: Value
    if let upperPhase = phases[safe: upperBound] {
      if
        upperPhase.progress < progress,
        let phase = phases[safe: upperBound - 1]
      {
      let valueProgress = (progress - phase.progress) / (upperPhase.progress - phase.progress)
      result = phase.value.interpolate(to: upperPhase.value, progress: valueProgress)
      } else {
        result = upperPhase.value
      }
    } else {
      result = phases.last!.value
    }
    return result
  }
}

public extension TimeoutData {
  struct Phase: Equatable {
    public let progress: Double
    public let value: Value

    public init(progress: Double, value: Value) {
      self.progress = progress
      self.value = value
    }
  }
}

extension TimeoutData {
  struct AnimationData {
    var initial: Phase
    var items: [AnimationItem]

    var isEmpty: Bool { items.isEmpty }

    mutating func fetchItem() -> AnimationItem? {
      guard !isEmpty else { return nil }
      let item = items.removeLast()
      initial = item.phase
      return item
    }
  }

  struct AnimationItem {
    let duration: TimeInterval
    let phase: Phase
  }
}
