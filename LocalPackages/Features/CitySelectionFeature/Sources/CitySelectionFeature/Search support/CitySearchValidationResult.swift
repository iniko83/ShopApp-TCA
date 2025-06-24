//
//  CitySearchValidationResult.swift
//  CitySelectionFeature
//
//  Created by Igor Nikolaev on 23.06.2025.
//

import Foundation

public struct CitySearchValidationResult {
  let text: String
  let invalidSymbols: String?
  
  func query() -> String {
    text.lowercased()
  }
}
 
enum CitySearch {
  static func validate(text: String) -> CitySearchValidationResult {
    let invalidSymbols = text.unicodeScalars.filter { !CharacterSet.filtrationSet.contains($0) }
    
    let result: CitySearchValidationResult
    if invalidSymbols.isEmpty {
      result = .init(text: text, invalidSymbols: nil)
    } else {
      let validSymbols = text.unicodeScalars.filter { CharacterSet.filtrationSet.contains($0) }
      result = .init(
        text: String(validSymbols),
        invalidSymbols: String(invalidSymbols)
      )
    }
    return result
  }
}


/// Constants
private extension CharacterSet {
  static let filtrationSet = CharacterSet(charactersIn: String.russianAlphabet + .space)
}
