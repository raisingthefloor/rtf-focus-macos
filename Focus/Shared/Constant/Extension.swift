//
//  Extention.swift
//  Focus
//
//  Created by Bhavi on 14/07/21.
//  Copyright © 2021 Raising the Floor. All rights reserved.
//

import Cocoa
import Foundation

extension NSView {
    var bgColor: NSColor? {
        get {
            if let colorRef = layer?.backgroundColor {
                return NSColor(cgColor: colorRef)
            } else {
                return nil
            }
        }

        set {
            wantsLayer = true
            layer?.backgroundColor = newValue?.cgColor
        }
    }
}

extension String {
    static func randomString(length: Int = 5) -> String {
        let letters = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
        return String((0 ..< length).map { _ in letters.randomElement()! })
    }
}
