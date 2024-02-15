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
}
