//
//  CitySelectionUndoToastView.swift
//  CitySelectionFeature
//
//  Created by Igor Nikolaev on 17.07.2025.
//

import SwiftUI
import Utility

struct CitySelectionUndoToastView<Content: View>: View {
  @State private var timeout: TimeInterval = 0

  let style: ToastStyle
  let deletionTimestamp: TimeInterval
  let onTapUndo: () -> Void

  @ViewBuilder private let content: () -> Content

  public init(
    style: ToastStyle = .init(),
    deletionTimestamp: TimeInterval,
    onTapUndo: @escaping () -> Void,
    content: @escaping () -> Content
  ) {
    self.style = style
    self.deletionTimestamp = deletionTimestamp
    self.onTapUndo = onTapUndo
    self.content = content
  }

  var body: some View {
    HStack(spacing: 0) {
      content()
        .frame(maxWidth: .infinity)

      ZStack {
        CircularColoredTimeoutView(
          timeout: $timeout,
          data: Self.timeoutData()
        )
        .scaleEffect(x: -1)
        .rotationEffect(.degrees(90))

        Button(
          action: onTapUndo,
          label: {
            Image(systemName: "arrow.uturn.down")
              .resizable()
              .aspectRatio(contentMode: .fit)
              .frame(square: 20)
              .foregroundStyle(style.color())
              .frame(maxSquare: .infinity)
          }
        )
      }
      .frame(width: 48, height: 32)
    }
    .onAppear { timeout = deletionTimestamp - Timestamp.now() }
  }

  private static func timeoutData() -> TimeoutData<Color> {
    .init(
      period: .undoTimeout,
      phases: [
        .init(progress: 0.0, value: .red),
        .init(progress: 0.1, value: .red),
        .init(progress: 0.4, value: .orange),
        .init(progress: 0.7, value: .white),
        .init(progress: 1.0, value: .white),
      ]
    )
  }
}


#Preview {
  let deletionTimestamp = Timestamp.now() + .undoTimeout
  let style = ToastStyle.information
  let toastPadding = EdgeInsets(top: 4, leading: 8, bottom: 4, trailing: 0)

  CitySelectionUndoToastView(
    style: style,
    deletionTimestamp: deletionTimestamp,
    onTapUndo: {},
    content: {
      Text("Отменить удаление города?")
        .opacity(0.7)
        .frame(maxWidth: .infinity, alignment: .leading)
    }
  )
  .toast(
    style,
    cornerRadius: 10,
    padding: toastPadding
  )
  .padding()
}
