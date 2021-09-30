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
    @IBOutlet var lblNote1: NSTextField!
    @IBOutlet var lblNote2: NSTextField!

    let viewModel: BlockListViewModelType = BlockListViewModel()
    var dataModel: DataModelType = DataModel()

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

        lblNote1.stringValue = NSLocalizedString("BS.note_one", comment: "Note: You cannot change a blocklist while it is in use in an active focus session.")

        lblNote2.stringValue = NSLocalizedString("BS.note_two", comment: "Any changes made will not take effect until the next focus session where the blocklist is used.")
        txtCharacter.stringValue = "30"
    }

    func setUpViews() {
        updateBlocklistList()

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

//        lblNote1.font = NSFont.systemFont(ofSize: 13, weight: .bold) // Bold Italic
//        lblNote2.font = NSFont.systemFont(ofSize: 13, weight: .bold) // Bold Italic
        lblNote1.textColor = Color.note_color
        lblNote2.textColor = Color.note_color

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
        btnBAddWeb.tag = BlockList.block_web_app.rawValue

        btnBAddApp.target = self
        btnBAddApp.action = #selector(addAppAction(_:))
        btnBAddApp.tag = BlockList.block_web_app.rawValue

        btnNBAddWeb.target = self
        btnNBAddWeb.action = #selector(addWebAction(_:))
        btnNBAddWeb.tag = BlockList.exception_web_app.rawValue

        btnNBAddApp.target = self
        btnNBAddApp.action = #selector(addAppAction(_:))
        btnNBAddApp.tag = BlockList.exception_web_app.rawValue

        comboBlock.target = self
        comboBlock.action = #selector(handleBlockSelection(_:))
        txtCharacter.delegate = self
    }
}

extension EditBlockListViewC: NSTableViewDataSource, NSTableViewDelegate {
    func tableViewSetup() {
        tblCategory.delegate = self
        tblCategory.dataSource = self
        tblCategory.rowHeight = 25
        tblCategory.reloadData()

        tblBlock.delegate = self
        tblBlock.dataSource = self
        tblNotBlock.usesAutomaticRowHeights = true
        tblBlock.reloadData()

        tblNotBlock.delegate = self
        tblNotBlock.dataSource = self
        tblNotBlock.usesAutomaticRowHeights = true
        tblNotBlock.reloadData()
    }

    func numberOfRows(in tableView: NSTableView) -> Int {
        if tableView.identifier == NSUserInterfaceItemIdentifier(rawValue: "categoryIdentifier") {
            return dataModel.input.getCategoryList(cntrl: .edit_blocklist).1.count
        } else if tableView.identifier == NSUserInterfaceItemIdentifier(rawValue: "blockIdentifier") {
            return dataModel.objBlocklist?.block_app_web?.allObjects.count ?? 0
        } else {
            return dataModel.objBlocklist?.exception_block?.allObjects.count ?? 0
        }
    }

    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        return setupCellForDifferentTable(tableView, viewFor: tableColumn, row: row)
    }

    func setupCellForDifferentTable(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        if tableView.identifier == NSUserInterfaceItemIdentifier(rawValue: "categoryIdentifier") {
            let objCat = dataModel.input.getCategoryList(cntrl: .edit_blocklist).1[row]
            if tableColumn?.identifier == NSUserInterfaceItemIdentifier(rawValue: "checkIdentifier") {
                if let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "checkId"), owner: nil) as? ButtonCell {
                    cell.configCategoryCell(row: row, objCat: objCat, objBlocklist: dataModel.objBlocklist, target: self, action: #selector(addCategoryAction(_:)))
                    return cell
                }

            } else if tableColumn?.identifier == NSUserInterfaceItemIdentifier(rawValue: "nameIdentifier") {
                if let categoryCell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "nameId"), owner: nil) as? ImageTextCell {
                    categoryCell.configCategory(val: objCat.name ?? "")
                    return categoryCell
                }
            }
            return nil
        } else if tableView.identifier == NSUserInterfaceItemIdentifier(rawValue: "blockIdentifier") {
            let arrBlock = dataModel.objBlocklist?.block_app_web?.allObjects as? [Block_App_Web]
            let objBlock = arrBlock?[row] as? Block_Interface
            if tableColumn?.identifier == NSUserInterfaceItemIdentifier(rawValue: "nameIdentifier1") {
                if let bCell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "nameId"), owner: nil) as? ImageTextCell {
                    bCell.configCell(obj: objBlock)
                    return bCell
                }
            } else if tableColumn?.identifier == NSUserInterfaceItemIdentifier(rawValue: "deleteIdentifier1") {
                if let dCell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "deleteID"), owner: nil) as? ButtonCell {
                    dCell.btnAddApp.tag = row
                    dCell.btnAddApp.target = self
                    dCell.btnAddApp.action = #selector(deleteSetBlock(_:))
                    return dCell
                }
            }
            return nil
        } else if tableView.identifier == NSUserInterfaceItemIdentifier(rawValue: "exceptionIdentifier") {
            let arrBlock = dataModel.objBlocklist?.exception_block?.allObjects as? [Exception_App_Web]
            let objBlock = arrBlock?[row] as? Block_Interface

            if tableColumn?.identifier == NSUserInterfaceItemIdentifier(rawValue: "nameIdentifier2") {
                if let nBCell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "nameId"), owner: nil) as? ImageTextCell {
                    nBCell.configCell(obj: objBlock)
                    return nBCell
                }
            } else if tableColumn?.identifier == NSUserInterfaceItemIdentifier(rawValue: "deleteIdentifier2") {
                if let deleteCell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "deleteID"), owner: nil) as? ButtonCell {
                    deleteCell.btnAddApp.tag = row
                    deleteCell.btnAddApp.target = self
                    deleteCell.btnAddApp.action = #selector(deleteSetException(_:))
                    return deleteCell
                }
            }
            return nil
        }

        return nil
    }

    // Need to check other option to get the object
    func tableViewSelectionDidChange(_ notification: Notification) {
        if let tblV = notification.object as? NSTableView {
            let selectedRow = tblV.selectedRow
            guard selectedRow != -1 else { return }
            if tblV.identifier == NSUserInterfaceItemIdentifier(rawValue: "categoryIdentifier") {
                let objCat = dataModel.input.getCategoryList(cntrl: .edit_blocklist).1[selectedRow]
                let listDialogue = BlocklistDialogueViewC(nibName: "BlocklistDialogueViewC", bundle: nil)
                listDialogue.listType = .category_list
                listDialogue.categoryName = objCat.name ?? "-"
                presentAsSheet(listDialogue)
            }
        }
    }

    func tableView(_ tableView: NSTableView, rowViewForRow row: Int) -> NSTableRowView? {
        let view = LightRowView()
        return view
    }
}

