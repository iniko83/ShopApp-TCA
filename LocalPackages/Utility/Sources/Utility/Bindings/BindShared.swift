//
//  BindShared.swift
//  Utility
//
//  Created by Igor Nikolaev on 14.07.2025.
//

import ComposableArchitecture
import SwiftUI

// Based on: [ https://github.com/pointfreeco/swift-navigation/blob/main/Sources/SwiftNavigation/Bind.swift ]
extension View {
  public func bindShared<ModelValue: Equatable, ViewValue: _Bindable>(
    _ modelValue: Shared<ModelValue>, to viewValue: ViewValue
  ) -> some View
  where ModelValue == ViewValue.Value {
    modifier(_BindShared(modelValue: modelValue, viewValue: viewValue))
  }
}

private struct _BindShared<ModelValue: Equatable, ViewValue: _Bindable>: ViewModifier
  where ModelValue == ViewValue.Value
{
  let modelValue: Shared<ModelValue>
  let viewValue: ViewValue

  @State private var hasAppeared = false

  func body(content: Content) -> some View {
    content
      .onAppear {
        guard !hasAppeared else { return }
        hasAppeared = true
        guard viewValue.wrappedValue != modelValue.wrappedValue else { return }
        viewValue.wrappedValue = modelValue.wrappedValue
      }
      .onChange(of: modelValue.wrappedValue, { _, newValue in
        guard viewValue.wrappedValue != newValue else { return }
        viewValue.wrappedValue = newValue
      })
      .onChange(of: viewValue.wrappedValue, { _, newValue in
        guard modelValue.wrappedValue != newValue else { return }
        modelValue.withLock { $0 = newValue }
      })
  }
}
