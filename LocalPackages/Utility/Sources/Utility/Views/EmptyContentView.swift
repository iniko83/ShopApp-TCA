//
//  EmptyContentView.swift
//  Utility
//
//  Created by Igor Nikolaev on 11.07.2025.
//

import SwiftUI

public struct EmptyContentView: View {
  let iconSystemName: String
  let message: String

  public init(
    iconSystemName: String,
    message: String
  ) {
    self.iconSystemName = iconSystemName
    self.message = message
  }

  public var body: some View {
    GeometryReader { geometry in
      let width = geometry.size.width
      let iconWidth = max(24, 0.125 * width)

      ScrollView {
        VStack(spacing: 0) {
          Spacer()
          ContentView(iconWidth: iconWidth)
          Spacer()
        }
        .frame(width: width, height: geometry.size.height)
      }
      .scrollBounceBehavior(.basedOnSize, axes: [.vertical])
    }
  }

  @ViewBuilder private func ContentView(iconWidth: CGFloat) -> some View {
    VStack(alignment: .center, spacing: 0) {
      Image(systemName: iconSystemName)
        .resizable()
        .aspectRatio(contentMode: .fit)
        .frame(maxWidth: iconWidth)
        .padding(.bottom, 16)

      Text(message)
        .font(.callout)
        .multilineTextAlignment(.center)
    }
    .geometryGroup()
  }
}


#Preview {
  EmptyContentView(
    iconSystemName: "magnifyingglass",
    message: "Поиск не дал результатов"
  )
  .ignoresSafeArea()
}
