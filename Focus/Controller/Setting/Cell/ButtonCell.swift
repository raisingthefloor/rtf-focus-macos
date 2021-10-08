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

class ButtonCell: NSTableCellView {
    // TODO: Need to update the name of the buttons as it previously define as per the old design
    @IBOutlet var btnAddApp: NSButton!
    @IBOutlet var btnAddWeb: NSButton!

    override func prepareForReuse() {
        super.prepareForReuse()
    }

    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        setUpText()
        setUpViews()
    }
}

extension ButtonCell: BasicSetupType {
    func setUpText() {
    }

    func setUpViews() {
    }

    func configBlockCell() {
        btnAddApp.title = BlockType.application.title
        btnAddWeb.title = BlockType.web.title
    }

    func bindTarget(target: AnyObject?) {
        btnAddApp.target = target
        btnAddWeb.target = target
        btnAddApp.tag = BlockType.application.rawValue
        btnAddWeb.tag = BlockType.web.rawValue
    }

    func configScheduleActionCell(isPause: Bool) {
        btnAddApp.title = isPause ? "🚫" : "⏸"
    }

    func configCategoryCell(row: Int, objCat: Block_Category, objBlocklist: Block_List?, target: AnyObject?, action: Selector?) {
        let arrCate = objBlocklist?.block_category?.allObjects as? [Block_List_Category]
        btnAddApp.tag = row
        btnAddApp.target = target
        let isSelected = arrCate?.compactMap({ $0.id == objCat.id }).filter({ $0 }).first ?? false
        btnAddApp.state = isSelected ? .on : .off
        btnAddApp.action = action
    }

    func configGCategoryCell(row: Int, objSubCat: Block_SubCategory?, target: AnyObject?, action: Selector?) {
        btnAddApp.tag = row
        btnAddApp.target = target
        let isSelected = objSubCat?.is_selected ?? false
        btnAddApp.state = isSelected ? .on : .off
        btnAddApp.action = action
    }

    func configScheduleActive(obj: Focus_Schedule?, row: Int, target: AnyObject?, action: Selector?, action_delete: Selector?) {
        //Checkbox
        btnAddApp.tag = row
        btnAddApp.target = target
        let is_active = obj?.is_active ?? false
        btnAddApp.state = is_active ? .on : .off
        btnAddApp.action = action
        
        //Delete
        btnAddWeb.tag = row
        btnAddWeb.target = target
        btnAddWeb.action = action_delete
    }
}