// MARK: Common Methods and Button Action Here

extension EditBlockListViewC: NSTextFieldDelegate {
    func controlTextDidChange(_ notification: Notification) {
        let object = notification.object as! NSTextField
        txtCharacter.stringValue = object.stringValue
        dataModel.objBlocklist?.character_val = Int64(object.stringValue) ?? 36

        DBManager.shared.saveContext()
    }

    func updateBlocklistList() {
        comboBlock.menu = dataModel.input.getBlockList(cntrl: .edit_blocklist).0
        dataModel.objBlocklist = dataModel.input.getBlockList(cntrl: .edit_blocklist).1.first
        updateRadioOptions()
        reloadTables()
    }

    func updateRadioOptions() {
        // Blocklist Behaviour
        radioAllBreak.state = dataModel.objBlocklist?.blocked_all_break ?? false ? .on : .off
        radioLongBreak.state = dataModel.objBlocklist?.unblock_long_break_only ?? false ? .on : .off
        radioShortLongBreak.state = dataModel.objBlocklist?.unblock_short_long_break ?? true ? .on : .off

        // Discourage Stop Session
        radioRestart.state = dataModel.objBlocklist?.restart_computer ?? false ? .on : .off
        radioStopFocus.state = dataModel.objBlocklist?.random_character ?? false ? .on : .off
        radioStopAnyTime.state = dataModel.objBlocklist?.stop_focus_session_anytime ?? true ? .on : .off

        txtCharacter.stringValue = "\(dataModel.objBlocklist?.character_val ?? 36)"
    }

    // Store the Apps in Block Also and Exception as per selected blick list
    @objc func addAppAction(_ sender: NSButton) {
        let arrBlock = dataModel.input.getBlockList(cntrl: .edit_blocklist).1
        if !arrBlock.isEmpty {
            let controller = BlocklistDialogueViewC(nibName: "BlocklistDialogueViewC", bundle: nil)
            controller.listType = .system_app_list
            controller.dataModel.objBlocklist = dataModel.objBlocklist
            controller.addedSuccess = { [weak self] dataV in
                if sender.tag == BlockList.block_web_app.rawValue {
                    self?.dataModel.input.updateSelectedBlocklist(data: dataV) { isStore in
                        if isStore {
                            self?.reloadTables()
                        }
                    }
                } else {
                    self?.dataModel.input.updateSelectedExceptionlist(data: dataV) { isStore in
                        if isStore {
                            self?.reloadTables()
                        }
                    }
                }
            }
            presentAsSheet(controller)
        } else {
            systemAlert(title: "Focus", description: "Please, first create the block list then add the apps/Web inside it.", btnOk: "OK")
        }
    }

