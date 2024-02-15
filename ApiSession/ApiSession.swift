//
//  ApiSession.swift
//  ApiSession
//  
//  Created by mothule on 2024/02/12
//  
//

import Foundation

/// サーバサイドAPIと通信するためにクライアントサイドで利用する通信方法を公開する.
public protocol SessionProtocol {
    /// HTTPリクエストの送信.
    /// - Parameters:
    ///     - request: HTTPリクエスト
    /// - Returns: リクエストに指定された方法でデコードされたペイロードを含むレスポンス
    /// - Throws: ApiError
    func sendHttpRequest<Request: HttpRequestable>(_ request: Request) async throws -> HttpResponse<Request.SuccessBodyResponse, Request.ErrorBodyResponse>
}

extension SessionProtocol {
//    func sendHttpRequest<Request: ApiRequestable>(_ request: Request) async throws -> Request.Response {
//        return try await sendHttpRequest(request).body
//    }
}

public class Session: SessionProtocol {
    public let session: URLSessionAdapter
    
    /// shared instance is using URLSession.shared.
    public static var shared: SessionProtocol = Session(session: URLSession.shared)
    
    public init(session: URLSessionAdapter) {
        self.session = session
    }
    
    public func sendHttpRequest<Request: HttpRequestable>(_ request: Request) async throws -> HttpResponse<Request.SuccessBodyResponse, Request.ErrorBodyResponse> {
        guard let urlRequest = request.urlRequest() else { throw ApiError.requestError }
        
        do {
            let (data, urlResponse) = try await session.data(for: urlRequest)
            
            guard let httpUrlResponse = urlResponse as? HTTPURLResponse else {
                throw ApiError.responseError(.cannotCastHTTPURLResponse)
            }
            do {
                if 200..<300 ~= httpUrlResponse.statusCode {
                    let successBodyResponse = try request.decodeResponseBody(data: data)
                    return .makeSuccess(response: httpUrlResponse, body: successBodyResponse)
                } else {
                    let errorBodyResponse = try request.decodeErrorResponseBody(data: data)
                    return .makeError(response: httpUrlResponse, body: errorBodyResponse)
                }
            } catch let error as DecodingError {
                throw ApiError.responseError(.decodeError(error))
            }
            
        } catch let error as ApiError {
            throw error
            
        } catch let error as URLError {
            throw ApiError.urlError(error)
            
        } catch let error {
            throw ApiError.unknown(error)
        }
    }
}
