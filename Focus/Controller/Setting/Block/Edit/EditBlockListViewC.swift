//
//  EditBlockListViewC.swift
//  Focus
//
//  Created by Bhavi on 10/09/21.
//  Copyright © 2021 Raising the Floor. All rights reserved.
//

import Cocoa

class EditBlockListViewC: BaseViewController {
    @IBOutlet var lblTitle: NSTextField!
    @IBOutlet var lblSubTitle: NSTextField!

    @IBOutlet var lblBlockTitle: NSTextField!
    @IBOutlet var comboBlock: NSPopUpButton!
    @IBOutlet var lblListTitle: NSTextField!

    @IBOutlet var tblCategory: NSTableView!
    @IBOutlet var tblBlock: NSTableView!
    @IBOutlet var btnBAddApp: CustomButton!
    @IBOutlet var btnBAddWeb: CustomButton!

    @IBOutlet var lblExceptionTitle: NSTextField!
    @IBOutlet var lblExceptionSubTitle: NSTextField!
    @IBOutlet var tblNotBlock: NSTableView!
    @IBOutlet var btnNBAddApp: CustomButton!
    @IBOutlet var btnNBAddWeb: CustomButton!

    @IBOutlet var lblBlockBehaviour: NSTextField!
    @IBOutlet var radioShortLongBreak: NSButton!
    @IBOutlet var radioLongBreak: NSButton!
    @IBOutlet var radioAllBreak: NSButton!

    @IBOutlet var lblEarlyTitle: NSTextField!
    @IBOutlet var radioStopAnyTime: NSButton!
    @IBOutlet var radioStopFocus: NSButton!
    @IBOutlet var txtCharacter: NSTextField!
    @IBOutlet var lblRandom: NSTextField!

    @IBOutlet var radioRestart: NSButton!

    let viewModel: BlockListViewModelType = BlockListViewModel()
    var webSites: [Override_Block] = []

    let cellIdentifier: String = "checkboxCellID"
    let addCellIdentifier: String = "addCellID"

    override func viewDidLoad() {
        super.viewDidLoad()
        setUpText()
        setUpViews()
        bindData()
        tableViewSetup()
    }
}

extension EditBlockListViewC: BasicSetupType {
    func setUpText() {
        lblSettingInfo.stringValue = NSLocalizedString("BS.blocksetting_info", comment: "You can choose the apps and website you want  to have blocked when you are focusing.  You can select categories (on the left) or you can just list individual apps and websites (on the right).  You can use a premade set – or you can make your own sets.  If you try to use an application or website you have blocked during a focus session it will not launch or will immediately shut down with a message ”You selected this to be blocked during your focus session”.")

        lblRename.stringValue = NSLocalizedString("BS.rename_edit", comment: "Show/edit/rename BlockList Named")
        lblAdditionalTitle.stringValue = NSLocalizedString("BS.additional_options", comment: "Additional Options for this BlockList (only)")
        lblHard.stringValue = NSLocalizedString("BS.make_hard", comment: "Make it hard for me to STOP a FOCUS Session early (Lock it)")
        radioLeave.title = NSLocalizedString("BS.leave_it", comment: "No - Leave it so I can unlock focus any time with the click of one of the STOP buttons.")
        radioRandom.title = NSLocalizedString("BS.random_character", comment: "🔒 - Make me type a string of random characters you give me to type  [30] characters")
        radioSignout.title = NSLocalizedString("BS.sign_out", comment: "🔒 - Make me Sign out and back in to stop focus session")

        lblScheduleTitle.stringValue = NSLocalizedString("BS.schedule_title", comment: "Scheduling Options (FOR THIS BLOCKLIST ONLY)")
        checkboxLongBreak.title = NSLocalizedString("BS.short_long", comment: "Unblock this list during short and long breaks during scheduled focus periods")
        checkboxOnlyLong.title = NSLocalizedString("BS.only_long", comment: "Unblock this list ONLY for long breaks  (at 2-hour points) in scheduled focus periods")
        checkboxContinues.title = NSLocalizedString("BS.continues", comment: "Continuously block this list for entire scheduled focus period (including breaks)")
        lblExample.stringValue = NSLocalizedString("BS.eg", comment: "(e.g. if you might create a BlockList for  just games – and want to make sure they are blocked all day – and not be available even during breaks)")
    }

    func setUpViews() {
    }

    func bindData() {
    }
}

extension EditBlockListViewC: NSTableViewDataSource, NSTableViewDelegate {
    func tableViewSetup() {
        tblCategory.delegate = self
        tblCategory.dataSource = self
        tblCategory.usesAutomaticRowHeights = true

        tblBlock.delegate = self
        tblBlock.dataSource = self
        tblBlock.usesAutomaticRowHeights = true

        tblNotBlock.delegate = self
        tblNotBlock.dataSource = self
        tblNotBlock.usesAutomaticRowHeights = true
    }
}
