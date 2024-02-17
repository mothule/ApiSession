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
        mockAdapter.setupDataForHandler(object: ["name": "NAME", "age": 15], statusCode: 200)
        let req = HogeRequest(urlString: anyValidUrl.absoluteString)
        let res = try await target.sendHttpRequest(req)
        XCTAssertEqual(res.statusCode, 200)
        XCTAssertNil(res.errorBody)
        XCTAssertEqual(res.body?.name, "NAME")
        XCTAssertEqual(res.body?.age, 15)
    }
    
    func test_HttpAPIはエラーレスポンスを返す() async throws {
        mockAdapter.setupDataForHandler(object: ["code": "E01002", "message": "I have not a pen"], statusCode: 400)
        
        let req = HogeRequest(urlString: anyValidUrl.absoluteString)
        let res = try await target.sendHttpRequest(req)
        XCTAssertEqual(res.statusCode, 400)
        XCTAssertNil(res.body)
        XCTAssertEqual(res.errorBody?.code, "E01002")
        XCTAssertEqual(res.errorBody?.message, "I have not a pen")
    }
    
    func test_HttpAPIで正常系レスポンスのデコードエラーが発生したら例外を投げる() async throws {
        mockAdapter.setupDataForHandler(object: ["": ""], statusCode: 200)
        let req = HogeRequest(urlString: anyValidUrl.absoluteString)
        await XCTAssertThrowsError(try await self.target.sendHttpRequest(req))
    }
    
    func test_HttpAPIで異常系レスポンスのデコードエラーが発生したら例外を投げる() async {
        mockAdapter.setupDataForHandler(object: ["": ""], statusCode: 400)
        let req = HogeRequest(urlString: anyValidUrl.absoluteString)
        await XCTAssertThrowsError(try await self.target.sendHttpRequest(req))
    }
    
    func test_URLRequest作成に失敗したら例外を投げる() async {
        mockAdapter.setupDataForHandler(object: ["name": "NAME", "age": 15], statusCode: 200)
        let req = HogeRequest(urlString: "")
        await XCTAssertThrowsError(try await self.target.sendHttpRequest(req)) { error in
            let error = try! XCTUnwrap(error as? ApiError)
            XCTAssertEqual(error, ApiError.requestError(.cannotURLRequest))
        }
    }
    
    func test_URL先の接続に失敗したら例外を投げる() async {
        mockAdapter.dataForHandler = { (req) throws -> (Data, URLResponse) in
            throw URLError(URLError.appTransportSecurityRequiresSecureConnection)
        }
        let req = HogeRequest(urlString: anyValidUrl.absoluteString)
        await XCTAssertThrowsError(try await self.target.sendHttpRequest(req)) { error in
            let error = try! XCTUnwrap(error as? ApiError)
            XCTAssertEqual(error, ApiError.urlError(URLError(.appTransportSecurityRequiresSecureConnection)))
        }
    }
    
    func test_Httpリクエスト通信プロセスで何らかのエラーが起きたら例外を投げる() async {
        let nsError = NSError(domain: "com.mothule.ApiSession", code: -1)
        mockAdapter.dataForHandler = { (req) throws -> (Data, URLResponse) in
            throw nsError
        }
        let req = HogeRequest(urlString: anyValidUrl.absoluteString)
        await XCTAssertThrowsError(try await self.target.sendHttpRequest(req)) { error in
            let error = try! XCTUnwrap(error as? ApiError)
            XCTAssertEqual(error, ApiError.unknown(nsError))
        }
    }
}



private struct HogeRequest: HttpRequestable {
    typealias SuccessBodyResponse = HogeResponse
    typealias ErrorBodyResponse = HogeErrorResponse
    
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
