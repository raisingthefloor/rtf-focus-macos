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

class EditBlockListViewC: BaseViewController {
    @IBOutlet var scrollView: NSScrollView!
    @IBOutlet var lblTitle: NSTextField!
    @IBOutlet var lblSubTitle: NSTextField!

    @IBOutlet var lblBlockTitle: NSTextField!
    @IBOutlet var mainView: NSView!

    @IBOutlet var comboBlock: NSPopUpButton!
    @IBOutlet var lblListTitle: NSTextField!

    @IBOutlet var listCategoryContainerV: NSView!
    @IBOutlet var lblCategoryTitle: NSTextField!
    @IBOutlet var tblCategory: NSTableView!

    @IBOutlet var listBlocklContainerV: NSView!
    @IBOutlet var lblBlockAppTitle: NSTextField!
    @IBOutlet var tblBlock: NSTableView!

    @IBOutlet var btnBContainerV: NSView!
    @IBOutlet var btnBAddApp: CustomButton!
    @IBOutlet var btnBAddWeb: CustomButton!

    @IBOutlet var listNotBContainerV: NSView!
    @IBOutlet var lblExceptionTitle: NSTextField!
    @IBOutlet var lblExceptionSubTitle: NSTextField!
    @IBOutlet var tblNotBlock: NSTableView!
    @IBOutlet var btnNBContainerV: NSView!
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

    var blockList = ["email", "slack", "Skype", "LinkedIn", "Yahoo"]

    let cellIdentifier: String = "checkboxCellID"
    let addCellIdentifier: String = "addCellID"

    override func viewDidLoad() {
        super.viewDidLoad()
        setUpText()
        setUpViews()
        bindData()
        tableViewSetup()
    }

    override func scrollWheel(with event: NSEvent) {
        if !event.momentumPhase.isEmpty || !event.phase.isEmpty {
            // magic trackpad or magic mouse
            super.scrollWheel(with: event)
        } else if event.modifierFlags.contains(.option) {
            // traditional mouse
            if let centerPoint = scrollView.documentView?.convert(event.locationInWindow, from: nil) {
                let linearVal = CGFloat(log2(scrollView.magnification))
                var linearDeltaY = event.scrollingDeltaY * 0.01
                if !event.hasPreciseScrollingDeltas {
                    linearDeltaY *= scrollView.verticalLineScroll
                }
                scrollView.setMagnification(CGFloat(pow(2, linearVal + linearDeltaY)), centeredAt: centerPoint)
            }
        }
    }

    public class func scrollMouse(onPoint point: CGPoint, xLines: Int, yLines: Int) {
        if #available(OSX 10.13, *) {
            guard let scrollEvent = CGEvent(scrollWheelEvent2Source: nil, units: CGScrollEventUnit.line, wheelCount: 2, wheel1: Int32(yLines), wheel2: Int32(xLines), wheel3: 0) else {
                return
            }
            scrollEvent.setIntegerValueField(CGEventField.eventSourceUserData, value: 1)
            scrollEvent.post(tap: CGEventTapLocation.cghidEventTap)
        } else {
            // scroll event is not supported for macOS older than 10.13
        }
    }
}

extension EditBlockListViewC: BasicSetupType {
    func setUpText() {
        lblTitle.stringValue = NSLocalizedString("BS.title", comment: "Edit Blocklists")
        let subtitle = NSLocalizedString("BS.subTitle", comment: "A blocklist is a group of apps, websites and other items that you can choose to block during a focus session. Learn more about Blocklists")

        let attributedText = NSMutableAttributedString.getAttributedString(fromString: subtitle)
        attributedText.underLine(subString: "Learn more about Blocklists") // Need to add seprate string
        attributedText.apply(color: Color.blue_color, subString: "Learn more about Blocklists")
        lblSubTitle.attributedStringValue = attributedText

        lblBlockTitle.stringValue = NSLocalizedString("BS.select_list", comment: "Select a blocklist to edit:")
        lblListTitle.stringValue = NSLocalizedString("BS.following_select_list", comment: "The following settings only apply to the selected blocklist")

        lblCategoryTitle.stringValue = NSLocalizedString("BS.category_title", comment: "Block all items in these categories:")
        lblBlockAppTitle.stringValue = NSLocalizedString("BS.block_app_title", comment: "Also, block these apps & websites:")

        btnBAddApp.title = NSLocalizedString("Button.add_app", comment: "Add App")
        btnBAddWeb.title = NSLocalizedString("Button.add_website", comment: "Add Website")

        btnNBAddApp.title = NSLocalizedString("Button.add_app", comment: "Add App")
        btnNBAddWeb.title = NSLocalizedString("Button.add_website", comment: "Add Website")

        lblExceptionTitle.stringValue = NSLocalizedString("BS.exception_title", comment: "Exceptions to blocked items:")
        lblExceptionSubTitle.stringValue = NSLocalizedString("BS.exception_subtitle", comment: "These will not be blocked even if in one of the lists above:")

        lblBlockBehaviour.stringValue = NSLocalizedString("BS.block_behaviour", comment: "Blocklist behavior during breaks:")
        radioShortLongBreak.title = NSLocalizedString("BS.short_long_break", comment: "Unblock this blocklist during short and long breaks")
        radioLongBreak.title = NSLocalizedString("BS.long_break", comment: "Unblock this blocklist during long breaks only")
        radioAllBreak.title = NSLocalizedString("BS.all_break", comment: "Keep this blocklist blocked during all breaks")

        lblEarlyTitle.stringValue = NSLocalizedString("BS.early_title", comment: "Discourage me from stopping early:")

        radioStopAnyTime.title = NSLocalizedString("BS.stop_any_time", comment: "No, let me stop the focus session at any time")
        radioStopFocus.title = NSLocalizedString("BS.stop_focus_session", comment: "Yes, make me type to stop the focus session:")
        lblRandom.stringValue = NSLocalizedString("BS.random_chracter", comment: "random characters")
        radioRestart.title = NSLocalizedString("BS.restart", comment: "Yes, make me restart my computer to stop the focus session")
    }

