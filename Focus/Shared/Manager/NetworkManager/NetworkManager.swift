//
//  NetworkManager.swift
//  Focus
//
//  Created by Bhavi on 09/08/21.
//  Copyright © 2021 Raising the Floor. All rights reserved.
//

import Foundation
import NetworkExtension
import SystemExtensions
import os.log


enum NetworkStatus {
    case stopped
    case indeterminate
    case running
}







//struct PacketInfo {
//
//    let addressLength: Int
//
//    let headerRange: Range<Data.Index>
//    let headerChecksumRange: Range<Data.Index>?
//    let sourceAddressRange: Range<Data.Index>
//    let destinationAddressRange: Range<Data.Index>
//
//    let tcpHeaderRange: Range<Data.Index>
//    let tcpSourcePortRange: Range<Data.Index>
//    let tcpDestinationPortRange: Range<Data.Index>
//    let tcpChecksumRange: Range<Data.Index>
//
//    let tcpPayloadRange: Range<Data.Index>
//
//    enum AddressKind {
//        case src
//        case dst
//    }
//
//    func addressRange(kind: AddressKind) -> Range<Data.Index> {
//        switch kind {
//        case .src: return self.sourceAddressRange
//        case .dst: return self.destinationAddressRange
//        }
//    }
//
//    func portRange(kind: AddressKind) -> Range<Data.Index> {
//        switch kind {
//        case .src: return self.tcpSourcePortRange
//        case .dst: return self.tcpDestinationPortRange
//        }
//    }
//
//    init?(protocolFamily: sa_family_t, packetData: Data) {
//        switch Int32(protocolFamily) {
//        case AF_INET:
//            try? self.init(packetData4: packetData)
//        case AF_INET6:
//            // Leaving out IPv6 support for the moment because I’m not set up to
//            // test it, and writing all the code without testing it would be a
//            // mistake.
//            return nil
//        default:
//            return nil
//        }
//    }
//
//    private init(packetData4 packetData: Data) throws {
//        self.addressLength = 4
//
//        var p = PacketParser(packetData: packetData)
//
//        let versionIHL = try p.parseUInt8()
//        try p.skip(1)                       // DSCP | ECN
//        let totalLength = try Int(p.parseUInt16())
//        try p.skip(2)                       // Identification
//        try p.skip(2)                       // Flags | Fragment Offset
//        try p.skip(1)                       // TTL
//        let proto = try p.parseUInt8()
//        self.headerChecksumRange = try p.skip(2)
//        self.sourceAddressRange = try p.skip(4)
//        self.destinationAddressRange = try p.skip(4)
//
//        guard
//            versionIHL & 0xf0 == 0x40,
//            versionIHL & 0x0f >= 5,
//            totalLength <= packetData.count,
//            proto == 6
//        else { throw ParseError.unexpectedValue }
//        let ipHeaderLength = Int(versionIHL & 0x0f) * 4
//
//        let optionsRange = try p.skip(ipHeaderLength - 20)
//        self.headerRange = packetData.startIndex..<optionsRange.upperBound
//
//        self.tcpSourcePortRange = try p.skip(2)
//        self.tcpDestinationPortRange = try p.skip(2)
//        try p.skip(4)                       // Sequence Number
//        try p.skip(4)                       // Acknowledgment Number
//        let tcpDataOffsetFlags = try p.parseUInt8()
//        try p.skip(1)                       // Flags
//        try p.skip(2)                       // Window
//        self.tcpChecksumRange = try p.skip(2)
//        try p.skip(2)                       // Urgent Pointer
//
//        guard (tcpDataOffsetFlags >> 4) >= 5 else { throw ParseError.unexpectedValue }
//        let tcpHeaderLength = Int(tcpDataOffsetFlags >> 4) * 4
//
//        let tcpOptionsRange = try p.skip(tcpHeaderLength - 20)
//        self.tcpHeaderRange = optionsRange.upperBound..<tcpOptionsRange.upperBound
//
//        let payloadLength = totalLength - (ipHeaderLength + tcpHeaderLength)
//        self.tcpPayloadRange = try p.skip(payloadLength)
//    }
//
//    private struct PacketParser {
//        let packetData: Data
//
//        init(packetData: Data) {
//            self.packetData = packetData
//            self.currentIndex = packetData.startIndex
//        }
//
//        var currentIndex: Data.Index
//
//        @discardableResult
//        mutating func skip(_ count: Int) throws -> Range<Data.Index> {
//            let old = self.currentIndex
//            guard let newIndex = packetData.index(self.currentIndex, offsetBy: count, limitedBy: packetData.endIndex) else {
//                throw ParseError.dataExpected
//            }
//            defer { self.currentIndex = newIndex }
//            return self.currentIndex..<newIndex
//        }
//
//        mutating func parseUInt8() throws -> UInt8 {
//            let r = try skip(1)
//            return self.packetData[r.lowerBound]
//        }
//
//        mutating func parseUInt16() throws -> UInt16 {
//            let r = try skip(2)
//            return UInt16(self.packetData[r.lowerBound]) << 8 | UInt16(self.packetData[r.lowerBound + 1])
//        }
//    }
//
//    private enum ParseError: Error {
//        case dataExpected
//        case unexpectedValue
//    }
//}
