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
  let city: City
  let userCoordinate: Coordinate?
  let animation: Animation
  let onRemove: () -> Void
  
  init(
    selectedCityId: Binding<Int?>,
    city: City,
    userCoordinate: Coordinate? = nil,
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
    let padding = EdgeInsets.cityCell.with(trailing: 0)

    ZStack {
      CellHighlightingButton(action: { selectedCityId = id })

      HStack {
        CityContentView(
          city: city,
          isSelected: isSelected,
          userCoordinate: userCoordinate
        )
        .animation(animation, value: selectedCityId)
        .padding(padding)

        RemoveButton()
      }
      .geometryGroup()
    }
  }

  @ViewBuilder private func RemoveButton() -> some View {
    let padding = EdgeInsets.cityCell.with(vertical: 0)

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
          .padding(padding)
      }
    )
  }
}


#Preview {
  @Previewable @State var selectedCityId: Int?
  let city = City.moscow
  
  LazyVStack {
    CitySelectionHistoryRowView(
      selectedCityId: $selectedCityId,
      city: city,
      onRemove: {}
    )
    .border(Color.blue.opacity(0.1))
  }
}
