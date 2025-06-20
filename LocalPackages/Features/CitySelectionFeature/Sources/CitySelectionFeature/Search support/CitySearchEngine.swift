//
//  CitySearchEngine.swift
//  CitySelectionFeature
//
//  Created by Igor Nikolaev on 20.06.2025.
//

import Utility

/* Results always alphabetically ordered. */

struct CitySearchEngine: Sendable {
  private let cities: [City]
  
  // dependent
  private let defaultCityIds: [Int]
  private let searchItems: [CitySearchItem]
  
  init(cities: [City] = []) {
    self.cities = cities
    
    defaultCityIds = cities
      .prefix(while: { $0.size == .big })
      .sorted(by: { $0.name < $1.name })
      .map { $0.id }
    
    searchItems = cities
      .map { city in
        CitySearchItem(
          index: city.id,
          lowercasedName: city.name.lowercased()
        )
      }
      .sorted(by: { $0.lowercasedName < $1.lowercasedName })
  }
  
  func isEmpty() -> Bool {
    cities.isEmpty
  }
  
  func findNearestCity(to coordinate: Coordinate?) -> City? {
    guard let coordinate else { return nil }
    return cities.nearest(to: coordinate)
  }
  
  /// return alphabetically ordered city ids with preferred big cities on top
  func search(query: String) async -> [Int] {
    let queryParts = query.components(separatedBy: String.space)
    let queryPartsCount = queryParts.count
    let enumeratedQueryParts = queryParts.enumerated()
    
    let range = searchItems.binarySearch { searchItem -> ComparisonResult in
      let name = searchItem.lowercasedName
      let nameParts = name.components(separatedBy: String.space)
      
      var result = ComparisonResult.equal
      if nameParts.count >= queryPartsCount {
        for (index, queryPart) in enumeratedQueryParts {
          let namePart = nameParts[index]
          
          guard
            let lowerBound = namePart.range(of: queryPart)?.lowerBound,
            lowerBound == namePart.startIndex
          else {
            result = namePart.compare(queryPart)
            break
          }
        }
      } else {
        result = name.compare(query)
      }
      return result
    }

    let result = Array(searchItems[safe: range])
      .map { item -> CitySearchSortItem in
        let size = cities[item.index].size
        return .init(item: item, size: size)
      }
      .sorted(by: { (lhs, rhs) in
        let isLeftBig = lhs.size == .big
        let isRightBig = rhs.size == .big
        
        let result: Bool
        if isLeftBig != isRightBig {
          result = isLeftBig
        } else {
          result = false
        }
        return result
      })
      .map { $0.item.index }

    return result
  }
}

private struct CitySearchItem {
  let index: Int
  let lowercasedName: String
}

private struct CitySearchSortItem {
  let item: CitySearchItem
  let size: CitySize
}

private extension Array where Element == City {
  func nearest(to coordinate: Coordinate) -> City? {
    var result: City?
    var minimumDistance = Double.greatestFiniteMagnitude
    for city in self {
      let distance = city.coordinate.distance(to: coordinate)
      if distance < minimumDistance {
        minimumDistance = distance
        result = city
      }
    }
    return result
  }
}
