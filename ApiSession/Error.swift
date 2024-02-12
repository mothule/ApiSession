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
    case requestError
    /// レスポンス処理でエラー
    case responseError(ApiResponseError)
    /// HTTPステータスエラー
    case httpError(Int, ApiResponsable)
    
    case urlError(URLError)
    
    case unknown(Error)
}

public enum ApiResponseError: LocalizedError & CustomNSError {
    case cannotCastHTTPURLResponse
    case decodeError(DecodingError)
    case underlyingError(Error)
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
