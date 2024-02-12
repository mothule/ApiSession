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
    func sendHttpRequest<Request: ApiRequestable>(_ request: Request) async throws -> ApiResponse<Request.Response>
}

extension SessionProtocol {
    func sendHttpRequest<Request: ApiRequestable>(_ request: Request) async throws -> Request.Response {
        return try await sendHttpRequest(request).body
    }
}

public class Session: SessionProtocol {
    public let session: URLSession
    
    /// shared instance is using URLSession.shared.
    public static var shared: SessionProtocol = Session(session: .shared)
    
    public init(session: URLSession) {
        self.session = session
    }
    
    public func sendHttpRequest<Request: ApiRequestable>(_ request: Request) async throws -> ApiResponse<Request.Response> {
        guard let urlRequest = request.urlRequest() else { throw ApiError.requestError }
        
        do {
            let (data, urlResponse) = try await session.data(for: urlRequest)
            
            guard let httpUrlResponse = urlResponse as? HTTPURLResponse else {
                throw ApiError.responseError(.cannotCastHTTPURLResponse)
            }
            guard 200..<300 ~= httpUrlResponse.statusCode else {
                let errorResponse = try request.decodeErrorResponseBody(data: data)
                throw ApiError.httpError(httpUrlResponse.statusCode, errorResponse)
            }
            
            // Success
            
            do {
                let body = try request.decodeResponseBody(data: data)
                return .init(httpUrlResponse: httpUrlResponse, body: body)
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
