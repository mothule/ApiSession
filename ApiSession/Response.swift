//
//  Response.swift
//  ApiSession
//  
//  Created by mothule on 2024/02/12
//  
//

import Foundation

public protocol ApiResponsable: Decodable {}
public protocol BodyResponsable: Decodable {}

public struct HttpResponse<T: BodyResponsable, E: BodyResponsable> {
    var statusCode: Int
    var headerFields: [AnyHashable: Any]
    var body: T?
    var errorBody: E?
    
    static func makeSuccess(response: HTTPURLResponse, body: T) -> Self {
        return .init(
            statusCode: response.statusCode,
            headerFields: response.allHeaderFields,
            body: body
        )
    }
    static func makeError(response: HTTPURLResponse, body: E) -> Self {
        return .init(
            statusCode: response.statusCode,
            headerFields: response.allHeaderFields,
            errorBody: body
        )
    }
}
