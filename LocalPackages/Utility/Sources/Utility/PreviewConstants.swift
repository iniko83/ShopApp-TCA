//
//  Constants.swift
//  Utility
//
//  Created by Igor Nikolaev on 04.07.2025.
//

public extension Coordinate {
  static let moscow = Coordinate(latitude: 37.620405, longitude: 55.7540471)
  static let saintPetersburg = Coordinate(latitude: 59.943646, longitude: 30.2851863)
  static let blagoveshchensk = Coordinate(latitude: 50.25778, longitude: 127.53639)
}

public extension City {
  static let moscow = City(
    id: 0,
    name: "Москва",
    coordinate: .moscow,
    size: .big,
    subject: nil
  )
  
  static let saintPetersburg = City(
    id: 1,
    name: "Санкт-Петербург",
    coordinate: .saintPetersburg,
    size: .big,
    subject: nil
  )
  
  static let blagoveshchensk = City(
    id: 52,
    name: "Благовещенск",
    coordinate: Coordinate(latitude: 50.25778, longitude: 127.53639),
    size: .small,
    subject: "Амурская область"
  )
}
