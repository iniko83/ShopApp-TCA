//
//  CityRowView.swift
//  CitySelectionFeature
//
//  Created by Igor Nikolaev on 21.06.2025.
//

import SwiftUI
import Utility

struct CityRowView: View {
  private let data: CityRowData
  private let onSelectId: (_ id: Int) -> Void
  
  init(
    data: CityRowData,
    onSelectId: @escaping (_ id: Int) -> Void
  ) {
    self.data = data
    self.onSelectId = onSelectId
  }
  
  var body: some View {
    let id = data.city.id
    
    return ZStack {
      Button(
        action: { onSelectId(id) },
        label: { Color.clear }
      )
      .buttonStyle(.highlightingCell)
      
      CityContentView(rowData: data)
        .padding(.cityCell)
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
            RowView(
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
    
    @ViewBuilder private func RowView(
      city: City,
      userCoordinate: Coordinate?
    ) -> some View {
      let isSelected = city.id == selectedCityId
      
      CityRowView(
        data: CityRowData(
          city: city,
          isSelected: isSelected,
          userCoordinate: userCoordinate
        ),
        onSelectId: { id in selectedCityId = id }
      )
      .animation(.rowSelection, value: isSelected)
    }
    
    private func userLocationCity() -> City? {
      guard let id = userLocationCityId else { return nil }
      return cities.first(where: { $0.id == id })
    }
  }
  
  return ContentView(cities: cities)
}
