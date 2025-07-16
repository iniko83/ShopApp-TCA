//
//  CitySelectionListSection.swift
//  CitySelectionFeature
//
//  Created by Igor Nikolaev on 24.06.2025.
//

import Foundation
import Utility

/*
 Одним из недостатков TCA является тот факт, что State & Action должны быть public,
 таким образом все, что приходит в Action, будет видно снаружи.
 */

public struct CitySelectionListSection: Equatable, Identifiable, Sendable {
  let kind: Kind
  let cities: [City]

  /// Identifiable
  public var id: Int { kind.id }
}

extension CitySelectionListSection {
  public enum Kind: Equatable, Identifiable, Sendable {
    case combinedSizes(CombinedCitySizes)
    case bigCities
    case untitled
    
    /// Identifiable
    public var id: Int {
      let result: Int
      switch self {
      case let .combinedSizes(sizes):
        result = sizes.rawValue
      case .bigCities:
        result = CombinedCitySizes.allCases.count
      case .untitled:
        result = 1 + CombinedCitySizes.allCases.count
      }
      return result
    }
  }
  
  public enum CombinedCitySizes: Int, Equatable, Sendable {
    case bigAndMiddle
    case others
  }
}

extension CitySelectionListSection.CombinedCitySizes: CaseIterable {}
