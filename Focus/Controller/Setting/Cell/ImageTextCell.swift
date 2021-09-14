//
//  ImageTextCell.swift
//  Focus
//
//  Created by Bhavi on 14/09/21.
//  Copyright © 2021 Raising the Floor. All rights reserved.
//

import Cocoa

class ImageTextCell: NSTableCellView {

    @IBOutlet var lblTitle: NSTextField!
    @IBOutlet var imgV: NSImageView!

    override func prepareForReuse() {
        super.prepareForReuse()
    }

    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        setUpText()
        setUpViews()
    }
}

extension ImageTextCell: BasicSetupType {
    func setUpText() {
        
    }

    func setUpViews() {
        if lblTitle != nil {
            lblTitle.font = NSFont.systemFont(ofSize: 12, weight: .regular)
        }
    }
    
    func configCell(){
        lblTitle.stringValue = "Skype"
        imgV.image = NSImage(named: "ic_info_filled")
    }
}
