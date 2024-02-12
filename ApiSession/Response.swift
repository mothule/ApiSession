//
//  Response.swift
//  ApiSession
//  
//  Created by mothule on 2024/02/12
//  
//

import Foundation

public protocol ApiResponsable: Decodable {}

public struct ApiResponse<T: ApiResponsable> {
    var httpUrlResponse: HTTPURLResponse
    var body: T
}

extension ApiResponse {
    var httpStatusCode: Int { httpUrlResponse.statusCode }
}
