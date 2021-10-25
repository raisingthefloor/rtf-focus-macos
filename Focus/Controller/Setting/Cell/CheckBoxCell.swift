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

class CheckBoxCell: NSTableCellView {
    @IBOutlet var checkBox: NSButton!
    @IBOutlet var btnDelete: NSButton!

    override func prepareForReuse() {
        super.prepareForReuse()
    }

    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
    }
}

extension CheckBoxCell {
    func configScheduleActive(obj: Focus_Schedule?, row: Int, target: AnyObject?, action: Selector?, action_delete: Selector?) {
        // Checkbox
        checkBox.tag = row
        checkBox.target = target
        checkBox.action = action
        let is_active = obj?.is_active ?? false
        checkBox.state = is_active ? .on : .off

        let image = (obj?.block_list_name != nil) ? NSImage(named: "ic_delete") : NSImage(named: "ic_grey_delete")

        if btnDelete != nil {
            // Delete
            btnDelete.tag = row
            btnDelete.target = target
            btnDelete.action = action_delete
            btnDelete.image = image
        }
    }
}
