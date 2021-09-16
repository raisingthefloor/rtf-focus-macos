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

class CustomSettingController: NSViewController {
    @IBOutlet var topView: NSView!
    @IBOutlet var leftView: NSView!
    @IBOutlet var tblMenu: NSTableView!
    @IBOutlet var lblTitle: NSTextField!

    @IBOutlet var righView: NSView!

    override func viewDidLoad() {
        super.viewDidLoad()
        setUpText()
        setUpViews()
        bindData()
        tableViewSetup()
    }
}

extension CustomSettingController: BasicSetupType {
    func setUpText() {
        title = NSLocalizedString("Home.customize_focus", comment: "Customize Focus")
        lblTitle.stringValue = NSLocalizedString("Home.customize_focus", comment: "Customize Focus")
    }

    func setUpViews() {
        topView.background_color = Color.top_title_green_color
        tblMenu.backgroundColor = Color.green_color
        leftView.background_color = Color.green_color
        righView.background_color = .white
        lblTitle.textColor = .white
    }

    func bindData() {
        let option = SettingOptions.setting_options[0]
        if let generalSetting = WindowsManager.getVC(withIdentifier: option.identifier, ofType: option.type, storyboard: "CustomSetting") as? GeneralSettingViewC {
            generalSetting.view.frame = righView.bounds
            righView.addSubview(generalSetting.view)
            generalSetting.reloadView()
        }
    }
}

// MARK: - NSTableViewDataSource

extension CustomSettingController: NSTableViewDataSource, NSTableViewDelegate {
    func tableViewSetup() {
        tblMenu.delegate = self
        tblMenu.dataSource = self
        tblMenu.rowHeight = 34
        let row = tblMenu.rowView(atRow: 0, makeIfNecessary: false)
        row?.isSelected = true
        let selectedRowIndexes = IndexSet(integer: 0)
        tblMenu.reloadData()
        tblMenu.selectRowIndexes(selectedRowIndexes, byExtendingSelection: false)
    }

    func numberOfRows(in tableView: NSTableView) -> Int {
        return SettingOptions.setting_options.count
    }

    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        if let cellText = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "nameCell"), owner: nil) as? LabelCell {
            cellText.configSettingMenu(value: SettingOptions.setting_options[row].title)
            return cellText
        }
        return nil
    }

    func tableView(_ tableView: NSTableView, rowViewForRow row: Int) -> NSTableRowView? {
        let customView = RowView()
        return customView
    }

    func tableViewSelectionDidChange(_ notification: Notification) {
        if let tblV = notification.object as? NSTableView {
            let selectedRow = tblV.selectedRow
            if selectedRow != -1 {
                let option = SettingOptions.setting_options[selectedRow]
                righView.removeSubviews()
                if let vc = WindowsManager.getVC(withIdentifier: option.identifier, ofType: option.type, storyboard: "CustomSetting") as? BaseViewController {
                    vc.view.frame = righView.bounds
                    righView.addSubview(vc.view)
                    vc.reloadView()
                }
            }
        }
    }
}
