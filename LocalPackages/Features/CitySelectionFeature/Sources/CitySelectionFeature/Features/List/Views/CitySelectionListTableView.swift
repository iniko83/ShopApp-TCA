//
//  CitySelectionListTableView.swift
//  CitySelectionFeature
//
//  Created by Igor Nikolaev on 19.06.2025.
//

import SwiftUI
import Utility

struct CitySelectionListTableView: View {
  @Binding var selectedCityId: Int?
  @State private var scrollPositionCityId: Int?

  let sections: [ListSection]
  let userCoordinate: Coordinate?

  let insets: EdgeInsets

  init(
    selectedCityId: Binding<Int?>,
    sections: [ListSection],
    userCoordinate: Coordinate?,
    insets: EdgeInsets
  ) {
    _selectedCityId = selectedCityId
    self.sections = sections
    self.userCoordinate = userCoordinate
    self.insets = insets
  }
  
  var body: some View {
    ScrollView {
      LazyVStack(spacing: 0, pinnedViews: [.sectionHeaders]) {
        ForEach(sections, id: \.id) { section in
          Section(
            content: {
              ForEach(section.cities, id: \.id) { RowView(city: $0) }
            },
            header: { CitySectionHeaderView(kind: section.kind) }
          )
          .scrollTargetLayout()
        }
      }
      .animation(.smooth, value: sections)
    }
    .contentMargins(.all, insets, for: .automatic)
    // FIXME: sometimes scroll animation position cell at header place
    // FIXME: may be solution: https://stackoverflow.com/a/78033285
    // FIXME: or may be use List instead (sometimes cells jump from bottom to top via scrolling)
    .scrollPosition(id: $scrollPositionCityId)
    .animation(.smooth, value: scrollPositionCityId)
    .onChange(of: sections) { (_, newValue) in
      guard let id = newValue.first?.cities.first?.id else { return }
      scrollPositionCityId = id
    }
  }

  @ViewBuilder private func RowView(city: City) -> some View {
    CitySelectionRowView(
      selectedCityId: $selectedCityId,
      city: city,
      userCoordinate: userCoordinate
    )
    .animation(.rowSelection, value: selectedCityId)
  }
}
