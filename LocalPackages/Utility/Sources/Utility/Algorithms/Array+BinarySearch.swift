//
//  Array+BinarySearch.swift
//  Utility
//
//  Created by Igor Nikolaev on 19.06.2025.
//

/* Not ideal, but works. Used for text search. */

extension Array {
  public func binarySearch(compare: (Element) -> ComparisonResult) -> Range<Int> {
    let lowerBound = lowerBound(compare: compare)
    let upperBound = upperBound(compare: compare, range: (lowerBound..<count))

    return Range(uncheckedBounds: (lowerBound, upperBound))
  }
  
  public func lowerBound(compare: (Element) -> ComparisonResult) -> Int {
    lowerBound(compare: compare, range: (0..<count))
  }
  
  // Based on: https://takeuforward.org/arrays/implement-lower-bound-bs-2/
  public func lowerBound(
    compare: (Element) -> ComparisonResult,
    range: Range<Int>
  ) -> Int {
    var result = range.upperBound
    var lower = range.lowerBound
    var upper = range.upperBound - 1
    
    while lower <= upper {
      let middle = (lower + upper) >> 1
      let comparisonResult = compare(self[middle])
      switch comparisonResult {
      case .less:
        // look on the right
        lower = middle + 1
      default:
        // may be result
        result = middle
        // look for smaller index on the left
        upper = middle - 1
      }
    }
    return result
  }

  public func upperBound(compare: (Element) -> ComparisonResult) -> Int {
    upperBound(compare: compare, range: (0..<count))
  }
  
  // Based on: https://takeuforward.org/arrays/implement-upper-bound/
  public func upperBound(
    compare: (Element) -> ComparisonResult,
    range: Range<Int>
  ) -> Int {
    var result = range.upperBound
    var lower = range.lowerBound
    var upper = range.upperBound - 1
        
    while lower <= upper {
      let middle = (lower + upper) >> 1
      let comparisonResult = compare(self[middle])
      switch comparisonResult {
      case .greater:
        // may be result
        result = middle
        // look for smaller index on the left
        upper = middle - 1
      default:
        // look on the right
        lower = middle + 1
      }
    }
    return result
  }
}
