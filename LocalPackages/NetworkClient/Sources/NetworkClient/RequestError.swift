//
//  RequestError.swift
//  NetworkClient
//
//  Created by Igor Nikolaev on 17.06.2025.
//

import Foundation
import RestClient

/* Удобная версия ошибки для последующего использования на соответствующих экранах. */

public extension RequestError {
  static let connectionLost = Self(type: .connectionLost)
  static let decoding = Self(type: .decoding)
  static let requestFailed = Self(type: .requestFailed)
  static let unauthorizedUser = Self(type: .unauthorizedUser)
  static let unknown = Self(type: .unknown)
  static let updateApplication = Self(type: .updateApplication)
  static let wrongUrl = Self(type: .wrongUrl)
}

public struct RequestError: Error, Equatable {
  public let type: RequestErrorType
  public let underlying: Error?
  
  public init() {
    self = .unknown
  }
  
  public init(
    type: RequestErrorType,
    underlying: Error? = nil
  ) {
    self.type = type
    self.underlying = underlying
  }
  
  public func isRetryable() -> Bool {
    type.isRetryable()
  }
  
  public func isUpdateApplication() -> Bool {
    type.isUpdateApplication()
  }
  
  /// Equatable
  public static func == (lhs: RequestError, rhs: RequestError) -> Bool {
    lhs.type == rhs.type
  }
}

extension RequestError {
  init(error: Error) {
    switch error {
    case let error as RequestError:
      self = error
      
    case let error as DecodingError:
      self.init(type: .decoding, underlying: error)
      
    case let error as EncodingError:
      self.init(type: .encoding, underlying: error)
      
    case let error as URLError:
      self.init(error: error)
      
    case let error as RestClientError:
      self.init(error: error)
      
    default:
      self.init(type: .unknown, underlying: error)
    }
  }
  
  init(error: RestClientError) {
    let type: RequestErrorType
    switch error {
    case let .builder(errorType):
      type = errorType.isUnauthorized() ? .unauthorizedUser : .wrongUrl
      
    case let .statusCode(data):
      type = RequestErrorStatusCode(rawValue: data.code)?.errorType() ?? .requestFailed
    }
    
    self.init(type: type, underlying: error)
  }
  
  init(error: URLError) {
    self.init(
      type: .init(error: error),
      underlying: error
    )
  }
}

extension Swift.Result where Failure == RequestError {
  public func requestError() -> RequestError? {
    let result: RequestError?
    switch self {
    case .success:
      result = nil
    case let .failure(error):
      result = error
    }
    return result
  }
}

public enum RequestErrorType: Int32, Sendable {
  case unknown
  case updateApplication
  
  case decoding
  case encoding
  case wrongUrl
  
  case unauthorizedUser
  
  case connectionLost
  case requestFailed
  case serverOffline
  
  public func isConnectionLost() -> Bool {
    self == .connectionLost
  }
  
  public func isRetryable() -> Bool {
    rawValue > Self.unauthorizedUser.rawValue
  }
  
  public func isUnauthorizedUser() -> Bool {
    self == .unauthorizedUser
  }
  
  public func isUpdateApplication() -> Bool {
    self == .updateApplication
  }
}

extension RequestErrorType {
  init(error: URLError) {
    switch error.code {
    case .cannotFindHost, .cannotConnectToHost:
      self = .serverOffline
    case .notConnectedToInternet:
      self = .connectionLost
    default:
      self = .requestFailed
    }
  }
}

extension RequestErrorType: CustomStringConvertible {
  public var description: String {
    let result: String
    switch self {
    case .unknown:
      result = "unknown"
    case .updateApplication:
      result = "updateApplication"
    case .decoding:
      result = "decoding"
    case .encoding:
      result = "encoding"
    case .wrongUrl:
      result = "wrongUrl"
    case .unauthorizedUser:
      result = "unauthorizedUser"
    case .connectionLost:
      result = "connectionLost"
    case .requestFailed:
      result = "requestFailed"
    case .serverOffline:
      result = "serverOffline"
    }
    return result
  }
}

private enum RequestErrorStatusCode {
  case unauthorizedUser
  case updateApplication
  
  init?(rawValue: Int) {
    switch rawValue {
    case 403:
      self = .unauthorizedUser
    case 572:
      self = .updateApplication
    default:
      return nil
    }
  }
  
  fileprivate func errorType() -> RequestErrorType {
    isUnauthorizedUser() ? .unauthorizedUser : .updateApplication
  }
  
  private func isUnauthorizedUser() -> Bool {
    self == .unauthorizedUser
  }
}
