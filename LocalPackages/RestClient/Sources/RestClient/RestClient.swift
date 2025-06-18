// The Swift Programming Language
// https://docs.swift.org/swift-book

import Foundation

public final class RestClient: Sendable {
  private let authorizationType: RestAuthorizationType
  private let baseUrl: URL
  private let session: URLSession
  
  public init(
    authorizationType: RestAuthorizationType = .init(),
    baseUrl: URL,
    session: URLSession = .shared
  ) {
    self.authorizationType = authorizationType
    self.baseUrl = baseUrl
    self.session = session
  }
  
  public func request(
    _ request: RestRequest,
    authorizationToken: String? = nil
  ) async throws -> Data {
    let urlRequest = try request.buildUrlRequest(
      baseUrl: baseUrl,
      authorizationToken: authorizationToken,
      authorizationType: authorizationType
    )
    
    let (data, response) = try await session.data(for: urlRequest)
    let statusCode = (response as? HTTPURLResponse)?.statusCode ?? -1
    
    guard (200...299).contains(statusCode) else {
      throw RestClientError.statusCode(
        .init(code: statusCode, data: data)
      )
    }
    
    return data
  }
}
