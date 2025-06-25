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
  
  private let cities: [City]

  private let nearestCity: City?
  private let nearestCityRequestState: RequestLocationState
  private let userCoordinate: Coordinate?
  
  private let onAction: (Action) -> Void
  
  init(
    selectedCityId: Binding<Int?>,
    sections: Binding<[CityTableSection]>,
    cities: [City],
    nearestCity: City?,
    nearestCityRequestState: RequestLocationState,
    userCoordinate: Coordinate?,
    onAction: @escaping (Action) -> Void
  ) {
    _selectedCityId = selectedCityId
    _sections = sections
    self.cities = cities
    self.nearestCity = nearestCity
    self.nearestCityRequestState = nearestCityRequestState
    self.userCoordinate = userCoordinate
    self.onAction = onAction
  }
  
  var body: some View {
    ZStack {
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
          }
        }
        .animation(.smooth, value: sections)
      }
      
      VStack {
        if let nearestCity {
          // FIXME: add nearest city when cities & location managers implemented in store
        } else {
          DefineNearestCityButton(
            isProcessing: nearestCityRequestState.isProcessing,
            action: { onAction(.tapDefineUserLocation) }
          )
          .shadow(color: .mainBackground.opacity(0.2), radius: 6)
        }
      }
      .padding()
      .frame(maxHeight: .infinity, alignment: .bottom)
      .ignoresSafeArea(.keyboard, edges: .bottom)
    }
  }
}

extension CityListView {
  enum Action {
    case tapDefineUserLocation
  }
}
