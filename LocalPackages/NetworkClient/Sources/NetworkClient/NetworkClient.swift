// The Swift Programming Language
// https://docs.swift.org/swift-book

import SwiftUI
import RestClient

public typealias RequestResult<T> = Result<T, RequestError>

public final class NetworkClient {
  @Binding var authorizationToken: String?
  
  private let client: RestClient
    
  public init(
    authorizationToken: Binding<String?>,
    client: RestClient
  ) {
    _authorizationToken = authorizationToken
    self.client = client
  }
  
  public func request<Object: Decodable>(_ request: RestRequest) async -> RequestResult<Object> {
    let result: RequestResult<Object>
    do {
      let data = try await client.request(request, authorizationToken: authorizationToken)
      let object = try JSONDecoder().decode(Object.self, from: data)
      result = .success(object)
    } catch {
      let requestError = RequestError(error: error)
      result = .failure(requestError)
    }
    return result
  }
}

extension NetworkClient {
  public static let defaultConfiguration: URLSessionConfiguration = {
    let result = URLSessionConfiguration.default
    result.httpAdditionalHeaders = ["AppVersion": String.appVersion]
    result.requestCachePolicy = .reloadRevalidatingCacheData
    result.timeoutIntervalForRequest = .requestTimeout
    result.timeoutIntervalForResource = .resourceTimeout
    return result
  }()
  
  public static let defaultSession = URLSession(configuration: defaultConfiguration)
}


/// Constants
private extension TimeInterval {
  static let requestTimeout: TimeInterval = 20
  static let resourceTimeout: TimeInterval = 60
}

private extension String {
  static let appVersion = Bundle.main.infoDictionary!["CFBundleShortVersionString"] as! String
}
