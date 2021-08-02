/*
 Copyright 2020 Raising the Floor - International

 Licensed under the New BSD license. You may not use this file except in
 compliance with this License.

 You may obtain a copy of the License at
 https://github.com/GPII/universal/blob/master/LICENSE.txt

 The R&D leading to these results received funding from the:
 * Rehabilitation Services Administration, US Dept. of Education under
   grant H421A150006 (APCP)
 * National Institute on Disability, Independent Living, and
   Rehabilitation Research (NIDILRR)
 * Administration for Independent Living & Dept. of Education under grants
   H133E080022 (RERC-IT) and H133E130028/90RE5003-01-00 (UIITA-RERC)
 * European Union's Seventh Framework Programme (FP7/2007-2013) grant
   agreement nos. 289016 (Cloud4all) and 610510 (Prosperity4All)
 * William and Flora Hewlett Foundation
 * Ontario Ministry of Research and Innovation
 * Canadian Foundation for Innovation
 * Adobe Foundation
 * Consumer Electronics Association Foundation
 */

import Foundation

public protocol Scannable {}

extension String: Scannable {}

public final class DataScanner: IteratorProtocol, Sequence {
    public static let standardInput = DataScanner(source: FileHandle.standardInput)

    public init(source: FileHandle, delimiters: CharacterSet = CharacterSet.whitespacesAndNewlines) {
        self.source = source
        self.delimiters = delimiters
    }

    public func next() -> String? {
        return read()
    }

    public func makeIterator() -> DataScanner.Iterator {
        return self
    }

    public func ready() -> Bool {
        if buffer?.isAtEnd ?? true {
            // Init or append the buffer.
            let availableData = source.availableData
            if availableData.count > 0,
               let nextInput = String(data: availableData, encoding: .utf8) {
                buffer = Scanner(string: nextInput)
            }
        }
        return !(buffer?.isAtEnd ?? true)
    }

    public func read<T: Scannable>() -> T? {
        if ready() {
            var token: NSString?
            // Grab the next valid characters into token.
            if buffer?.scanUpToCharacters(from: delimiters, into: &token) ?? false,
               let token = token as String? {
                // Skip delimiters for the next invocation.
                buffer?.scanCharacters(from: delimiters, into: nil)
                // Convert the token into an instance of type T and return it.
                return convert(token)
            }
        }
        return nil
    }

    // MARK: - Private

    fileprivate let source: FileHandle
    fileprivate let delimiters: CharacterSet
    fileprivate var buffer: Scanner?

    fileprivate func convert<T: Scannable>(_ token: String) -> T? {
        let scanner = Scanner(string: token)
        switch T.self {
        case is String.Type:
            return token as? T
        case is Int.Type:
            var value: Int = 0
            if scanner.scanInt(&value) {
                return value as? T
            }
        case is Int32.Type:
            var value: Int32 = 0
            if scanner.scanInt32(&value) {
                return value as? T
            }
        case is Int64.Type:
            var value: Int64 = 0
            if scanner.scanInt64(&value) {
                return value as? T
            }
        case is UInt64.Type:
            var value: UInt64 = 0
            if scanner.scanUnsignedLongLong(&value) {
                return value as? T
            }
        case is Float.Type:
            var value: Float = 0
            if scanner.scanFloat(&value) {
                return value as? T
            }
        case is Double.Type:
            var value: Double = 0
            if scanner.scanDouble(&value) {
                return value as? T
            }
        default:
            break
        }
        return nil
    }
}
