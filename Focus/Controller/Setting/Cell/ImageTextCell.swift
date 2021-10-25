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

    func configCell(obj: Block_Interface?) {
        guard let model = obj else { return }

        lblTitle.stringValue = model.name ?? "-"
        imgV.isHidden = (model.block_type == BlockType.application.rawValue) ? false : true
        if model.block_type == BlockType.application.rawValue {
            let icon = NSWorkspace.shared.icon(forFile: model.app_icon_path ?? "")
            imgV.image = icon
        }
    }

    func configCategory(obj: Block_Category?) {
        guard let strVal = obj?.name else { return }
        imgV.isHidden = true
        if obj?.show_link ?? false {
            let categoryStr = NSMutableAttributedString.getAttributedString(fromString: strVal)
            categoryStr.underLine(subString: strVal)
            categoryStr.apply(color: Color.blue_color, subString: strVal)
            lblTitle.attributedStringValue = categoryStr
        } else {
            lblTitle.stringValue = strVal
        }
    }

    func configSubCategory(obj: Block_SubCategory?) {
        guard let model = obj else { return }
        imgV.isHidden = true
        let name = model.name ?? "-"
        lblTitle.stringValue = name
        if model.block_type == BlockType.web.rawValue {
//            let categoryStr = NSMutableAttributedString.getAttributedString(fromString: name)
//            categoryStr.underLine(subString: name)
//            categoryStr.apply(color: Color.blue_color, subString: name)
//            lblTitle.attributedStringValue = name
        } else {
            guard let path = model.app_icon_path, !path.isEmpty else { return }
            imgV.isHidden = false
            let icon = NSWorkspace.shared.icon(forFile: path)
            imgV.image = icon
        }
    }

    func configApps(obj: Application_List?) {
        guard let model = obj else { return }
        lblTitle.stringValue = model.name ?? "-"

        let icon = NSWorkspace.shared.icon(forFile: model.path ?? "")
        imgV.image = icon
    }
}
