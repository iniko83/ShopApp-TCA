//
//  ToastContentView.swift
//  Utility
//
//  Created by Igor Nikolaev on 16.06.2025.
//

import SwiftUI

// Initialize explanations: [ https://stackoverflow.com/a/71383188 ]

public struct ToastContentView<Content: View>: View {
  private let style: ToastStyle
  
  @ViewBuilder private let content: () -> Content
  
  public init(
    style: ToastStyle = .init(),
    content: @escaping () -> Content
  ) {
    self.style = style
    self.content = content
  }
  
  public init(
    style: ToastStyle = .init(),
    markdown: AttributedString
  ) where Content == ToastMarkdownView {
    self.init(
      style: style,
      content: { ToastMarkdownView(markdown: markdown) }
    )
  }
  
  public init(
    style: ToastStyle = .init(),
    text: String
  ) where Content == ToastTextView {
    self.init(
      style: style,
      content: { ToastTextView(text: text) }
    )
  }
  
  public var body: some View {
    HStack {
      Image(systemName: style.iconSystemName())
        .foregroundStyle(style.color())
     
      content()
      
      Spacer()
    }
  }
}

public struct ToastMarkdownView: View {
  private let markdown: AttributedString
  
  fileprivate init(markdown: AttributedString) {
    self.markdown = markdown
  }
  
  public var body: some View {
    Text(markdown)
      .opacity(0.7)
  }
}

public struct ToastTextView: View {
  private let text: String
  
  fileprivate init(text: String) {
    self.text = text
  }
  
  public var body: some View {
    Text(text)
      .opacity(0.7)
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
                      style: style,
                      text: "This is \(name) toast."
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
