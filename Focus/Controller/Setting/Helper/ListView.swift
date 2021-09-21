//
//  ListView.swift
//  Focus
//
//  Created by Bhavi on 21/09/21.
//  Copyright © 2021 Raising the Floor. All rights reserved.
//

import Cocoa

class ListView: NSView, NibView {
    var mainView: NSView?

    @IBOutlet var listContainerV: NSView!
    @IBOutlet var lblTitle: NSTextField!
    @IBOutlet var lblSubTitle: NSTextField!
    @IBOutlet var tblView: NSTableView!
    @IBOutlet var btnContainerV: NSView!
    @IBOutlet var btnAddApp: CustomButton!
    @IBOutlet var btnAddWeb: CustomButton!

    init() {
        super.init(frame: NSRect.zero)
        _ = load(viaNib: "TableHeaderView")
        setUpText()
        setUpViews()
    }

    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

        // Drawing code here.
    }
}

extension ListView: BasicSetupType {
    func setUpText() {
        btnAddApp.title = NSLocalizedString("Button.add_app", comment: "Add App")
        btnAddWeb.title = NSLocalizedString("Button.add_website", comment: "Add Website")
    }

    func setUpViews() {

        lblTitle.font = NSFont.systemFont(ofSize: 12, weight: .semibold)
        lblTitle.textColor = .black
        
        // lblSubTitle.font = NSFont.systemFont(ofSize: 12, weight: .semibold) // Italic
        lblSubTitle.textColor = Color.black_color
        
        btnContainerV.background_color = Color.list_bg_color
        
        btnAddApp.buttonColor = Color.green_color
        btnAddApp.activeButtonColor = Color.green_color
        btnAddApp.textColor = .white
        btnAddApp.font = NSFont.systemFont(ofSize: 13, weight: .semibold)

        btnAddWeb.buttonColor = Color.green_color
        btnAddWeb.activeButtonColor = Color.green_color
        btnAddWeb.textColor = .white
        btnAddWeb.font = NSFont.systemFont(ofSize: 13, weight: .semibold)
        
        listContainerV.border_color = Color.dark_grey_border
        listContainerV.border_width = 0.5
        listContainerV.background_color = .white
        listContainerV.corner_radius = 4
    }
}
