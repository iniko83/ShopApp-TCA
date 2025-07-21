//
//  CircularProgressView.swift
//  Utility
//
//  Created by Igor Nikolaev on 18.07.2025.
//

import SwiftUI

public struct CircularProgressView: View {
  let lineWidth: CGFloat
  let progress: CGFloat
  let strokeColor: Color

  public init(
    lineWidth: CGFloat,
    progress: CGFloat,
    strokeColor: Color
  ) {
    self.lineWidth = lineWidth
    self.progress = progress
    self.strokeColor = strokeColor
  }

  public var body: some View {
    Circle()
      .inset(by: 0.5 * lineWidth)
      .trim(from: 0, to: progress)
      .stroke(
        strokeColor,
        style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)
      )
  }
}


#Preview {
  @Previewable @State var isFilled = false

  VStack {
    Toggle("isFilled", isOn: $isFilled)

    Spacer()

    CircularProgressView(
      lineWidth: 20,
      progress: isFilled ? 1 : 0,
      strokeColor: .red
    )
    .rotationEffect(.degrees(-90))
    .scaleEffect(x: -1)
    .frame(width: 300, height: 240)
    .animation(.linear(duration: 1), value: isFilled)
    .background(Color.blue.opacity(0.2))

    Spacer()
  }
  .padding()
}
