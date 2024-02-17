//
//  URLSessionAdapterMock.swift
//  ApiSessionTests
//  
//  Created by mothule on 2024/02/16
//  
//

import Foundation
@testable import ApiSession

class URLSessionAdapterMock: URLSessionAdapter {
    var dataForHandler: ((URLRequest) throws -> (Data, URLResponse))?
    
    func data(for urlRequest: URLRequest) async throws -> (Data, URLResponse) {
        return try await withCheckedThrowingContinuation { continuation in
            guard let dataForHandler else { fatalError() }
            do {
                let result = try dataForHandler(urlRequest)
                continuation.resume(returning: result)
            } catch {
                continuation.resume(throwing: error)
            }
        }
    }
    
    func setupDataForHandler(bodyString: String, statusCode: Int) {
        let response = (
            Data(bodyString.utf8),
            HTTPURLResponse(
                url: .init(string: "https://valid-url.jp")!,
                statusCode: statusCode,
                httpVersion: "1.1",
                headerFields: nil
            )! as URLResponse
        )
        dataForHandler = { (request) throws -> (Data, URLResponse) in
            return response
        }
    }
    
    func setupDataForHandler(object: Any, statusCode: Int) {
        let data = try! JSONSerialization.data(withJSONObject: object)
        let response = (
            data,
            HTTPURLResponse(
                url: .init(string: "https://valid-url.jp")!,
                statusCode: statusCode,
                httpVersion: "1.1",
                headerFields: nil
            )! as URLResponse
        )
        dataForHandler = { (request) throws -> (Data, URLResponse) in
            return response
        }
    }
}