    // Store the Web URL in Block Also and Exception as per selected blick list
    @objc func addWebAction(_ sender: NSButton) {
        let arrBlock = dataModel.input.getBlockList(cntrl: .edit_blocklist).1
        if !arrBlock.isEmpty {
            let inputDialogueCntrl = InputDialogueViewC(nibName: "InputDialogueViewC", bundle: nil)
            inputDialogueCntrl.inputType = .add_website
            inputDialogueCntrl.dataModel.objBlocklist = dataModel.objBlocklist
            inputDialogueCntrl.addedSuccess = { [weak self] dataV in
                if sender.tag == BlockList.block_web_app.rawValue {
                    self?.dataModel.input.updateSelectedBlocklist(data: dataV) { isStore in
                        if isStore {
                            self?.reloadTables()
                        }
                    }
                } else {
                    self?.dataModel.input.updateSelectedExceptionlist(data: dataV) { isStore in
                        if isStore {
                            self?.reloadTables()
                        }
                    }
                }
            }
            presentAsSheet(inputDialogueCntrl)
        } else {
            systemAlert(title: "Focus", description: "Please, first create the block list then add the apps/Web inside it.", btnOk: "OK")
        }
    }

    // Remove the Apps and Web Url from Also Block View
    @objc func deleteSetBlock(_ sender: NSButton) {
        let arrBlock = dataModel.objBlocklist?.block_app_web?.allObjects as? [Block_App_Web]
        guard let objBlock = arrBlock?[sender.tag] as? Block_App_Web else { return }
        DBManager.shared.managedContext.delete(objBlock)
        DBManager.shared.saveContext()
        tblBlock.reloadData()
    }

    // Remove the Apps and Web Url from Exceptions view
    @objc func deleteSetException(_ sender: NSButton) {
        let arrBlock = dataModel.objBlocklist?.exception_block?.allObjects as? [Exception_App_Web]
        guard let objException = arrBlock?[sender.tag] as? Exception_App_Web else { return }
        DBManager.shared.managedContext.delete(objException)
        DBManager.shared.saveContext()
        tblNotBlock.reloadData()
    }

    // Store the Categories as per selected blick list
    @objc func addCategoryAction(_ sender: NSButton) {
        let obj = dataModel.input.getCategoryList(cntrl: .edit_blocklist).1[sender.tag]
        obj.is_selected = !obj.is_selected
        DBManager.shared.saveContext()
        dataModel.input.updateSelectedCategorylist(objCat: obj) { _ in
            self.reloadTables()
        }
    }

    @objc func handleBlockSelection(_ sender: Any) {
        guard sender is NSPopUpButton else { return }
        let index = comboBlock.selectedTag()
        if index == -1 {
            let inputDialogueCntrl = InputDialogueViewC(nibName: "InputDialogueViewC", bundle: nil)
            inputDialogueCntrl.inputType = .add_block_list_name
            inputDialogueCntrl.addedSuccess = { [weak self] _ in
                self?.updateBlocklistList()
                self?.reloadTables()
            }

            presentAsSheet(inputDialogueCntrl)
        } else {
            dataModel.objBlocklist = dataModel.input.getBlockList(cntrl: .edit_blocklist).1[index]
            updateRadioOptions()
        }
        reloadTables()
    }

    @IBAction func behaviorOptions(sender: NSButton) {
        if radioShortLongBreak.state == .on {
            radioLongBreak.state = .off
            radioAllBreak.state = .off

            dataModel.objBlocklist?.unblock_short_long_break = true
            dataModel.objBlocklist?.unblock_long_break_only = false
            dataModel.objBlocklist?.blocked_all_break = false
        }

        if radioLongBreak.state == .on {
            radioShortLongBreak.state = .off
            radioAllBreak.state = .off

            dataModel.objBlocklist?.unblock_long_break_only = true
            dataModel.objBlocklist?.unblock_short_long_break = false
            dataModel.objBlocklist?.blocked_all_break = false
        }

        if radioAllBreak.state == .on {
            radioLongBreak.state = .off
            radioShortLongBreak.state = .off

            dataModel.objBlocklist?.blocked_all_break = true
            dataModel.objBlocklist?.unblock_long_break_only = false
            dataModel.objBlocklist?.unblock_short_long_break = false
        }

        DBManager.shared.saveContext()
    }

    @IBAction func stopOptions(sender: NSButton) {
        if radioStopAnyTime.state == .on {
            radioStopFocus.state = .off
            radioRestart.state = .off

            dataModel.objBlocklist?.stop_focus_session_anytime = true
            dataModel.objBlocklist?.random_character = false
            dataModel.objBlocklist?.restart_computer = false
        }

        if radioStopFocus.state == .on {
            radioStopAnyTime.state = .off
            radioRestart.state = .off

            dataModel.objBlocklist?.stop_focus_session_anytime = false
            dataModel.objBlocklist?.random_character = true
            dataModel.objBlocklist?.restart_computer = false
        }

        if radioRestart.state == .on {
            radioStopAnyTime.state = .off
            radioStopFocus.state = .off

            dataModel.objBlocklist?.stop_focus_session_anytime = false
            dataModel.objBlocklist?.random_character = false
            dataModel.objBlocklist?.restart_computer = true
        }
        DBManager.shared.saveContext()
    }

    func reloadTables() {
        tblBlock.reloadData()
        tblNotBlock.reloadData()
        tblCategory.reloadData()
    }
}
