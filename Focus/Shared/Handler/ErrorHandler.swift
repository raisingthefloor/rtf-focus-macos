//
//  ErrorHandlerHandler.swift
//  Focus
//
//  Created by Hardik-Mac on 3/5/19.
//  Copyright © 2019 Thetatechnolabs. All rights reserved.
//

import Foundation

enum ErrorHandler: Error {
    case no_connection
    case request_time_out
    case request_cancelled
    case server_issue(String?)
    case generic(String)

    var message: String {
        switch self {
        case .request_time_out:
            return "Time out"
        case let .server_issue(message):
            return message ?? ""
        case let .generic(message):
            return message
        case .no_connection:
            return "Connection issue"
        default:
            return "Cancel"
        }
    }
}

extension Error {
    var error_handler: ErrorHandler {
        guard let error = self as? ErrorHandler else { return .server_issue(localizedDescription) }
        return error
    }
}
