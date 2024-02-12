//
//  ApiSessionTests.swift
//  ApiSessionTests
//  
//  Created by mothule on 2024/02/12
//  
//

import XCTest
@testable import ApiSession

final class ApiSessionTests: XCTestCase {

    override func setUpWithError() throws {
    }

    override func tearDownWithError() throws {
    }

    func test_success() async throws {
        // FIXME: UT書きづらいので URLSession の Adapter を用意し、 AdapterをMockingする
//        let req = HogeRequest(urlString: "")
//        let res = try await Session.shared.sendHttpRequest(req).body
    }
}


private struct HogeRequest: ApiRequestable {
    typealias Response = HogeResponse
    typealias ErrorResponse = HogeErrorResponse
    
    var urlString: String
    
    var url: URL? { .init(string: urlString) }
    
    var httpMethod: ApiSession.HttpMethod { .get }
    
    var httpHeaderFields: [String : String]?
    var cachePolicy: URLRequest.CachePolicy?
    var requestTimeoutInterval: TimeInterval?
    
    func decodeResponseBody(data: Data) throws -> HogeResponse {
        try JSONDecoder().decode(HogeResponse.self, from: data)
    }
    
    func decodeErrorResponseBody(data: Data) throws -> HogeErrorResponse {
        try JSONDecoder().decode(HogeErrorResponse.self, from: data)
    }
}

private struct HogeResponse: ApiResponsable {
}

private struct HogeErrorResponse: ApiResponsable {
}
