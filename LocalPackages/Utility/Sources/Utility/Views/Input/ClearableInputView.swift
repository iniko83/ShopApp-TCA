//
//  ClearableInputView.swift
//  Utility
//
//  Created by Igor Nikolaev on 23.06.2025.
//

import SwiftUI

public struct ClearableInputView<Content: View>: View {
  @Binding public var isClearHidden: Bool
  @Binding public var isEnabled: Bool
  
  @ViewBuilder private let content: () -> Content
  
  private let onClear: () -> Void
  
  public init(
    isClearHidden: Binding<Bool>,
    isEnabled: Binding<Bool> = .constant(true),
    onClear: @escaping () -> Void,
    content: @escaping () -> Content
  ) {
    _isClearHidden = isClearHidden
    _isEnabled = isEnabled
    self.onClear = onClear
    self.content = content
  }
  
  public var body: some View {
    HStack(spacing: 0) {
      content()
      
      if !isClearHidden {
        Button(
          action: { onClear() },
          label: {
            Image(systemName: "xmark")
              .resizable()
              .aspectRatio(contentMode: .fit)
              .frame(square: 16)
              .padding(8)
          }
        )
        .disabled(!isEnabled)
        .contentShape(Rectangle())
        .tint(.secondary)
        .buttonStyle(InputClearButtonStyle(isClosed: $isClearHidden))
        .transition(
          .scale(0.5)
          .combined(with: .opacity)
        )
      }
    }
    .animation(.smooth, value: isClearHidden)
  }
}
