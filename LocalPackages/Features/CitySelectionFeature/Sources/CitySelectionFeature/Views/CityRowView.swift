//
//  CityRowView.swift
//  CitySelectionFeature
//
//  Created by Igor Nikolaev on 21.06.2025.
//

import SwiftUI
import Utility

struct CityRowView: View {
  @Binding var selectedCityId: Int?
  
  private let city: City
  private let userCoordinate: Coordinate?
  
  private let animation: Animation
  
  init(
    selectedCityId: Binding<Int?>,
    city: City,
    userCoordinate: Coordinate?,
    animation: Animation = .rowSelection
  ) {
    _selectedCityId = selectedCityId
    self.city = city
    self.userCoordinate = userCoordinate
    self.animation = animation
  }
  
  var body: some View {
    let id = city.id
    let isSelected = selectedCityId == id
    
    return ZStack {
      Button(
        action: { selectedCityId = id },
        label: { Color.clear }
      )
      .buttonStyle(.highlightingCell)
      
      CityContentView(
        city: city,
        isSelected: isSelected,
        userCoordinate: userCoordinate
      )
      .padding(.cityCell)
      .animation(animation, value: selectedCityId)
    }
  }
}


#Preview {
  let cities: [City] = [
    .moscow,
    .saintPetersburg,
    .blagoveshchensk
  ]

  struct ContentView: View {
    @State private var isDarkTheme = false
    
    @State private var selectedCityId: Int?
    @State private var userLocationCityId: Int?
    
    private let cities: [City]
    
    init(cities: [City]) {
      self.cities = cities
    }
    
    var body: some View {
      let userLocationCity = userLocationCity()
      
      VStack {
        Toggle("Dark theme", isOn: $isDarkTheme)
        
        VStack(alignment: .leading, spacing: 2) {
          HStack {
            Text("User location:")
            Spacer()
            
            if let name = userLocationCity?.name {
              Text(name)
            }
          }
          
          Picker(
            selection: $userLocationCityId,
            content: {
              ForEach(cities, id: \.id) { city in
                Text(city.name).tag(city.id)
              }
            },
            label: { }
          )
          .pickerStyle(.segmented)
        }
        
        LazyVStack(spacing: 2) {
          ForEach(cities, id: \.id) { city in
            CityRowView(
              selectedCityId: $selectedCityId,
              city: city,
              userCoordinate: userLocationCity?.coordinate
            )
            .border(Color.blue.opacity(0.1))
          }
        }
      }
      .preferredColorScheme(isDarkTheme ? .dark : .light)
      .padding()
    }
    
    private func userLocationCity() -> City? {
      guard let id = userLocationCityId else { return nil }
      return cities.first(where: { $0.id == id })
    }
  }
  
  return ContentView(cities: cities)
}
