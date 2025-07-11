//
//  CityToastListView.swift
//  CitySelectionFeature
//
//  Created by Igor Nikolaev on 01.07.2025.
//

import SwiftUI
import Utility

public enum CityToastAction {
  case removeItem(CityToastItem)
}

struct CityToastListView: View {
  @State private var contentHeight: CGFloat = 1
  let items: [CityToastItem]
  let onAction: (CityToastAction) -> Void
  
  var body: some View {
    let maximumHeight: CGFloat = 150
    let scrollVerticalInset: CGFloat = 12
    
    ZStack(alignment: .bottom) {
      Color.clear
        .frame(height: maximumHeight)
      
      ScrollView {
        VStack(spacing: 12) {
          ForEach(items, id: \.hashValue) { item in
            ToastView(item)
              .transition(.opacity.combined(with: .move(edge: .bottom)))
          }
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal)
        .onGeometryChange(
          for: CGFloat.self,
          of: { $0.size.height },
          action: { value in
            contentHeight = min(maximumHeight, value + 2 * scrollVerticalInset)
          }
        )
      }
      .scrollIndicators(.hidden)
      .contentMargins(.vertical, scrollVerticalInset)
      .scrollBounceBehavior(.basedOnSize, axes: .vertical)
      .frame(height: contentHeight)
      .animation(.smooth, value: items)
      .animation(.smooth, value: contentHeight)
    }
    .verticalGradientMask(padding: scrollVerticalInset)
    .padding(.vertical, -12)
  }
  
  @ViewBuilder private func ToastView(_ item: CityToastItem) -> some View {
    switch item {
    case .citySelectionRequired:
      makeToast(style: .information) { style in
        ToastContentView(
          style: style,
          text: "Выберите город для продолжения работы."
        )
      }
    
    case .nearestCityFetchFailure:
      makeToast(style: .error) { style in
        ClosableToastContentView(
          style: style,
          onClose: { onAction(.removeItem(item)) },
          content: {
            ToastContentView(
              style: style,
              text: "Не удалось определить ближайший город."
            )
          }
        )
      }
    }
  }
  
  @ViewBuilder private func makeToast<Content: View>(
    style: ToastStyle,
    content: (ToastStyle) -> Content
  ) -> some View {
    content(style)
      .toast(
        style,
        cornerRadius: 10,
        padding: EdgeInsets(horizontal: 8, vertical: 8)
      )
  }
}
