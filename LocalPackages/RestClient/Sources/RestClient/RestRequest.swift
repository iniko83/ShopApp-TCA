//
//  RestRequest.swift
//  RestClient
//
//  Created by Igor Nikolaev on 17.06.2025.
//

import Foundation

public protocol RestRequestConvertible {
  func restRequest() -> RestRequest
}

public struct RestRequest {
  let path: String
  let method: HttpMethod
  
  let headers: [String: String]?
  let parameters: Parameters?
  let urlQuery: UrlQuery?
  let urlQueryTrailing: String?
  
  let timeoutInterval: TimeInterval?
  
  let authorization: Authorization
  
  init(
    path: String,
    method: HttpMethod = .get,
    headers: [String: String]? = nil,
    parameters: Parameters? = nil,
    urlQuery: UrlQuery? = nil,
    urlQueryTrailing: String? = nil,
    timeoutInterval: TimeInterval? = nil,
    authorization: Authorization = .init()
  ) {
    self.path = path
    self.method = method
    self.headers = headers
    self.parameters = parameters
    self.urlQuery = urlQuery
    self.urlQueryTrailing = urlQueryTrailing
    self.timeoutInterval = timeoutInterval
    self.authorization = authorization
  }
  
  
  func buildUrlRequest(
    baseUrl: URL,
    authorizationToken: String?,
    authorizationType: RestAuthorizationType
  ) throws -> URLRequest {
    guard let url = url(baseUrl: baseUrl) else {
      throw RestClientError.builder(.wrongUrl)
    }
    
    var result = URLRequest(url: url)
    result.httpMethod = method.operation()
    
    headers?.forEach { (field, value) in
      result.addValue(value, forHTTPHeaderField: field)
    }
    
    if let parameters {
      result.httpBody = try parameters.httpBody()
      result.addValue("application/json", forHTTPHeaderField: "Content-Type")
    }
    
    if let timeoutInterval {
      result.timeoutInterval = timeoutInterval
    }
    
    if authorization.isUseToken() {
      if let authorizationToken {
        authorizationType.authorizeRequest(&result, token: authorizationToken)
      } else if authorization.isTokenRequired() {
        throw RestClientError.builder(.unauthorized)
      }
    }
    
    return result
  }
  
  private func url(baseUrl: URL) -> URL? {
    var components = URLComponents()
    components.scheme = baseUrl.scheme
    components.host = baseUrl.host
    components.path = baseUrl.path
    components.queryItems = urlQuery?.items()
    
    guard let url = components.url?.appendingPathComponent(path) else { return nil }
    
    guard let urlQueryTrailing else { return url }
    
    let urlString = url.absoluteString + urlQueryTrailing
    return .init(string: urlString)
  }
}

extension RestRequest {
  public enum Authorization {
    case any
    case required
    case unused
    
    init() {
      self = .any
    }
    
    fileprivate func isTokenRequired() -> Bool {
      self == .required
    }
    
    fileprivate func isUseToken() -> Bool {
      self != .unused
    }
  }
  
  public enum Parameters {
    case body(Encodable)
    case info([String: Encodable])
    
    fileprivate func httpBody() throws -> Data {
      let result: Data
      switch self {
      case let .body(value):
        result = try JSONEncoder().encode(value)
      case let .info(value):
        result = try JSONSerialization.data(withJSONObject: value)
      }
      return result
    }
  }
  
  public enum UrlQuery {
    case dictionary([String: CustomStringConvertible])
    case queryItems([URLQueryItem])
    
    fileprivate func items() -> [URLQueryItem] {
      let result: [URLQueryItem]
      switch self {
      case let .dictionary(info):
        result = info.map { (name, value) in
            .init(name: name, value: value.description)
        }
        
      case let .queryItems(items):
        result = items
      }
      return result
    }
  }
}
