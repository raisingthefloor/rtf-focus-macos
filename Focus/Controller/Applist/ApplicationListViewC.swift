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

class ApplicationListViewC: NSViewController {
    @IBOutlet var topView: NSView!
    @IBOutlet var btnClose: NSButton!
    @IBOutlet var lblTitle: NSTextField!
    @IBOutlet var tblApplication: NSTableView!

    @IBOutlet var bottomView: NSView!
    @IBOutlet var btnApply: NSButton!
    var arrApplicatios: [Application_List] = []
    var applySuccess: ((Bool) -> Void)?

    let viewModel: BlockListViewModelType = BlockListViewModel()

    override func viewDidLoad() {
        super.viewDidLoad()
        setUpText()
        setUpViews()
        bindData()
        tableViewSetup()
    }
}

extension ApplicationListViewC: BasicSetupType {
    func setUpText() {
        btnApply.title = NSLocalizedString("Button.apply", comment: "Apply")
        lblTitle.stringValue = NSLocalizedString("Applications", comment: "Applications")
    }

    func setUpViews() {
        arrApplicatios = DBManager.shared.getApplicationList()
    }

    func bindData() {
        btnClose.target = self
        btnClose.action = #selector(closeWindow(_:))
        btnApply.target = self
        btnApply.action = #selector(apply(_:))
    }

    @objc func closeWindow(_ sender: Any) {
        dismiss(nil)
    }

    @objc func apply(_ sender: Any) {
        // Store the application in block list
        let data = arrApplicatios.filter({ $0.is_selected }).compactMap({ $0 })
        for obj in data {
            let data: [String: Any?] = ["name": obj.name, "created_at": Date(), "bundle_id": obj.bundle_id, "is_selected": false, "is_deleted": false, "block_type": BlockType.application.rawValue]
            viewModel.input.storeOverridesBlock(data: data) { _ in
            }
        }

        applySuccess?(true)
        dismiss(nil)
    }
}

extension ApplicationListViewC: NSTableViewDataSource, NSTableViewDelegate {
    func tableViewSetup() {
        tblApplication.delegate = self
        tblApplication.dataSource = self
        tblApplication.usesAutomaticRowHeights = true
    }

    func numberOfRows(in tableView: NSTableView) -> Int {
        return arrApplicatios.count
    }

    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        return setupCell(tableView: tableView, tableColumn: tableColumn, row: row)
    }

    func setupCell(tableView: NSTableView, tableColumn: NSTableColumn?, row: Int) -> NSView? {
        let obj = arrApplicatios[row]
        if tableColumn?.identifier == NSUserInterfaceItemIdentifier(rawValue: "useIdentifier") {
            if let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "buttonId"), owner: nil) as? ButtonCell {
                cell.btnAddApp.target = self
                cell.btnAddApp.tag = row
                cell.btnAddApp.action = #selector(toggleUse(_:))
                cell.btnAddApp.state = obj.is_selected ? .on : .off
                return cell
            }
        } else {
            if let cellText = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "nameCell"), owner: nil) as? NSTableCellView {
                cellText.textField?.stringValue = obj.name ?? "-"
                return cellText
            }
        }
        return nil
    }

    @objc func toggleUse(_ sender: NSButton) {
        let state = sender.state
        let obj = arrApplicatios[sender.tag]
        obj.is_selected = !obj.is_selected
        tblApplication.reloadData()
    }
}
