//
//  URLSessionAdapter.swift
//  ApiSession
//  
//  Created by mothule on 2024/02/16
//  
//

import Foundation

public protocol URLSessionAdapter {
    func data(for urlRequest: URLRequest) async throws -> (Data, URLResponse)
}

extension URLSession: URLSessionAdapter {}
