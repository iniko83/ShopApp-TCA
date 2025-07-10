//
//  CitySelectionHistoryRowView.swift
//  CitySelectionFeature
//
//  Created by Igor Nikolaev on 04.07.2025.
//

import SwiftUI
import Utility

struct CitySelectionHistoryRowView: View {
  @Binding var selectedCityId: Int?
  
  private let city: City
  private let userCoordinate: Coordinate?
  
  private let animation: Animation
  
  private let onRemove: () -> Void
  
  init(
    selectedCityId: Binding<Int?>,
    city: City,
    userCoordinate: Coordinate?,
    animation: Animation = .rowSelection,
    onRemove: @escaping () -> Void
  ) {
    _selectedCityId = selectedCityId
    self.city = city
    self.userCoordinate = userCoordinate
    self.animation = animation
    self.onRemove = onRemove
  }
  
  var body: some View {
    let id = city.id
    let isSelected = selectedCityId == id

    let contentInsets = EdgeInsets.cityCell.with(trailing: 0)
    let buttonInsets = EdgeInsets.cityCell.with(vertical: 0)

    ZStack {
      Button(
        action: { selectedCityId = id },
        label: { Color.clear }
      )
      .buttonStyle(.highlightingCell)
      
      HStack {
        CityContentView(
          city: city,
          isSelected: isSelected,
          userCoordinate: userCoordinate
        )
        .animation(animation, value: selectedCityId)
        .padding(contentInsets)

        Button(
          action: onRemove,
          label: {
            Image(systemName: "minus.circle.fill")
              .resizable()
              .aspectRatio(contentMode: .fit)
              .frame(square: 24)
              .symbolRenderingMode(.palette)
              .foregroundStyle(Color.white, Color.citySelection)
              .frame(maxHeight: .infinity)
              .padding(buttonInsets)
          }
        )
      }
      .geometryGroup()
    }
  }
}


#Preview {
  @Previewable @State var selectedCityId: Int?
  
  let city = City.moscow
  
  LazyVStack {
    CitySelectionHistoryRowView(
      selectedCityId: $selectedCityId,
      city: city,
      userCoordinate: nil,
      onRemove: {}
    )
    .border(Color.blue.opacity(0.1))
  }
}
