//
//  ToastContentView.swift
//  Utility
//
//  Created by Igor Nikolaev on 16.06.2025.
//

import SwiftUI

public struct ToastContentView: View {
  private let text: String
  private let style: ToastStyle
  
  init(
    text: String,
    style: ToastStyle = .init()
  ) {
    self.text = text
    self.style = style
  }
  
  public var body: some View {
    HStack {
      Image(systemName: style.iconSystemName())
        .foregroundStyle(style.color())
      Text(text)
        .opacity(0.7)
      Spacer()
    }
  }
}

#Preview {
  struct Item: Equatable {
    let name: String
    let style: ToastStyle

    static func == (lhs: Item, rhs: Item) -> Bool {
      lhs.name == rhs.name
    }
  }
  
  struct ContentView: View {
    static let initialItems: [Item] = [
      .init(name: "information", style: .information),
      .init(name: "success", style: .success),
      .init(name: "error", style: .error),
      .init(name: "warning", style: .warning)
    ]
    
    @State private var isDarkTheme = false
    @State private var items = Self.initialItems
    
    var body: some View {
      let isCanResetItems = items.count < Self.initialItems.count
      
      VStack {
        Toggle("Dark theme", isOn: $isDarkTheme)
        
        if isCanResetItems {
          Button(
            action: { items = Self.initialItems },
            label: {
              Text("Reset items")
                .foregroundStyle(.white)
            }
          )
          .tint(.red.opacity(0.5))
          .buttonStyle(.borderedProminent)
          .transition(
            .scale(0.5)
            .combined(with: .opacity)
            .animation(.smooth)
          )
        }
        
        Image(systemName: "info.circle")
          .resizable()
          .aspectRatio(contentMode: .fit)
          .foregroundStyle(Color.blue.opacity(0.5))
          .background(Color.blue.opacity(0.1))
          .overlay {
            VStack {
              ForEach(items, id: \.style.rawValue) { item in
                let style = item.style
                let name = item.name
                
                ClosableToastContentView(
                  style: style,
                  onClose: {
                    items = items.filter { $0.name != name }
                  },
                  content: {
                    ToastContentView(
                      text: "This is \(name) toast.",
                      style: style
                    )
                  }
                )
                .toast(style)
              }
            }
            .frame(maxHeight: .infinity, alignment: .bottom)
            .animation(.smooth, value: items)
          }
          .clipShape(
            RoundedRectangle(
              cornerSize: CGSize(width: 16, height: 16),
              style: .continuous
            )
          )
      }
      .preferredColorScheme(isDarkTheme ? .dark : .light)
      .padding()
      .animation(.smooth, value: isCanResetItems)
    }
  }
  
  return ContentView()
}
