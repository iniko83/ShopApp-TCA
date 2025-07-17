//
//  CitySelectionRowView.swift
//  CitySelectionFeature
//
//  Created by Igor Nikolaev on 21.06.2025.
//

import SwiftUI
import Utility

struct CitySelectionRowView: View {
  @Binding var selectedCityId: Int?
  let city: City
  let userCoordinate: Coordinate?
  let animation: Animation

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
      CellHighlightingButton(action: { selectedCityId = id })

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
  struct ContentView: View {
    @State private var isDarkTheme = false
    @State private var selectedCityId: Int?
    @State private var userLocationCityId: Int?
    let cities: [City]

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
            label: {}
          )
          .pickerStyle(.segmented)
        }
        
        LazyVStack(spacing: 2) {
          ForEach(cities, id: \.id) { city in
            CitySelectionRowView(
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

  let cities: [City] = [
    .moscow,
    .saintPetersburg,
    .blagoveshchensk
  ]
  return ContentView(cities: cities)
}
