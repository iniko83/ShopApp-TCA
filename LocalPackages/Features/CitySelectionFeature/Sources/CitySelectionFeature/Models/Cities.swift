//
//  Cities.swift
//  CitySelectionFeature
//
//  Created by Igor Nikolaev on 18.06.2025.
//

import Foundation
import Utility

struct Cities: Decodable {
  let list: [City]
  
  /// Decodable
  private enum CodingKeys: String, CodingKey {
    case cities
    case citySizeIndexes
  }
  
  init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    
    let cities = try container.decode([CityRawData].self, forKey: .cities)
    let sizeIndexes = try container.decode([Int].self, forKey: .citySizeIndexes)
    
    list = cities.enumerated().compactMap { item -> City? in
      let (index, cityRawData) = item
      let sizeRawValue = sizeIndexes.firstIndex(where: { index < $0 }) ?? sizeIndexes.count

      guard let size = CitySize(rawValue: sizeRawValue) else { return nil }
      
      return City(
        id: index,
        name: cityRawData.name,
        coordinate: cityRawData.coordinate,
        size: size,
        subject: cityRawData.subject
      )
    }
  }
}

private struct CityRawData: Decodable {
  let name: String
  let coordinate: Coordinate
  let subject: String?
}
