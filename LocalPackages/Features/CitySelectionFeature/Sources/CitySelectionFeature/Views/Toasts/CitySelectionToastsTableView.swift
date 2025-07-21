//
//  CitySelectionToastsTableView.swift
//  CitySelectionFeature
//
//  Created by Igor Nikolaev on 01.07.2025.
//

import SwiftUI
import Utility

public enum CitySelectionToastAction {
  case removeItem(CitySelectionToastItem)
  case undoItem(CitySelectionToastItem)
}

struct CitySelectionToastsTableView: View {
  @State private var contentHeight: CGFloat = 1
  @State private var scrollPositionId: Int?

  let toasts: [Toast]
  let onAction: (ToastAction) -> Void

  var body: some View {
    let maximumHeight: CGFloat = 150
    let scrollVerticalInset: CGFloat = 12
    
    ZStack(alignment: .bottom) {
      Color.clear
        .frame(height: maximumHeight)

      ScrollView {
        VStack(spacing: 12) {
          ForEach(toasts, id: \.item.hashValue) { toast in
            ToastView(toast)
              .transition(.opacity.combined(with: .move(edge: .bottom)))
              .id(toast.id)
          }
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal)
        .scrollTargetLayout()
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
      .animation(.smooth, value: toasts)
      .animation(.smooth, value: contentHeight)
      .scrollPosition(id: $scrollPositionId)
      .animation(.smooth, value: scrollPositionId)
      .onChange(of: toasts) { _, newValue in
        guard
          let id = newValue.last?.id,
          scrollPositionId != id
        else { return }

        scrollPositionId = id
      }
    }
    .verticalGradientMask(padding: scrollVerticalInset)
    .padding(.vertical, -12)
  }
  
  @ViewBuilder private func ToastView(_ toast: Toast) -> some View {
    let item = toast.item

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

    case let .undoRemoveSelectionHistoryCity(city):
      let deletionTimestamp = toast.timeoutStamp ?? 0
      let markdown = "Восстановить ранее выбранный город **\"\(city.name)\"**?".markdown()!

      makeToast(style: .information, padding: .undoPadding) { style in
        CitySelectionUndoToastView(
          style: style,
          deletionTimestamp: deletionTimestamp,
          onTapUndo: { onAction(.undoItem(item)) },
          content: {
            ToastContentView(
              style: style,
              markdown: markdown
            )
          }
        )
      }
    }
  }

  @ViewBuilder private func makeToast<Content: View>(
    style: ToastStyle,
    padding: EdgeInsets = .defaultPadding,
    content: (ToastStyle) -> Content
  ) -> some View {
    content(style)
      .toast(
        style,
        cornerRadius: 10,
        padding: padding
      )
  }
}


// Constants
private extension EdgeInsets {
  static let defaultPadding = EdgeInsets(horizontal: 8, vertical: 8)
  static let undoPadding = EdgeInsets(top: 4, leading: 8, bottom: 4, trailing: 0)
}
