//
//  Error.swift
//  ApiSession
//  
//  Created by mothule on 2024/02/12
//  
//

import Foundation

public enum ApiError: LocalizedError & CustomNSError {
    /// 通信プロセスや通信経路上に問題が発生
    case networkError
    /// リクエスト処理でエラー
    case requestError(ApiRequestError)
    /// レスポンス処理でエラー
    case responseError(ApiResponseError)
    
    case urlError(URLError)
    
    case unknown(Error)
}

extension ApiError: Equatable {
    public static func == (lhs: ApiError, rhs: ApiError) -> Bool {
        switch (lhs, rhs) {
        case (.networkError, .networkError): return true
        case (.requestError(let l), .requestError(let r)): return l == r
        case (.responseError(let l), .responseError(let r)): return l == r
        case (.urlError(let l), .urlError(let r)): return l == r
        case (.unknown(let l), .unknown(let r)):
            return (l as NSError).code == (r as NSError).code &&
            (l as NSError).domain == (r as NSError).domain
        default: return false
        }
    }
}

public enum ApiRequestError: LocalizedError & CustomNSError {
    case cannotURLRequest
    case cannotCastHTTPURLResponse
}
extension ApiRequestError: Equatable {
}

public enum ApiResponseError: LocalizedError & CustomNSError {
    case decodeError(DecodingError)
}
extension ApiResponseError: Equatable {
    public static func == (lhs: ApiResponseError, rhs: ApiResponseError) -> Bool {
        switch (lhs, rhs) {
        case (.decodeError(let l), .decodeError(let r)): return l == r
        }
    }
}


extension DecodingError: CustomDebugStringConvertible {
    public var debugDescription: String {
        switch self {
        case let .keyNotFound(key, context):
            let contextDebugDesc: [String] = [
                context.codingPath.map(\.stringValue).joined(separator: ","),
                context.debugDescription,
                context.underlyingError?.localizedDescription ?? ""
            ]
            return "Key not found. \(key.stringValue), \(contextDebugDesc)"
        case let .valueNotFound(type, context):
            let contextDebugDesc: [String] = [
                context.codingPath.map(\.stringValue).joined(separator: ","),
                context.debugDescription,
                context.underlyingError?.localizedDescription ?? ""
            ]
            return "Value not found. \(String(describing: type)), \(contextDebugDesc)"
        case let .typeMismatch(type, context):
            let contextDebugDesc: [String] = [
                context.codingPath.map(\.stringValue).joined(separator: ","),
                context.debugDescription,
                context.underlyingError?.localizedDescription ?? ""
            ]
            return "Type mismatch. \(String(describing: type)), \(contextDebugDesc)"
        case let .dataCorrupted(context):
            let contextDebugDesc: [String] = [
                context.codingPath.map(\.stringValue).joined(separator: ","),
                context.debugDescription,
                context.underlyingError?.localizedDescription ?? ""
            ]
            return "Data corrupted. \(contextDebugDesc)"
        @unknown default:
            fatalError("Not supported type.")
        }
    }
}

extension DecodingError: Equatable {
    public static func == (lhs: DecodingError, rhs: DecodingError) -> Bool {
        lhs.debugDescription == rhs.debugDescription
    }
}
