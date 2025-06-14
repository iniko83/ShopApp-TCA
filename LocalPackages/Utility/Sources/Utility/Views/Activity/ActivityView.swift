//
//  ActivityView.swift
//  Utility
//
//  Created by Igor Nikolaev on 14.06.2025.
//

import SwiftUI

public struct ActivityView: View {
  private let style: ActivityStyle
  
  public init(style: ActivityStyle = .init()) {
    self.style = style
  }
  
  public var body: some View {
    switch style {
    case .ballRotateChase:
      ActivityBallRotateChaseView()
      
    case let .spinner(configuration):
      ActivitySpinnerView(configuration: configuration)
    }
  }
}


#Preview {
  let styles: [ActivityStyle] = [
    .ballRotateChase,
    .spinner()
  ]
  
  VStack(spacing: 16) {
    ForEach(Array(styles.enumerated()), id: \.offset) { (_, style) in
      ActivityView(style: style)
        .tint(.red)
        .opacity(0.5)
        .frame(width: 120, height: 120)
    }
  }
}