    func setUpViews() {
        mainView.border_color = Color.dark_grey_border
        mainView.border_width = 0.6
        mainView.background_color = Color.edit_bg_color
        mainView.corner_radius = 6

        btnBAddApp.buttonColor = Color.green_color
        btnBAddApp.activeButtonColor = Color.green_color
        btnBAddApp.textColor = .white
        btnBAddApp.font = NSFont.systemFont(ofSize: 13, weight: .semibold)

        btnBAddWeb.buttonColor = Color.green_color
        btnBAddWeb.activeButtonColor = Color.green_color
        btnBAddWeb.textColor = .white
        btnBAddWeb.font = NSFont.systemFont(ofSize: 13, weight: .semibold)

        btnNBAddApp.buttonColor = Color.green_color
        btnNBAddApp.activeButtonColor = Color.green_color
        btnNBAddApp.textColor = .white
        btnNBAddApp.font = NSFont.systemFont(ofSize: 13, weight: .semibold)

        btnNBAddWeb.buttonColor = Color.green_color
        btnNBAddWeb.activeButtonColor = Color.green_color
        btnNBAddWeb.textColor = .white
        btnNBAddWeb.font = NSFont.systemFont(ofSize: 13, weight: .semibold)

        listCategoryContainerV.border_color = Color.dark_grey_border
        listCategoryContainerV.border_width = 0.5
        listCategoryContainerV.background_color = .white
        listCategoryContainerV.corner_radius = 4

        listBlocklContainerV.border_color = Color.dark_grey_border
        listBlocklContainerV.border_width = 0.5
        listBlocklContainerV.background_color = .white
        listBlocklContainerV.corner_radius = 4

        listNotBContainerV.border_color = Color.dark_grey_border
        listNotBContainerV.border_width = 0.5
        listNotBContainerV.background_color = .white
        listNotBContainerV.corner_radius = 4

        btnBContainerV.background_color = Color.list_bg_color
        btnNBContainerV.background_color = Color.list_bg_color

        lblTitle.font = NSFont.systemFont(ofSize: 18, weight: .semibold)
        lblTitle.textColor = .black

        lblBlockTitle.font = NSFont.systemFont(ofSize: 12, weight: .semibold)
        lblBlockTitle.textColor = .black

        comboBlock.font = NSFont.systemFont(ofSize: 12, weight: .regular)

        lblCategoryTitle.font = NSFont.systemFont(ofSize: 12, weight: .semibold)
        lblCategoryTitle.textColor = .black

        lblBlockAppTitle.font = NSFont.systemFont(ofSize: 12, weight: .semibold)
        lblBlockAppTitle.textColor = .black

        lblExceptionTitle.font = NSFont.systemFont(ofSize: 12, weight: .semibold)
        lblExceptionTitle.textColor = .black

        // lblExceptionSubTitle.font = NSFont.systemFont(ofSize: 12, weight: .semibold) // Italic
        lblExceptionTitle.textColor = Color.black_color

        radioShortLongBreak.font = NSFont.systemFont(ofSize: 12, weight: .regular)
        radioRestart.font = NSFont.systemFont(ofSize: 12, weight: .regular)
        radioAllBreak.font = NSFont.systemFont(ofSize: 12, weight: .regular)

        radioStopFocus.font = NSFont.systemFont(ofSize: 12, weight: .regular)
        radioStopAnyTime.font = NSFont.systemFont(ofSize: 12, weight: .regular)
        radioLongBreak.font = NSFont.systemFont(ofSize: 12, weight: .regular)

        txtCharacter.font = NSFont.systemFont(ofSize: 12, weight: .regular)
        lblRandom.font = NSFont.systemFont(ofSize: 12, weight: .regular)
        lblRandom.textColor = .black

        if scrollView.hasVerticalScroller {
            scrollView.verticalScroller?.floatValue = 0
        }

        var newScrollOrigin: NSPoint = NSPoint(x: 0, y: 0)
        if let isFlipped = scrollView.documentView?.isFlipped, isFlipped {
            newScrollOrigin = NSMakePoint(0.0, 0.0)
        } else {
            newScrollOrigin = NSMakePoint(0.0, NSMaxY(scrollView.documentView?.frame ?? .zero) - NSHeight(scrollView.contentView.bounds))
        }
        scrollView.documentView?.scroll(newScrollOrigin)
    }

