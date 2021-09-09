//
//  LeftMenuView.swift
//  Focus
//
//  Created by Bhavi on 08/09/21.
//  Copyright © 2021 Raising the Floor. All rights reserved.
//

import Cocoa

class LeftMenuView: NSViewController {
    @IBOutlet var topView: NSView!
    @IBOutlet var tblMenu: NSTableView!
    @IBOutlet var lblTitle: NSTextField!

    override func viewDidLoad() {
        super.viewDidLoad()
        setUpText()
        setUpViews()
        bindData()
        tableViewSetup()
    }
}

extension LeftMenuView: BasicSetupType {
    func setUpText() {
        lblTitle.stringValue = NSLocalizedString("Home.customize_focus", comment: "Customize Focus")
    }

    func setUpViews() {
        topView.background_color = Color.green_color
        lblTitle.textColor = .white
    }

    func bindData() {
    }
}

// MARK: - NSTableViewDataSource

extension LeftMenuView: NSTableViewDataSource, NSTableViewDelegate {
    func tableViewSetup() {
        tblMenu.delegate = self
        tblMenu.dataSource = self
        tblMenu.rowHeight = 60
        let row = tblMenu.rowView(atRow: 0, makeIfNecessary: false)
        row?.isSelected = true
    }

    func numberOfRows(in tableView: NSTableView) -> Int {
        return SettingOptions.setting_options.count
    }

//    func tableView(_ tableView: NSTableView, objectValueFor tableColumn: NSTableColumn?, row: Int) -> Any? {
//        return SettingOptions.setting_options[row].title
//    }

    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        if let cellText = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "nameCell"), owner: nil) as? NSTableCellView {
            cellText.textField?.stringValue = SettingOptions.setting_options[row].title
            cellText.textField?.alignment = .center
            cellText.textField?.textColor = .white
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
            let option = SettingOptions.setting_options[selectedRow]
            if let splitVC = WindowsManager.getVC(withIdentifier: "sidSplitviewController", ofType: NSSplitViewController.self, storyboard: "CustomSetting") {
                let identifier = option.identifier
                var items = splitVC.splitViewItems
                if let vc = WindowsManager.getVC(withIdentifier: identifier, ofType: GeneralSettingViewC.self, storyboard: "CustomSetting") {
                    items[1] = NSSplitViewItem(viewController: vc)
                    splitVC.splitViewItems = items
                }
            }
        }
    }
}
