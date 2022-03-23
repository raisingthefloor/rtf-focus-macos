//
//  CustomScrollView.swift
//  Focus
//
//  Created by Bhavi on 23/03/22.
//  Copyright © 2022 Raising the Floor. All rights reserved.
//

import Foundation
import Cocoa

@IBDesignable
@objc(BCLDisablableScrollView)
public class CustomScrollView: NSScrollView {
    @IBInspectable
    @objc(enabled)
    public var isEnabled: Bool = true

    public override func scrollWheel(with event: NSEvent) {
        if isEnabled {
            super.scrollWheel(with: event)
        }
        else {
            nextResponder?.scrollWheel(with: event)
        }
    }
}
