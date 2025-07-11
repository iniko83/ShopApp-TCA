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
  let city: City?
  let isProcessing: Bool
  let userCoordinate: Coordinate?
  let onTapDefineUserLocation: () -> Void
  
  var body: some View {
    let isCityHidden = city == nil
    ZStack {
      if let city {
        NearestCityView(city)
          .background(
            Color.white
              .clipShape(.rect(topLeadingRadius: 24, topTrailingRadius: 24))
              .shadow(radius: 16)
              .mask(Rectangle().padding(.top, -36))
              .ignoresSafeArea(.all, edges: .bottom)
          )
          .transition(.opacity.combined(with: .move(edge: .bottom)))
      } else {
        DefineNearestCityButton(
          isProcessing: isProcessing,
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
    .animation(.snappy, value: isCityHidden)
    .frame(maxWidth: .infinity, alignment: .bottom)
  }
  
  @ViewBuilder private func NearestCityView(_ city: City) -> some View {
    let id = city.id
    let isSelected = selectedCityId == id

    ZStack {
      CellHighlightingButton(action: { selectedCityId = id })

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
          action: onTapDefineUserLocation
        )
        .frame(square: 36)
      }
      .padding(.cityCell)
    }
    .fixedSize(horizontal: false, vertical: true)
  }
}


#Preview {
  @Previewable @State var isDefaultCity = false
  @Previewable @State var isProcessing = false
  @Previewable @State var selectedCityId: Int?

  VStack(spacing: 0) {
    Spacer()

    VStack {
      Toggle("isDefaultCity", isOn: $isDefaultCity)
      Toggle("isProcessing", isOn: $isProcessing)
    }
    .padding()

    let city: City? = isDefaultCity ? .moscow : nil

    Spacer()

    NearestCityPanelView(
      selectedCityId: $selectedCityId,
      city: city,
      isProcessing: isProcessing,
      userCoordinate: nil,
      onTapDefineUserLocation: { isDefaultCity = true }
    )
  }
}
