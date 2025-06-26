//
//  NearestCityPanelView.swift
//  CitySelectionFeature
//
//  Created by Igor Nikolaev on 26.06.2025.
//

import SwiftUI
import Utility

struct NearestCityPanelView: View {
  @Binding var selectedCityId: Int?
  
  private let nearestCity: City?
  private let nearestCityRequestState: RequestLocationState
  
  private let userCoordinate: Coordinate?
  
  private let onTapDefineUserLocation: () -> Void
  
  init(
    selectedCityId: Binding<Int?>,
    nearestCity: City?,
    nearestCityRequestState: RequestLocationState,
    userCoordinate: Coordinate?,
    onTapDefineUserLocation: @escaping () -> Void
  ) {
    _selectedCityId = selectedCityId
    self.nearestCity = nearestCity
    self.nearestCityRequestState = nearestCityRequestState
    self.userCoordinate = userCoordinate
    self.onTapDefineUserLocation = onTapDefineUserLocation
  }
  
  var body: some View {
    ZStack {
      if let nearestCity {
        // FIXME: add nearest city when cities & location managers implemented in store
      } else {
        DefineNearestCityButton(
          isProcessing: nearestCityRequestState.isProcessing,
          action: onTapDefineUserLocation
        )
        .padding()
        .shadow(color: .mainBackground.opacity(0.2), radius: 6)
      }
    }
    .frame(maxWidth: .infinity, alignment: .bottom)
    .ignoresSafeArea(.keyboard, edges: .bottom)
  }
}