    func bindData() {
        btnBAddWeb.target = self
        btnBAddWeb.action = #selector(addWebAction(_:))

        btnBAddApp.target = self
        btnBAddApp.action = #selector(addAppAction(_:))

        btnNBAddWeb.target = self
        btnNBAddWeb.action = #selector(addWebAction(_:))

        btnNBAddApp.target = self
        btnNBAddApp.action = #selector(addAppAction(_:))
    }

    @objc func addAppAction(_ sender: NSButton) {
    }

    @objc func addWebAction(_ sender: NSButton) {
        openPopup()
    }

    @objc func deleAppAction(_ sender: NSButton) {
    }

    func openPopup() {
        let paths = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)
        print(paths[0])

        promptToForInput("Enter Web Url", "Copy Url from Webrowser and paste it below.", completion: { (value: String, action: Bool) in
            if action {
                print(value)

                let data: [String: Any] = ["url": value, "name": value, "created_at": Date(), "is_selected": false, "is_deleted": false, "block_type": BlockType.web.rawValue]
                viewModel.input.storeOverridesBlock(data: data) { _ in
                }
            }
        })
    }
}

extension EditBlockListViewC: NSTableViewDataSource, NSTableViewDelegate {
    func tableViewSetup() {
        tblCategory.delegate = self
        tblCategory.dataSource = self
        tblCategory.usesAutomaticRowHeights = true
        tblCategory.reloadData()

        tblBlock.delegate = self
        tblBlock.dataSource = self
        tblBlock.usesAutomaticRowHeights = true
        tblBlock.reloadData()

        tblNotBlock.delegate = self
        tblNotBlock.dataSource = self
        tblNotBlock.usesAutomaticRowHeights = true
        tblNotBlock.reloadData()
    }

    func numberOfRows(in tableView: NSTableView) -> Int {
        return blockList.count
    }

    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        return setupCellForDifferentTable(tableView, viewFor: tableColumn, row: row)
    }

    func setupCellForDifferentTable(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        if tableView.identifier == NSUserInterfaceItemIdentifier(rawValue: "categoryIdentifier") {
            if tableColumn?.identifier == NSUserInterfaceItemIdentifier(rawValue: "checkIdentifier") {
                if let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "checkId"), owner: nil) as? ButtonCell {
                    return cell
                }

            } else if tableColumn?.identifier == NSUserInterfaceItemIdentifier(rawValue: "nameIdentifier") {
                if let categoryCell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "nameId"), owner: nil) as? ImageTextCell {
                    categoryCell.configCategory(val: blockList[row])
                    return categoryCell
                }
            }
            return nil
        } else if tableView.identifier == NSUserInterfaceItemIdentifier(rawValue: "blockIdentifier") {
            if tableColumn?.identifier == NSUserInterfaceItemIdentifier(rawValue: "nameIdentifier1") {
                if let bCell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "nameId"), owner: nil) as? ImageTextCell {
                    bCell.configCell(val: blockList[row])
                    return bCell
                }
            } else if tableColumn?.identifier == NSUserInterfaceItemIdentifier(rawValue: "deleteIdentifier1") {
                if let dCell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "deleteID"), owner: nil) as? ButtonCell {
                    dCell.btnAddApp.tag = row
                    dCell.btnAddApp.target = self
                    dCell.btnAddApp.action = #selector(deleAppAction(_:))
                    return dCell
                }
            }
            return nil
        } else if tableView.identifier == NSUserInterfaceItemIdentifier(rawValue: "exceptionIdentifier") {
            if tableColumn?.identifier == NSUserInterfaceItemIdentifier(rawValue: "nameIdentifier2") {
                if let nBCell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "nameId"), owner: nil) as? ImageTextCell {
                    nBCell.configCell(val: blockList[row])
                    return nBCell
                }
            } else if tableColumn?.identifier == NSUserInterfaceItemIdentifier(rawValue: "deleteIdentifier2") {
                if let deleteCell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "deleteID"), owner: nil) as? ButtonCell {
                    deleteCell.btnAddApp.tag = row
                    deleteCell.btnAddApp.target = self
                    deleteCell.btnAddApp.action = #selector(deleAppAction(_:))
                    return deleteCell
                }
            }
            return nil
        }

        return nil
    }

    func tableViewSelectionDidChange(_ notification: Notification) {
        if let tblV = notification.object as? NSTableView {
            let selectedRow = tblV.selectedRow
            let option = blockList[selectedRow]
        }
    }
}
