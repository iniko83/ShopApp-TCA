//
//  CircularColoredTimeoutView.swift
//  Utility
//
//  Created by Igor Nikolaev on 18.07.2025.
//

import SwiftUI

public struct CircularColoredTimeoutView: View {
  @Binding var timeout: TimeInterval

  @State private var progress: Double = 0
  @State private var strokeColor = Color.clear

  @ObservationIgnored @State private var timer = Timer
    .publish(every: 1, on: .main, in: .common)
    .autoconnect()

  private let data: TimeoutData<Color>
  @ObservationIgnored @State private var animationData: TimeoutData<Color>.AnimationData

  private let lineWidthPart: CGFloat

  public init(
    timeout: Binding<TimeInterval>,
    data: TimeoutData<Color>,
    lineWidthPart: CGFloat = 0.08
  ) {
    _timeout = timeout
    self.data = data
    self.lineWidthPart = lineWidthPart

    animationData = data.animationData(timeout: timeout.wrappedValue)
  }

  public var body: some View {
    GeometryReader { geometry in
      let side = geometry.size.minSide()
      let lineWidth = lineWidthPart * side

      CircularProgressView(
        lineWidth: lineWidth,
        progress: progress,
        strokeColor: strokeColor
      )
    }
    .onChange(of: timeout) { _, newValue in
      animationData = data.animationData(timeout: newValue)
      initiate()
    }
    .onReceive(timer) { _ in processPhase() }
    .onAppear { initiate() }
  }

  private func initiate() {
    updatePhase(animationData.initial)
    processPhase()
  }

  private func processPhase() {
    guard let item = animationData.fetchItem() else {
      timer.upstream.connect().cancel()
      return
    }

    let duration = item.duration
    timer = Timer.publish(every: duration, on: .main, in: .common).autoconnect()
    updatePhase(item.phase, animation: .linear(duration: duration))
  }

  private func updatePhase(
    _ phase: TimeoutData<Color>.Phase,
    animation: Animation? = nil
  ) {
    withAnimation(animation) {
      progress = phase.progress
      strokeColor = phase.value
    }
  }
}


#Preview {
  struct ContentView: View {
    @State private var timeout: TimeInterval = 1.5

    let timeoutData: TimeoutData<Color>

    var body: some View {
      VStack {
        Spacer()

        Text("Timeout: \(timeout, format: .number)")

        Button(
          action: { randomTimeout() },
          label: { Text("Random timeout") }
        )
        .buttonStyle(.mainBlueStyle)

        CircularColoredTimeoutView(
          timeout: $timeout,
          data: timeoutData
        )
        .frame(width: 300, height: 240)
        .background(Color.blue.opacity(0.2))

        Spacer()
      }
    }

    private func randomTimeout() {
      timeout = .random(in: 0.1...1.5)
    }
  }

  let timeoutData = TimeoutData<Color>(
    period: 1,
    phases: [
      .init(progress: 0.0, value: .red),
      .init(progress: 0.2, value: .orange),
      .init(progress: 0.5, value: .white),
      .init(progress: 1.0, value: .white),
    ]
  )

  return ContentView(timeoutData: timeoutData)
}
