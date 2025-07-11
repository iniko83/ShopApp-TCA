//
//  CityQueryToastView.swift
//  CitySelectionFeature
//
//  Created by Igor Nikolaev on 25.06.2025.
//

import SwiftUI
import Utility

struct CityQueryToastView: View {
  let invalidSymbols: String
  let onClose: () -> Void
  
  var body: some View {
    let style = ToastStyle.warning
    let message = "Удалены недопустимые символы: **\(invalidSymbols)**"
    
    ClosableToastContentView(
      style: style,
      onClose: onClose,
      content: {
        ToastContentView(
          style: style,
          content: {
            Text(message.markdown()!)
              .font(.subheadline)
              .opacity(0.7)
          }
        )
      }
    )
    .toast(
      style,
      cornerRadius: 10,
      padding: EdgeInsets(horizontal: 8, vertical: 4)
    )
  }
}
