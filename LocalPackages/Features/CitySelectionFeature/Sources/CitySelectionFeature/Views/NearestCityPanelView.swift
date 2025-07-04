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
    let isNearestCityHidden = nearestCity == nil
    ZStack {
      if let nearestCity {
        NearestCityView(city: nearestCity)
          .background(
            Color.white
              .clipShape(.rect(topLeadingRadius: 24, topTrailingRadius: 24))
              .shadow(radius: 16)
              .mask(Rectangle().padding(.top, -36))
              .ignoresSafeArea(.all, edges: .bottom)
          )
          .transition(.move(edge: .bottom))
      } else {
        DefineNearestCityButton(
          isProcessing: nearestCityRequestState.isProcessing,
          action: onTapDefineUserLocation
        )
        .padding([.horizontal, .bottom])
        .shadow(color: .mainBackground.opacity(0.2), radius: 6)
        .transition(
          .asymmetric(
            insertion: .opacity.combined(with: .move(edge: .bottom)),
            removal: .opacity
          )
        )
      }
    }
    .animation(.snappy, value: isNearestCityHidden)
    .frame(maxWidth: .infinity, alignment: .bottom)
  }
  
  @ViewBuilder private func NearestCityView(city: City) -> some View {
    let id = city.id
    let isSelected = selectedCityId == id
    let isProcessing = nearestCityRequestState.isProcessing
    
    ZStack {
      Button(
        action: { selectedCityId = id },
        label: { Color.clear }
      )
      .buttonStyle(.highlightingCell)
      
      HStack {
        VStack(spacing: 0) {
          Text("Ближайший город:")
            .font(.footnote)
            .frame(maxWidth: .infinity, alignment: .leading)
          
          CityContentView(
            city: city,
            isSelected: isSelected,
            userCoordinate: userCoordinate
          )
          .animation(.rowSelection, value: selectedCityId)
        }
        
        RefreshButton(
          isProcessing: isProcessing,
          action: { onTapDefineUserLocation() }
        )
        .frame(square: 36)
      }
      .padding(.cityCell)
    }
    .fixedSize(horizontal: false, vertical: true)
  }
}
