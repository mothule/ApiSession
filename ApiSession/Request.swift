//
//  Request.swift
//  ApiSession
//  
//  Created by mothule on 2024/02/12
//  
//

import Foundation

public enum HttpMethod: String {
    case get
    case post
    case put
    case delete
}

public protocol ApiRequestable {
    associatedtype Response: ApiResponsable
    associatedtype ErrorResponse: ApiResponsable
    
    var url: URL? { get }
    var httpMethod: HttpMethod { get }
    var httpHeaderFields: [String: String]? { get }
    
    /// リクエスト毎のキャッシュポリシー. nilならConfigurationの値を使う
    var cachePolicy: URLRequest.CachePolicy? { get }
    
    /// リクエスト毎のタイムアウト指定。nilならConfigurationの値を使う
    var requestTimeoutInterval: TimeInterval? { get }
    
    /// レスポンスボディからレスポンスモデルへデコードする
    func decodeResponseBody(data: Data) throws -> Response
    
    /// エラー時のレスポンスボディからモデルへデコードする
    func decodeErrorResponseBody(data: Data) throws -> ErrorResponse
    
    /// URLRequestに変換する
    func urlRequest() -> URLRequest?
}

extension ApiRequestable {
    func urlRequest() -> URLRequest? {
        guard let url else { return nil }
        var ret =  URLRequest(url: url)
        if let cachePolicy = cachePolicy {
            ret.cachePolicy = cachePolicy
        }
        if let timeoutInterval = requestTimeoutInterval {
            ret.timeoutInterval = timeoutInterval
        }
        ret.httpMethod = httpMethod.rawValue
        return ret
    }
}
