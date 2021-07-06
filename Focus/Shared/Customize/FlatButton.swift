//
//  FlatButton.swift
//  Focus
//
//  Created by Bhavi on 18/06/21.
//

import Foundation
import Cocoa

@IBDesignable class FlatButton: NSButton {
    @IBInspectable var cornerRadius: CGFloat = 5
    
    @IBInspectable var dxPadding: CGFloat = 10
    @IBInspectable var dyPadding: CGFloat = 10

    @IBInspectable var backgroundColor: NSColor = .blue
    
    @IBInspectable var imageName: String = "NSActionTemplate"
    
    override func draw(_ dirtyRect: NSRect) {
        // Set corner radius
        self.wantsLayer = true
        self.layer?.cornerRadius = cornerRadius
        
        // Darken background color when highlighted
        if isHighlighted {
            layer?.backgroundColor =  backgroundColor.blended(
                withFraction: 0.2, of: .black
            )?.cgColor
        } else {
            layer?.backgroundColor = backgroundColor.cgColor
        }
        
        // Set Image
        imagePosition = .imageLeading
        image = NSImage(named: imageName)

        // Reset the bounds after drawing is complete
        let originalBounds = self.bounds
        defer { self.bounds = originalBounds }

        // Inset bounds by padding
        self.bounds = originalBounds.insetBy(
            dx: dxPadding, dy: dyPadding
        )
        
        // Super
        super.draw(dirtyRect)
    }
}
