//
//  RequestErrorView.swift
//  Utility
//
//  Created by Igor Nikolaev on 18.06.2025.
//

import SwiftUI
import NetworkClient

public struct RequestErrorView: View {
  private let configuration: Configuration
  private let retryAction: (() -> Void)?
  
  public init(
    configuration: Configuration,
    retryAction: (() -> Void)? = nil
  ) {
    self.configuration = configuration
    self.retryAction = retryAction
  }
  
  public var body: some View {
    GeometryReader { geometry in
      let size = geometry.size
      let iconWidth = 0.6 * size.minSide()
      
      VStack(alignment: .center) {
        Spacer()
        IconView()
          .frame(maxWidth: iconWidth)
          .padding(.bottom, 30)
        TextsView()
        
        if
          configuration.isRetryable,
          let action = retryAction
        {
          Button(
            action: { action() },
            label: {
              Text(String.retry.uppercased())
                .frame(maxWidth: .infinity)
                .multilineTextAlignment(.center)
            }
          )
          .buttonStyle(.mainBlueStyle)
          .padding(.top, 30)
        }
        
        Spacer()
      }
      .frame(width: size.width)
    }
  }
  
  @ViewBuilder private func IconView() -> some View {
    Image(systemName: configuration.iconSystemName)
      .resizable()
      .aspectRatio(contentMode: .fit)
      .symbolRenderingMode(.palette)
      .foregroundStyle(Color.mainAccent, Color.mainBackground)
      .iconSymbolEffect()
  }
  
  @ViewBuilder private func TextsView() -> some View {
    VStack(alignment: .center, spacing: 0) {
      Text(configuration.title)
        .font(.headline)
        .multilineTextAlignment(.center)
        .padding(.bottom, 12)
      
      if let message = configuration.message {
        Text(message)
          .font(.callout)
          .multilineTextAlignment(.center)
      }
    }
  }
}

extension RequestErrorView {
  public struct Configuration: Equatable {
    public let iconSystemName: String
    public let title: String
    public let message: String?
    
    public let isRetryable: Bool
    
    public init(
      iconSystemName: String,
      title: String,
      message: String? = nil,
      isRetryable: Bool = true
    ) {
      self.iconSystemName = iconSystemName
      self.title = title
      self.message = message
      self.isRetryable = isRetryable
    }
    
    public init(
      error: RequestError,
      message: String? = nil
    ) {
      self.init(
        iconSystemName: Self.iconSystemName(errorType: error.type),
        title: Self.title(errorType: error.type),
        message: message,
        isRetryable: error.isRetryable()
      )
    }
    
    private static func iconSystemName(errorType: RequestErrorType) -> String {
      let result: String
      switch errorType {
      case .connectionLost:
        result = "wifi.slash"
      default:
        result = "wrench.and.screwdriver"
      }
      return result
    }
      
    private static func title(errorType: RequestErrorType) -> String {
      let result: String
      switch errorType {
      case .unknown, .decoding, .encoding, .wrongUrl, .requestFailed:
        result = "Ошибка сервера"
      case .updateApplication:
        result = "Неподдерживаемая версия приложения"
      case .unauthorizedUser:
        result = "Необходима авторизация"
      case .connectionLost:
        result = "Отсутствие интернет-соединения"
      case .serverOffline:
        result = "Обслуживание сервера"
      }
      return result
    }
  }
}


#Preview {
  RequestErrorView(
    configuration: .init(
      error: .connectionLost,
      message: "Текст сообщения"
    )
  )
  .border(Color.blue.opacity(0.1))
  .padding()
}
