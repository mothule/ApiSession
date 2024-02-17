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

public protocol HttpRequestable {
    associatedtype SuccessBodyResponse: BodyResponsable
    associatedtype ErrorBodyResponse: BodyResponsable
    typealias Response = HttpResponse<SuccessBodyResponse, ErrorBodyResponse>
    
    var url: URL? { get }
    var httpMethod: HttpMethod { get }
    var httpHeaderFields: [String: String]? { get }
    
    /// リクエスト毎のキャッシュポリシー. nilならConfigurationの値を使う
    var cachePolicy: URLRequest.CachePolicy? { get }
    
    /// リクエスト毎のタイムアウト指定。nilならConfigurationの値を使う
    var requestTimeoutInterval: TimeInterval? { get }
    
    /// レスポンスボディからレスポンスモデルへデコードする
    func decodeResponseBody(data: Data) throws -> SuccessBodyResponse
    
    /// エラー時のレスポンスボディからモデルへデコードする
    func decodeErrorResponseBody(data: Data) throws -> ErrorBodyResponse
    
    /// URLRequestに変換する
    func urlRequest() -> URLRequest?
}

extension HttpRequestable {
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
