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

class SchedulerViewC: BaseViewController {
    @IBOutlet var tblSchedule: NSTableView!

    override func setTitle() -> String { return SettingOptions.schedule_setting.title }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        setUpText()
        setUpViews()
        bindData()
        tableViewSetup()
    }
}

extension SchedulerViewC: BasicSetupType {
    func setUpText() {
    }

    func setUpViews() {
    }

    func bindData() {
    }
}

extension SchedulerViewC: NSTableViewDataSource, NSTableViewDelegate {
    func tableViewSetup() {
        tblSchedule.delegate = self
        tblSchedule.dataSource = self
        tblSchedule.usesAutomaticRowHeights = true
    }

    func numberOfRows(in tableView: NSTableView) -> Int {
        return 10
    }

    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        return setupCell(tableView: tableView, tableColumn: tableColumn, row: row)
    }

    func setupCell(tableView: NSTableView, tableColumn: NSTableColumn?, row: Int) -> NSView? {
        if tableColumn?.identifier == NSUserInterfaceItemIdentifier(rawValue: "actionIdentifier") {
            if let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "buttonId"), owner: nil) as? ButtonCell {
                cell.configScheduleActionCell(isPause: (row % 2) != 0)
                return cell
            }
        } else if tableColumn?.identifier == NSUserInterfaceItemIdentifier(rawValue: "statusIdentifier") {
            if let cellStatus = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "statusId"), owner: nil) as? NSTableCellView {
                cellStatus.textField?.backgroundColor = NSColor.random
                return cellStatus
            }
        } else if tableColumn?.identifier == NSUserInterfaceItemIdentifier(rawValue: "blockIdentifier") {
            if let cellCombo = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "comboId"), owner: nil) as? ComboBoxCell {
                return cellCombo
            }
        } else {
            if let cellText = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "cellId"), owner: nil) as? NSTableCellView {
                cellText.textField?.stringValue = "-"
                return cellText
            }
        }
        return nil
    }
}

private extension NSColor {
    class var random: NSColor { return colors[Int(arc4random_uniform(UInt32(colors.count)))] }
}
