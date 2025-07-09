//
//  CityListView.swift
//  CitySelectionFeature
//
//  Created by Igor Nikolaev on 19.06.2025.
//

import SwiftUI
import Utility

struct CityListView: View {
  @Binding var selectedCityId: Int?
  @Binding var sections: [CityTableSection]
  
  @State private var scrollPositionCityId: Int?
  
  private let cities: [City]
  private let userCoordinate: Coordinate?
  
  private let insets: EdgeInsets
  
  init(
    selectedCityId: Binding<Int?>,
    sections: Binding<[CityTableSection]>,
    cities: [City],
    userCoordinate: Coordinate?,
    insets: EdgeInsets
  ) {
    _selectedCityId = selectedCityId
    _sections = sections
    self.cities = cities
    self.userCoordinate = userCoordinate
    self.insets = insets
  }
  
  var body: some View {
    ScrollView {
      LazyVStack(spacing: 0, pinnedViews: [.sectionHeaders]) {
        ForEach(sections, id: \.id) { section in
          Section(
            content: {
              ForEach(section.ids, id: \.self) { id in
                if let city = cities[safe: id] {
                  CityRowView(
                    selectedCityId: $selectedCityId,
                    city: city,
                    userCoordinate: userCoordinate
                  )
                  .animation(.rowSelection, value: selectedCityId)
                }
              }
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
    .scrollPosition(id: $scrollPositionCityId)
    .animation(.smooth, value: scrollPositionCityId)
    .onChange(of: sections) { (_, newValue) in
      guard let id = newValue.first?.ids.first else { return }
      scrollPositionCityId = id
    }
  }
}
