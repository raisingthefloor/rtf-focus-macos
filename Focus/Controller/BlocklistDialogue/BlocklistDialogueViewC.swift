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

    var listType: ListDialogue = .category_list

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
        btnAdd.title = listType.add_button_title
        lblTitle.stringValue = listType.title
    }

    func setUpViews() {
        
        view.window?.level = .floating
        view.background_color = Color.edit_bg_color

        lblTitle.font = NSFont.systemFont(ofSize: 12, weight: .semibold) // set font as per the dialogue
        lblTitle.textColor = .black

        btnAdd.buttonColor = Color.green_color
        btnAdd.activeButtonColor = Color.green_color
        btnAdd.textColor = .white
        btnAdd.font = NSFont.systemFont(ofSize: 13, weight: .semibold)

        listContainerV.border_color = Color.dark_grey_border
        listContainerV.border_width = 0.5
        listContainerV.background_color = .white
        listContainerV.corner_radius = 4
    }
    
    func bindData() {
        btnAdd.target = self
        btnAdd.action = #selector(btnAction(_:))
    }

    @objc func btnAction(_ sender: NSButton) {
        dismiss(sender)
    }

}

extension BlocklistDialogueViewC: NSTableViewDataSource, NSTableViewDelegate {
    func tableViewSetup() {
        tblView.delegate = self
        tblView.dataSource = self
        tblView.rowHeight = 23
    }

    func numberOfRows(in tableView: NSTableView) -> Int {
        return listType.arrData.count
    }

    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        return setupCell(tableView: tableView, tableColumn: tableColumn, row: row)
    }

    func setupCell(tableView: NSTableView, tableColumn: NSTableColumn?, row: Int) -> NSView? {
        let obj = listType.arrData[row]
        if tableColumn?.identifier == NSUserInterfaceItemIdentifier(rawValue: "checkIdentifier") {
            if let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "checkId"), owner: nil) as? ButtonCell {
                cell.btnAddApp.target = self
                cell.btnAddApp.tag = row
                cell.btnAddApp.action = #selector(toggleUse(_:))
                return cell
            }
        } else {
            if let categoryCell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "nameId"), owner: nil) as? ImageTextCell {
                categoryCell.configCategory(val: obj)
                return categoryCell
            }
        }
        return nil
    }

    @objc func toggleUse(_ sender: NSButton) {
        let state = sender.state
    }
}
