import Testing
@testable import Utility


@Suite("BinarySearch tests") struct BinarySearchTests {
  @Test func binarySearchInAscendingOrderedArrayTest() async throws {
    let values: [Int] = [0, 0, 3, 3, 5, 5, 10, 10]

    let testVariants: [BinarySearchTestVariant] = [
      .init(value: 0, range: 0..<2),
      .init(value: 2, range: 2..<2),
      .init(value: 3, range: 2..<4),
      .init(value: 5, range: 4..<6),
      .init(value: 7, range: 6..<6),
      .init(value: 10, range: 6..<8)
    ]

    for variant in testVariants {
      let value = variant.value
      let range = values.binarySearch(compare: { $0.compare(value) })
      #expect(range == variant.range)
    }
  }

  @Test func binarySearchInDescendingOrderedArrayTest() async throws {
    let values: [Int] = [10, 10, 5, 5, 3, 3, 0, 0]

    let testVariants: [BinarySearchTestVariant] = [
      .init(value: 0, range: 6..<8),
      .init(value: 2, range: 6..<6),
      .init(value: 3, range: 4..<6),
      .init(value: 5, range: 2..<4),
      .init(value: 7, range: 2..<2),
      .init(value: 10, range: 0..<2)
    ]

    for variant in testVariants {
      let value = variant.value
      let range = values.binarySearch(compare: { value.compare($0) })
      #expect(range == variant.range)
    }
  }

  fileprivate struct BinarySearchTestVariant {
    let value: Int        // input
    let range: Range<Int> // expected
  }
}

@Suite("TimePhase tests") struct TimePhaseTests {
  @Test func timePhaseTests() async throws {
    let phases: [TimePhase<Double>] = [
      .init(value: 3, time: 1),
      .init(value: 2, time: 0.5),
      .init(value: 1, time: 0.2)
    ]

    let testVariants: [TimePhaseTestVariant] = [
      .init(time: 1.5, value: 3),
      .init(time: 1, value: 3),
      .init(time: 0.8, value: 2.6),
      .init(time: 0.5, value: 2),
      .init(time: 0.35, value: 1.5),
      .init(time: 0.2, value: 1),
      .init(time: 0.1, value: 0.5),
      .init(time: 0, value: 0)
    ]

    for variant in testVariants {
      let time = variant.time

      let phaseLowerBound = TimePhase.phaseLowerBound(
        time: time,
        phases: phases
      )

      let value = TimePhase.initialValue(
        time: time,
        phases: phases,
        lowerBound: phaseLowerBound
      )

      #expect(value == variant.value)
    }
  }

  fileprivate struct TimePhaseTestVariant {
    let time: Double  // input
    let value: Double // expected
  }
}
