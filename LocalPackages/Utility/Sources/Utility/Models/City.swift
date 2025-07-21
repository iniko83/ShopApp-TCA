//
//  City.swift
//  Utility
//
//  Created by Igor Nikolaev on 17.06.2025.
//

import Foundation

public struct City: Codable, Equatable, Identifiable, Sendable {
  public let id: Int
  public let name: String
  public let coordinate: Coordinate
  public let size: CitySize
  public let subject: String? // only for cities with equal names
  
  /// Preview support
  public init(
    id: Int,
    name: String,
    coordinate: Coordinate,
    size: CitySize,
    subject: String?
  ) {
    self.id = id
    self.name = name
    self.coordinate = coordinate
    self.size = size
    self.subject = subject
  }
  
  /// Equatable
  public static func == (lhs: City, rhs: City) -> Bool {
    lhs.id == rhs.id
  }
}

public enum CitySize: Int, Codable, Sendable {
  case big
  case middle
  case small
  case tiny
}
