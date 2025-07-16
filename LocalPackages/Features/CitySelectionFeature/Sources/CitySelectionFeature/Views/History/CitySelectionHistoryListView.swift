//
//  CitySelectionHistoryListView.swift
//  CitySelectionFeature
//
//  Created by Igor Nikolaev on 04.07.2025.
//

import SwiftUI
import Utility

struct CitySelectionHistoryListView: View {
  @Binding var selectedCityId: Int?
  let cities: [City]
  let userCoordinate: Coordinate?
  let onRemoveCityId: (Int) -> Void
  
  init(
    selectedCityId: Binding<Int?>,
    cities: [City],
    userCoordinate: Coordinate? = nil,
    onRemoveCityId: @escaping (Int) -> Void
  ) {
    _selectedCityId = selectedCityId
    self.cities = cities
    self.userCoordinate = userCoordinate
    self.onRemoveCityId = onRemoveCityId
  }
  
  var body: some View {
    LazyVStack(spacing: 0, pinnedViews: [.sectionHeaders]) {
      Section(
        content: {
          ForEach(cities, id: \.id) { RowView(city: $0) }
        },
        header: { HeaderView() }
      )
    }
    .animation(.smooth, value: cities)
  }
  
  @ViewBuilder private func HeaderView() -> CitySectionHeaderView {
    CitySectionHeaderView(
      text: "Ранее выбранные города",
      isLeading: true,
      gradientColor: .mainBackground
    )
  }

  @ViewBuilder private func RowView(city: City) -> some View {
    let id = city.id

    CitySelectionHistoryRowView(
      selectedCityId: $selectedCityId,
      city: city,
      userCoordinate: userCoordinate,
      onRemove: { onRemoveCityId(id) }
    )
    .animation(.rowSelection, value: selectedCityId)
  }
}

#Preview {
  struct ContentView: View {
    @State private var isDarkTheme = false
    @State private var selectedCityId: Int?
    @State private var cities: [City]
    private let initialCities: [City]
    
    init(initialCities: [City]) {
      cities = initialCities
      self.initialCities = initialCities
    }
    
    var body: some View {
      VStack {
        Toggle("Dark theme", isOn: $isDarkTheme)
        
        Button(
          action: reset,
          label: {
            Text("Reset")
              .frame(maxWidth: .infinity)
          }
        )
        .buttonStyle(
          MainButtonStyle(style: .blue, shape: .capsule)
        )
        
        CitySelectionHistoryListView(
          selectedCityId: $selectedCityId,
          cities: cities,
          onRemoveCityId: removeCity
        )
        .border(Color.blue.opacity(0.1))
        .transition(.opacity)
      }
      .animation(.smooth, value: cities)
      .preferredColorScheme(isDarkTheme ? .dark : .light)
      .padding()
    }
    
    private func removeCity(id: Int) {
      cities.removeFirst(where: { $0.id == id })
    }
    
    private func reset() {
      selectedCityId = nil
      cities = initialCities
    }
  }

  let initialCities: [City] = [
    .moscow,
    .saintPetersburg,
    .blagoveshchensk
  ]
  return ContentView(initialCities: initialCities)
}
