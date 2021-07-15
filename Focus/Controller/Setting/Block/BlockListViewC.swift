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

class BlockListViewC: BaseViewController {
    @IBOutlet weak var lblSettingInfo: NSTextField!
    @IBOutlet weak var lblRename: NSTextField!
    
    @IBOutlet var tblCategory: NSTableView!
    @IBOutlet var tblBlock: NSTableView!
    @IBOutlet var tblNotBlock: NSTableView!
    @IBOutlet weak var comboBlock: NSPopUpButton!
    @IBOutlet weak var lblAdditionalTitle: NSTextField!
    @IBOutlet weak var lblHard: NSTextField!
    @IBOutlet weak var radioLeave: NSButton!
    @IBOutlet weak var radioRandom: NSButton!
    @IBOutlet weak var radioSignout: NSButton!
    @IBOutlet weak var lblScheduleTitle: NSTextField!
    @IBOutlet weak var checkboxLongBreak: NSButton!
    @IBOutlet weak var checkboxOnlyLong: NSButton!
    @IBOutlet weak var checkboxContinues: NSButton!

    @IBOutlet weak var lblExample: NSTextField!
    
    let viewModel: BlockListViewModelType = BlockListViewModel()
    var webSites: [String] = []

    let cellIdentifier: String = "checkboxCellID"
    let addCellIdentifier: String = "addCellID"

    override func setTitle() -> String { return SettingOptions.block_setting.title }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        setUpText()
        setUpViews()
        bindData()
        tableViewSetup()
    }
}

extension BlockListViewC: BasicSetupType {
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

extension BlockListViewC: NSTableViewDataSource, NSTableViewDelegate {
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

    func numberOfRows(in tableView: NSTableView) -> Int {
        return getCount(tableView: tableView)
    }

    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        return setupCellAsperTable(tableView: tableView, row: row)
    }

//    public func tableView(_ tableView: NSTableView, rowActionsForRow row: Int, edge: NSTableView.RowActionEdge) -> [NSTableViewRowAction] {
//        print("swipe")
//        // left swipe
//        if edge == .trailing {
//            let deleteAction = NSTableViewRowAction(style: .destructive, title: "Delete", handler: { _, row in
//                // action code
//                self.webSites.remove(at: row)
//                tableView.removeRows(at: IndexSet(integer: row), withAnimation: .effectFade)
//            })
//            deleteAction.backgroundColor = NSColor.red
//            return [deleteAction]
//        }
//        return []
//    }

    func setupCellAsperTable(tableView: NSTableView, row: Int) -> NSView? {
        if tableView == tblCategory {
            let blocks = viewModel.input.getBlockList()
            let item = blocks[row]

            if let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: cellIdentifier), owner: nil) as? CheckBoxCell {
                cell.checkBox.title = item.name ?? "-"

//                cell.checkBox.rx.tap.subscribe(onNext: { [weak self] _ in
//                    print("Block")
//                    print(cell.checkBox.state)
//                }).disposed(by: cell.disposeBag)

                return cell
            }

        } else if tableView == tblBlock {
            if row == 0 {
                if let buttonCell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: addCellIdentifier), owner: nil) as? ButtonCell {
                    
                    buttonCell.configBlockCell()
//                    buttonCell.btnAddApp.rx.tap.subscribe(onNext: { [weak self] _ in
//                        print("btnAddApp")
//                    }).disposed(by: buttonCell.disposeBag)
//
//                    buttonCell.btnAddWeb.rx.tap.subscribe(onNext: { [weak self] _ in
//                        self?.openPopup()
//                    }).disposed(by: buttonCell.disposeBag)

                    return buttonCell
                }
            }
            let item = webSites[row - 1]

            if let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: cellIdentifier), owner: nil) as? CheckBoxCell {
                cell.checkBox.title = item

//                cell.checkBox.rx.tap.subscribe(onNext: { [weak self] _ in
//                    print("Block")
//                    print(cell.checkBox.state)
//                }).disposed(by: cell.disposeBag)

                return cell
            }

        } else if tableView == tblNotBlock {
            if row == 0 {
                if let buttonCell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: addCellIdentifier), owner: nil) as? ButtonCell {
                    
                    buttonCell.configBlockCell()
//                    buttonCell.btnAddApp.rx.tap.subscribe(onNext: { [weak self] _ in
//                        print("btnAddApp")
//                    }).disposed(by: buttonCell.disposeBag)
//
//                    buttonCell.btnAddWeb.rx.tap.subscribe(onNext: { [weak self] _ in
//                        self?.openPopup()
//                    }).disposed(by: buttonCell.disposeBag)

                    return buttonCell
                }
            }

            let item = webSites[row - 1]

            if let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: addCellIdentifier), owner: nil) as? CheckBoxCell {
                cell.checkBox.title = item

//                cell.checkBox.rx.tap.subscribe(onNext: { [weak self] _ in
//                    print("Block")
//                    print(cell.checkBox.state)
//                }).disposed(by: cell.disposeBag)

                return cell
            }
        }

        return nil
    }

    func getCount(tableView: NSTableView) -> Int {
        if tableView == tblCategory {
            return viewModel.input.getBlockList().count
        } else if tableView == tblBlock {
            return webSites.count + 1
        } else if tableView == tblNotBlock {
            return webSites.count + 1
        }

        return 0
    }

    func listofApps() {
        let workspace = NSWorkspace.shared
        let apps = workspace.runningApplications.filter { $0.activationPolicy == .regular }
        print(apps)
    }

    func openPopup() {
        promptToForInput("Enter Web Url", "Copy Url from Webrowser and paste it below.", completion: { (value: String, action: Bool) in
            if action {
                print(value)
                webSites.append(value)
                tblBlock.reloadData()
                tblNotBlock.reloadData()
            }
        })
    }
}
