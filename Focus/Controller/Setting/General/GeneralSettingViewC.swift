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

class GeneralSettingViewC: BaseViewController {
    @IBOutlet var lblBehaviorTitle: NSTextField!
    @IBOutlet var checkBoxlock: NSButton!
    @IBOutlet var lbllockInfo: NSTextField!

    @IBOutlet var checkBoxShowTimer: NSButton!

    @IBOutlet var checkBoxCountUp: NSButton!

    @IBOutlet var lblUnblockingTitle: NSTextField!
    @IBOutlet var lblUnblockingInfo: NSTextField!
    @IBOutlet var lblAllowInfo: NSTextField!

    @IBOutlet var lblOverrideTitle: NSTextField!
    @IBOutlet var lblOverrideInfo: NSTextField!

    @IBOutlet var boxOverridelist: NSBox!
    @IBOutlet var btnEdit: NSButton!

    override func setTitle() -> String { return SettingOptions.general_setting.title }

    override func viewDidLoad() {
        super.viewDidLoad()
        setUpText()
        setUpViews()
        bindData()
    }
}

extension GeneralSettingViewC: BasicSetupType {
    func setUpText() {
        lblBehaviorTitle.stringValue = NSLocalizedString("GS.behaviorTitle", comment: "Behavior During Focus Period")
        checkBoxlock.title = NSLocalizedString("GS.lock_computer", comment: "Lock my computer screen for first minute during  Break")
        lbllockInfo.stringValue = NSLocalizedString("GS.lock_computer_info", comment: "(To force me to take a break away from computer for at LEAST 1 min.)")

        checkBoxShowTimer.title = NSLocalizedString("GS.countdown_timer", comment: "Show countdown timer for focus and breaks")
        checkBoxCountUp.title = NSLocalizedString("GS.countup_timer", comment: "Show countUP timer for 'Focus until I Stop'")

        lblUnblockingTitle.stringValue = NSLocalizedString("GS.unblockingtitle", comment: "Allow unblocking of key programs")
        lblUnblockingInfo.stringValue = NSLocalizedString("GS.unblockinginfo", comment: "(Sometimes you may need to unblock a program or website temporarily during a focus session in order to complete work, but the program or website is part of an active BlockList.)")
        lblAllowInfo.stringValue = NSLocalizedString("GS.allowinfo", comment: "This feature  allows user to override a block for the rest of the day.")

        lblOverrideTitle.stringValue = NSLocalizedString("GS.overridetitle", comment: "List of allowable overrides.")
        lblOverrideInfo.stringValue = NSLocalizedString("GS.overrideinfo", comment: "Check item to override blocking until next day")

        btnEdit.title = NSLocalizedString("GS.edit_list", comment: "Edit List")
    }

    func setUpViews() {
    }

    func bindData() {
        setupBoxData()
    }
}

extension GeneralSettingViewC {
    func setupBoxData() {
        let blockList = ["email", "slackt", "Skype", "LinkedIn"]

        let content = NSStackView(views: [])
        
        content.orientation = NSUserInterfaceLayoutOrientation.vertical
        // Get the data from DB
        for val in blockList {
            let checkBox = NSButton(checkboxWithTitle: val, target: self, action: #selector(checkBoxEventHandler(_:)))
            content.addArrangedSubview(checkBox)
        }
        boxOverridelist.contentView = content
    }

    @objc func checkBoxEventHandler(_ sender: NSButton) {
        print(" Check Box Event : \(sender.state) ::: \(sender.title)")
    }
}
