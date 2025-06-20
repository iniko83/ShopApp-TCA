//
//  Array+Extensions.swift
//  Utility
//
//  Created by Igor Nikolaev on 20.06.2025.
//

extension Array {
  public subscript(safe index: Index) -> Element? {
    index < count ? self[index] : nil
  }
}

// Based on: https://stackoverflow.com/a/37560630
extension Array {
  public subscript(safe range: Range<Int>) -> ArraySlice<Element> {
    guard
      range.lowerBound < count,
      range.upperBound > 0
    else { return [] }
    
    let lower = Swift.max(0, range.lowerBound)
    let upper = Swift.min(count, range.upperBound)
    return self[lower..<upper]
  }
  
  public subscript(safe range: ClosedRange<Int>) -> ArraySlice<Element> {
    guard
      range.lowerBound < count,
      range.upperBound > 0
    else { return [] }
    
    let lower = Swift.max(0, range.lowerBound)
    let upper = Swift.min(count, range.upperBound + 1)
    return self[lower..<upper]
  }
}
