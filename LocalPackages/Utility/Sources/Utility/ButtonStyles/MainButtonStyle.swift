//
//  MainButtonStyle.swift
//  Utility
//
//  Created by Igor Nikolaev on 18.06.2025.
//

import SwiftUI

extension ButtonStyle where Self == MainButtonStyle {
  public static var mainBlueStyle: MainButtonStyle { .init(style: .blue) }
  public static var mainTransparentStyle: MainButtonStyle { .init(style: .transparent) }
}

public struct MainButtonStyle: ButtonStyle {
  @Environment(\.isEnabled) private var isEnabled: Bool
  
  private let style: Style
  private let shape: Shape
  private let contentPadding: EdgeInsets
  
  public init(
    style: Style = .init(),
    shape: Shape = .roundedRectangle(radius: 8),
    contentPadding: EdgeInsets = .buttonDefaultPadding
  ) {
    self.style = style
    self.shape = shape
    self.contentPadding = contentPadding
  }
  
  public func makeBody(configuration: Configuration) -> some View {
    let isPressed = configuration.isPressed
    let backgroundColor = style.backgroundColor(isPressed: isPressed)
    let frontColor = style.frontColor(isPressed: isPressed)
    let textOpacity: Double = isPressed ? 0.75 : 1
    
    return configuration.label
      .padding(contentPadding)
      .bold()
      .foregroundStyle(frontColor)
      .opacity(textOpacity)
      .background(backgroundColor)
      .mainButtonShape(shape)
      .scaleEffect(isPressed ? 0.995 : 1)
      .animation(.smooth, value: isPressed)
      .opacity(isEnabled ? 1 : 0.5)
      .animation(.smooth, value: isEnabled)
  }
}

extension MainButtonStyle {
  public enum Style: Int {
    case blue
    case transparent
    
    public init() {
      self = .blue
    }
    
    fileprivate func backgroundColor(isPressed: Bool) -> Color {
      let result: Color
      switch self {
      case .blue:
        let brightness = brightness(isPressed: isPressed)
        result = .mainBackground.adjust(brightness: brightness)
        
      case .transparent:
        result = .transparent
      }
      return result
    }
    
    fileprivate func frontColor(isPressed: Bool) -> Color {
      let brightness = brightness(isPressed: isPressed)
      
      let result: Color
      switch self {
      case .blue:
        result = .white.adjust(brightness: brightness)
        
      case .transparent:
        result = .mainBackground.adjust(brightness: brightness)
      }
      return result
    }
    
    private func brightness(isPressed: Bool) -> Double {
      isPressed ? -0.1 : 0
    }
  }
  
  public enum Shape {
    case capsule
    case roundedRectangle(radius: CGFloat)
  }
}


/// Shape ViewModifier
private extension View {
  func mainButtonShape(_ shape: MainButtonStyle.Shape) -> some View {
    modifier(MainButtonShapeModifier(shape: shape))
  }
}

private struct MainButtonShapeModifier: ViewModifier {
  private let shape: MainButtonStyle.Shape
  
  init(shape: MainButtonStyle.Shape) {
    self.shape = shape
  }
  
  func body(content: Content) -> some View {
    switch shape {
    case .capsule:
      content.clipShape(Capsule())
      
    case let .roundedRectangle(radius):
      content.cornerRadius(radius)
    }
  }
}


#Preview {
  struct Item: Equatable {
    let name: String
    let style: MainButtonStyle.Style
    
    static func == (lhs: Item, rhs: Item) -> Bool {
      lhs.name == rhs.name
    }
  }
  
  struct ContentView: View {
    private let items: [Item] = [
      .init(name: "Blue", style: .blue),
      .init(name: "Transparent", style: .transparent)
    ]
    
    @State private var isDarkTheme = false
    @State private var isDisabled = false
    @State private var isShowBackground = true
  
    var body: some View {
      let panelColor: Color = isShowBackground
        ? isDarkTheme
          ? .red.opacity(0.3)
          : .blue.opacity(0.1)
        : .clear
      
      let buttonPadding: EdgeInsets = isShowBackground
        ? .init(value: 8)
        : .init(horizontal: 8, vertical: 0)
      
      VStack {
        Toggle("Dark theme", isOn: $isDarkTheme)
        Toggle("isDisabled", isOn: $isDisabled)
        Toggle("Show background", isOn: $isShowBackground)
        
        ScrollView {
          VStack {
            ForEach(items, id: \.style.rawValue) { item in
              Button(
                action: {},
                label: {
                  Text(item.name)
                    .frame(maxWidth: .infinity)
                }
              )
              .disabled(isDisabled)
              .buttonStyle(
                MainButtonStyle(style: item.style, shape: .capsule)
              )
              .padding(buttonPadding)
              .background(panelColor)
            }
          }
          .animation(.smooth, value: isShowBackground)
        }
        .scrollBounceBehavior(.basedOnSize, axes: .vertical)
      }
      .preferredColorScheme(isDarkTheme ? .dark : .light)
      .padding()
    }
  }
  
  return ContentView()
}
