//
//  PreventPassthoughTouches+ViewModifier.swift
//  Utility
//
//  Created by Igor Nikolaev on 25.06.2025.
//

import SwiftUI

extension View {
  public func preventPassthoughTouches() -> some View {
    modifier(PreventPassthoughTouchesModifier())
  }
}

struct PreventPassthoughTouchesModifier: ViewModifier {
  func body(content: Content) -> some View {
    content
      .background {
        PreventPassthoughTouchesView()
      }
  }
}

struct PreventPassthoughTouchesView: View {
  var body: some View {
    Button(action: {}) {
      Color.clear
    }
  }
}
