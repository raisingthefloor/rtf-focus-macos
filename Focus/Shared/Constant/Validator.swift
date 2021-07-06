import Foundation
import Cocoa

enum ValidaterError: Error {
    case invalidData(String)
    var message: String {
        switch self {
        case let .invalidData(message):
            return message
        }
    }
}
