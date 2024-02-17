//
//  RequestTests.swift
//  
//  
//  Created by mothule on 2024/02/18
//  
//

import XCTest

final class RequestTests: XCTestCase {
    func test_PostRequestはhttpBodyを含んだURLRequestを作成する() throws {
        let request = HogeCreateRequest(urlString: "https://api.any-valid.jp", name: "NAME", age: 16)
        let target = try XCTUnwrap(request.urlRequest())
        XCTAssertEqual(target.httpMethod, "POST")
        let bodyData = try XCTUnwrap(target.httpBody)
        let jsonObject = try XCTUnwrap(try JSONSerialization.jsonObject(with: bodyData) as? [String: Any])
        let name = try XCTUnwrap(jsonObject["name"] as? String)
        XCTAssertEqual(name, "NAME")
        
        let age = try XCTUnwrap(jsonObject["age"] as? Int)
        XCTAssertEqual(age, 16)
    }
}
