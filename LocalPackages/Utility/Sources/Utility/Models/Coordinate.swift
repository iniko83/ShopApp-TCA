//
//  Coordinate.swift
//  Utility
//
//  Created by Igor Nikolaev on 17.06.2025.
//

import CoreLocation

/* На самом деле можно использовать CLLocationCoordinate2D, но подавлять Decodable, Equatable warnings через @retroactive пока нет желания. */

public struct Coordinate: Equatable, Sendable {
  public let latitude: Double
  public let longitude: Double
  
  public init(
    latitude: Double,
    longitude: Double
  ) {
    self.latitude = latitude
    self.longitude = longitude
  }
  
  public init(coordinate: CLLocationCoordinate2D) {
    self.init(
      latitude: coordinate.latitude,
      longitude: coordinate.longitude
    )
  }
  
  public func distance(to: Coordinate) -> Double {
    location().distance(from: to.location())
  }
  
  public func locationCoordinate() -> CLLocationCoordinate2D {
    .init(latitude: latitude, longitude: longitude)
  }
  
  private func location() -> CLLocation {
    .init(latitude: latitude, longitude: longitude)
  }
}

extension Coordinate: Codable {
  private enum CodingKeys: String, CodingKey {
    case latitude = "lat"
    case longitude = "lon"
  }
  
  public init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    
    latitude = try container.decode(Double.self, forKey: .latitude)
    longitude = try container.decode(Double.self, forKey: .longitude)
  }
  
  public func encode(to encoder: any Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    
    try container.encode(latitude, forKey: .latitude)
    try container.encode(longitude, forKey: .longitude)
  }
}
