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
    let anyValidUrl: URL = .init(string: "https://www.any-valid-url.jp")!
    
    var mockAdapter: URLSessionAdapterMock!
    var target: Session!

    override func setUpWithError() throws {
        mockAdapter = URLSessionAdapterMock()
        target = Session(session: mockAdapter)
    }

    override func tearDownWithError() throws {
    }

    func test_HttpAPIは正常レスポンスを返す() async throws {
        mockAdapter.dataForHandler = { (request) throws -> (Data, URLResponse) in
            return (
                Data(
                """
                {
                    "name": "NAME",
                    "age": 15
                }
                """.utf8),
                HTTPURLResponse(url: self.anyValidUrl, statusCode: 200, httpVersion: "1.1", headerFields: nil)! as URLResponse
            )
        }
        
        let req = HogeRequest(urlString: anyValidUrl.absoluteString)
        let res = try await target.sendHttpRequest(req)
        XCTAssertEqual(res.statusCode, 200)
        XCTAssertNil(res.errorBody)
        XCTAssertEqual(res.body?.name, "NAME")
        XCTAssertEqual(res.body?.age, 15)
    }
    
    func test_HttpAPIはエラーレスポンスを返す() async throws {
        mockAdapter.dataForHandler = { (request) throws -> (Data, URLResponse) in
            return (
                Data(
                """
                {
                    "code": "E01002",
                    "message": "I have not a pen"
                }
                """.utf8),
                HTTPURLResponse(url: self.anyValidUrl, statusCode: 400, httpVersion: "1.1", headerFields: nil)! as URLResponse
            )
        }
        
        let req = HogeRequest(urlString: anyValidUrl.absoluteString)
        let res = try await target.sendHttpRequest(req)
        XCTAssertEqual(res.statusCode, 400)
        XCTAssertNil(res.body)
        XCTAssertEqual(res.errorBody?.code, "E01002")
        XCTAssertEqual(res.errorBody?.message, "I have not a pen")
    }
    
    func test_HttpAPIで正常系レスポンスのデコードエラーが発生したら例外を投げる() {
        
    }
    
    func test_HttpAPIで異常系レスポンスのデコードエラーが発生したら例外を投げる() {
        
    }
    
    func test_リクエスト作成に失敗したら例外を投げる() {
        
    }
    
    func test_URL先の接続に失敗したら例外を投げる() {
        
    }
    
    func test_Httpリクエスト通信プロセスで何らかのエラーが起きたら例外を投げる() {
        
    }
}


private struct HogeRequest: HttpRequestable {
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

private struct HogeResponse: BodyResponsable {
    var name: String
    var age: Int
}

private struct HogeErrorResponse: BodyResponsable {
    var code: String
    var message: String
}
