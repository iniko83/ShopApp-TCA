//
//  CityListView.swift
//  CitySelectionFeature
//
//  Created by Igor Nikolaev on 19.06.2025.
//

import SwiftUI
import Utility

struct CityListView: View {
  private let cities: [City]
  private let selectedCityId: Int?

  private let nearestCity: City?
  private let userCoordinateRequestState: RequestLocationState
  
  private let onAction: (Action) -> Void
  
  init(
    cities: [City],
    selectedCityId: Int?,
    nearestCity: City?,
    userCoordinateRequestState: RequestLocationState,
    onAction: @escaping (Action) -> Void
  ) {
    self.cities = cities
    self.selectedCityId = selectedCityId
    self.nearestCity = nearestCity
    self.userCoordinateRequestState = userCoordinateRequestState
    self.onAction = onAction
  }
  
  var body: some View {
    ZStack {
      ScrollView {
        LazyVStack(
          spacing: 0,
          content: {
            ForEach(cities, id: \.id) { city in
              let isSelected = city.id == selectedCityId
              CityContentView(city: city, isSelected: isSelected)
                .padding(EdgeInsets(horizontal: 16, vertical: 6))
            }
          }
        )
        .animation(.smooth, value: cities)
      }
      .scrollBounceBehavior(.basedOnSize, axes: [.vertical])
      
      VStack {
        if let nearestCity {
          // FIXME: add nearest city when cities & location managers implemented in store
        } else {
          DefineNearestCityButton(
            isProcessing: userCoordinateRequestState.isProcessing,
            action: { onAction(.tapDefineUserLocation) }
          )
          .shadow(color: .mainBackground.opacity(0.2), radius: 6)
        }
      }
      .padding()
      .frame(maxHeight: .infinity, alignment: .bottom)
    }
  }
}

extension CityListView {
  enum Action {
    case tapDefineUserLocation
  }
}
