//
//  ClosableToastContentView.swift
//  Utility
//
//  Created by Igor Nikolaev on 16.06.2025.
//

import SwiftUI

public struct ClosableToastContentView<Content: View>: View {
  @State private var isClosed = false
  
  @ViewBuilder private let content: () -> Content
  
  private let style: ToastStyle
  private let onClose: () -> Void
  
  public init(
    style: ToastStyle = .init(),
    onClose: @escaping () -> Void,
    content: @escaping () -> Content
  ) {
    self.style = style
    self.onClose = onClose
    self.content = content
  }
  
  public var body: some View {
    HStack(spacing: 0) {
      content()
      
      Button(
        action: onClose,
        label: {
          Image(systemName: "xmark")
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: 16, height: 16)
            .padding(EdgeInsets(top: 4, leading: 8, bottom: 4, trailing: 8))
            .offset(x: 8, y: 0)
        }
      )
      .disabled(isClosed)
      .contentShape(Rectangle())
      .tint(style.color())
      .buttonStyle(
        ToastCloseButtonStyle(
          isClosed: $isClosed,
          style: style
        )
      )
    }
    .animation(.smooth, value: isClosed)
  }
}
