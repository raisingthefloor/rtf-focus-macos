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

class BlocklistDialogueViewC: NSViewController {
    @IBOutlet var listContainerV: NSView!
    @IBOutlet var lblTitle: NSTextField!
    @IBOutlet var tblView: NSTableView!
    @IBOutlet var btnAdd: CustomButton!
    @IBOutlet var btnClose: CustomButton!

    var listType: ListDialogue = .category_list
    var categoryName: String = ""
    var objCat: Block_Category?
    var arrAppsWeb: [Block_Category_App_Web] = []

    var addedSuccess: (([[String: Any?]]) -> Void)?
    var dataModel: DataModelType = DataModel()

    override func viewDidLoad() {
        super.viewDidLoad()
        setUpText()
        setUpViews()
        themeSetUp()
        bindData()
        tableViewSetup()
    }
}

extension BlocklistDialogueViewC: BasicSetupType {
    func setUpText() {
        categoryName = objCat?.name ?? "-"
        btnAdd.title = listType.add_button_title
        btnClose.title = NSLocalizedString("Button.cancel", comment: "Cancel")
    }

    func setUpViews() {
        view.window?.level = .floating
        view.background_color = Color.edit_bg_color

        lblTitle.font = listType.font // set font as per the dialogue
        lblTitle.textColor = .black

        if listType == .category_list {
            btnClose.isHidden = true
            let title = listType.title + "\n" + categoryName
            let attributedValue = NSMutableAttributedString.getAttributedString(fromString: title)
            attributedValue.apply(font: NSFont.systemFont(ofSize: 18, weight: .bold), subString: categoryName)
            attributedValue.alignment(alignment: .natural, lineSpace: 4, subString: title)
            lblTitle.attributedStringValue = attributedValue
        } else {
            let subTitle = NSLocalizedString("List.title_sub", comment: "Only apps on this computer are listed.")
            let title = listType.title + " " + subTitle
            let attributedValue = NSMutableAttributedString.getAttributedString(fromString: title)
            attributedValue.apply(font: NSFont.systemFont(ofSize: 12, weight: .bold), subString: listType.title)
            attributedValue.apply(font: AppFont.italic.size(12), subString: subTitle)
            
            
            lblTitle.attributedStringValue = attributedValue
        }

        btnAdd.buttonColor = Color.green_color
        btnAdd.activeButtonColor = Color.green_color
        btnAdd.textColor = .white
        btnAdd.font = NSFont.systemFont(ofSize: 12, weight: .semibold)
        
        btnClose.buttonColor = Color.very_light_grey
        btnClose.activeButtonColor = Color.very_light_grey
        btnClose.textColor = Color.black_color
        btnClose.borderColor = Color.dark_grey_border
        btnClose.borderWidth = 0.6
        btnClose.font = NSFont.systemFont(ofSize: 12, weight: .bold)

        listContainerV.border_color = Color.dark_grey_border
        listContainerV.border_width = 0.5
        listContainerV.background_color = .white
        listContainerV.corner_radius = 4
    }

    func bindData() {
        btnAdd.target = self
        btnAdd.action = #selector(btnAction(_:))
        btnClose.target = self
        btnClose.action = #selector(btnClose(_:))
        if listType == .category_list {
            arrAppsWeb = objCat?.sub_data?.allObjects as! [Block_Category_App_Web]
            arrAppsWeb = arrAppsWeb.sorted(by: ({ $0.block_type < $1.block_type }))
        }
    }

    @objc func btnClose(_ sender: NSButton) {
        dismiss(nil)
    }

    @objc func btnAction(_ sender: NSButton) {
        if listType == .category_list {
            dismiss(sender)
        } else {
            if !listType.selectedData.isEmpty {
                guard let dataV = listType.selectedData as? [[String: Any?]] else { return }
                listType.resetSelection
                addedSuccess?(dataV)
                dismiss(sender)
            } else {
                addedSuccess?([])
                dismiss(sender)
            }
        }
    }
}

extension BlocklistDialogueViewC: NSTableViewDataSource, NSTableViewDelegate {
    func tableViewSetup() {
        tblView.delegate = self
        tblView.dataSource = self
        tblView.rowHeight = 23
        tblView.selectionHighlightStyle = .none

        if listType == .category_list {
            tblView.tableColumns.forEach { column in
                if column.identifier == NSUserInterfaceItemIdentifier(rawValue: "checkIdentifier") {
                    column.isHidden = true
                }
            }
        }
    }

    func numberOfRows(in tableView: NSTableView) -> Int {
        if listType == .category_list {
            return arrAppsWeb.count
        }
        return listType.arrData.count
    }

    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        return setupCell(tableView: tableView, tableColumn: tableColumn, row: row)
    }

    func setupCell(tableView: NSTableView, tableColumn: NSTableColumn?, row: Int) -> NSView? {
        if tableColumn?.identifier == NSUserInterfaceItemIdentifier(rawValue: "checkIdentifier") {
            if let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "checkId"), owner: nil) as? ButtonCell {
                cell.btnAddApp.target = self
                cell.btnAddApp.tag = row
                cell.btnAddApp.action = #selector(toggleUse(_:))
                if listType != .category_list { // For temp
                    let obj = listType.arrData[row]
                    cell.btnAddApp.state = ((obj as? Application_List)?.is_selected ?? false) ? .on : .off
                }
                return cell
            }
        } else {
            if let categoryCell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "nameId"), owner: nil) as? ImageTextCell {
                categoryCell.imgV.isHidden = !listType.isIconVisible
                if listType != .category_list {
                    let obj = listType.arrData[row]
                    categoryCell.configApps(obj: obj as? Application_List)
                } else {
                    let objSubCat = arrAppsWeb[row] as? Block_Category_App_Web
                    categoryCell.configSubCategory(obj: objSubCat)
                }
                return categoryCell
            }
        }
        return nil
    }

    @objc func toggleUse(_ sender: NSButton) {
        let state = sender.state
        let obj = listType.arrData[sender.tag]
        (obj as? Application_List)?.is_selected = !((obj as? Application_List)?.is_selected ?? false)
        // tblView.reloadData()
    }
}
