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
        _ = load(viaNib: "ListView")
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
