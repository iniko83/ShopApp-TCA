//
//  CitySelectionQueryToastView.swift
//  CitySelectionFeature
//
//  Created by Igor Nikolaev on 25.06.2025.
//

import SwiftUI
import Utility

struct CitySelectionQueryToastView: View {
  let invalidSymbols: String
  let onClose: () -> Void
  
  var body: some View {
    let style = ToastStyle.warning

    ClosableToastContentView(
      style: style,
      onClose: onClose,
      content: {
        ToastContentView(
          style: style,
          content: { ContentView() }
        )
      }
    )
    .toast(
      style,
      cornerRadius: 10,
      padding: EdgeInsets(horizontal: 8, vertical: 4)
    )
  }

  @ViewBuilder private func ContentView() -> some View {
    let message = "Удалены недопустимые символы: **\(invalidSymbols)**"

    Text(message.markdown()!)
      .font(.subheadline)
      .opacity(0.7)
  }
}
