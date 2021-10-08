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
    @IBOutlet var lblTitle: NSTextField!
    @IBOutlet var lblSubTitle: NSTextField!

    @IBOutlet var lblInstruction: NSTextField!

    @IBOutlet var tblSchedule: NSTableView!

    @IBOutlet var checkBoxFocusTime: NSButton!
    @IBOutlet var popBreakTime: NSPopUpButton!
    @IBOutlet var lblBrekInfo: NSTextField!
    @IBOutlet var popFocusTime: NSPopUpButton!
    @IBOutlet var lblFocusInfo: NSTextField!

    @IBOutlet var tblSession: NSTableView!
    let viewModel: ScheduleViewModelType = ScheduleViewModel()

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
        lblTitle.stringValue = NSLocalizedString("SS.title", comment: "Focus Schedule")
        lblSubTitle.stringValue = NSLocalizedString("SS.subTitle", comment: "Create a schedule to start focus sessions on days and times of your choosing.  (When you schedule focus sessions at the top of this page, they will appear on the calendar at the bottom.)")

        let instruction = NSLocalizedString("SS.instruction", comment: "Instructions")
        let attributedText = NSMutableAttributedString.getAttributedString(fromString: instruction)
        attributedText.underLine(subString: instruction) // Need to add seprate string
        attributedText.apply(color: Color.blue_color, subString: instruction)
        attributedText.apply(font: NSFont.systemFont(ofSize: 12, weight: .regular), subString: instruction)
        lblInstruction.attributedStringValue = attributedText
    }

    func setUpViews() {
        lblTitle.font = NSFont.systemFont(ofSize: 18, weight: .semibold)
        lblTitle.textColor = .black
    }

    func bindData() {
    }
}

extension SchedulerViewC: NSTableViewDataSource, NSTableViewDelegate {
    func tableViewSetup() {
        tblSchedule.delegate = self
        tblSchedule.dataSource = self
        tblSchedule.rowHeight = 44
        tblSchedule.allowsColumnReordering = false

        tblSession.delegate = self
        tblSession.dataSource = self
        tblSession.allowsColumnReordering = false
        tblSession.rowHeight = 20

        tblSchedule.tableColumns.forEach { column in
            column.headerCell.attributedStringValue = NSAttributedString(string: column.title, attributes: [NSAttributedString.Key.font: NSFont.systemFont(ofSize: 11)])
        }
    }

    func numberOfRows(in tableView: NSTableView) -> Int {
        if tableView.identifier == NSUserInterfaceItemIdentifier(rawValue: "scheduleIdentifier") {
            return viewModel.arrFocusSchedule.count
        } else {
            return viewModel.input.getSessionList().count
        }
    }

    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        return setupCell(tableView: tableView, tableColumn: tableColumn, row: row)
    }

    func setupCell(tableView: NSTableView, tableColumn: NSTableColumn?, row: Int) -> NSView? {
        if tableView.identifier == NSUserInterfaceItemIdentifier(rawValue: "scheduleIdentifier") {
            let obj = viewModel.arrFocusSchedule[row]
            if tableColumn?.identifier == NSUserInterfaceItemIdentifier(rawValue: "blockIdentifier") {
                if let cellCombo = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "comboId"), owner: nil) as? ComboBoxCell {
                    cellCombo.configScheduleCell(obj: obj)
                    cellCombo.refreshTable = { isChange in
                        if isChange {
                            self.tblSchedule.reloadData()
                        }
                    }
                    return cellCombo
                }
            } else if tableColumn?.identifier == NSUserInterfaceItemIdentifier(rawValue: "startAtId") {
                if let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "startId"), owner: nil) as? ComboBoxCell {
                    cell.configStartCell(obj: obj, arrTimes: viewModel.arrTimes)
                    return cell
                }
            } else if tableColumn?.identifier == NSUserInterfaceItemIdentifier(rawValue: "endAtId") {
                if let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "endId"), owner: nil) as? ComboBoxCell {
                    cell.configEndCell(obj: obj, arrTimes: viewModel.arrTimes)
                    return cell
                }
            } else if tableColumn?.identifier == NSUserInterfaceItemIdentifier(rawValue: "daysId") {
                if let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "weekdaysId"), owner: nil) as? WeekDaysCell {
                    cell.configDays(obj: obj)
                    cell.refreshTable = { isChange in
                        if isChange {
                            self.tblSchedule.reloadData()
                        }
                    }
                    return cell
                }
            } else if tableColumn?.identifier == NSUserInterfaceItemIdentifier(rawValue: "actionId") {
                if let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "checkId"), owner: nil) as? ButtonCell {
                    cell.configScheduleActive(obj: obj, row: row, target: self, action: #selector(toggleAction(_:)), action_delete: #selector(deleteSchedule(_:)))
                    return cell
                }
            }
        } else {
            let arrSession = viewModel.input.getSessionList()
            let obj = arrSession[row]

            if tableColumn?.identifier == NSUserInterfaceItemIdentifier(rawValue: "timeIdentifier") {
                if let cellTime = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "timeId"), owner: nil) as? LabelCell {
                    cellTime.setupTime(value: arrSession[row].time ?? "-")
                    return cellTime
                }
            } else {
                if let slotCell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "dayId"), owner: nil) as? SlotViewCell {
                    slotCell.configSlot(row: row, session: obj)
                    return slotCell
                }
            }
        }
        return nil
    }

    func tableView(_ tableView: NSTableView, rowViewForRow row: Int) -> NSTableRowView? {
        if tableView.identifier == NSUserInterfaceItemIdentifier(rawValue: "scheduleIdentifier") {
            let view = LightRowView()
            return view
        }
        return nil
    }
}

extension SchedulerViewC {
    // Active and Deactive the Schedule
    @objc func toggleAction(_ sender: NSButton) {
        let objFSchedule = viewModel.arrFocusSchedule[sender.tag]
        objFSchedule.is_active = !objFSchedule.is_active
        DBManager.shared.saveContext()
        tblSchedule.reloadData()
    }

    @objc func deleteSchedule(_ sender: NSButton) {
        let objFSchedule = viewModel.arrFocusSchedule[sender.tag]
        objFSchedule.is_active = false
        objFSchedule.session_color = nil
        objFSchedule.block_list_id = nil
        objFSchedule.block_list_name = nil
        objFSchedule.days = nil
        objFSchedule.start_time = nil
        objFSchedule.end_time = nil
        DBManager.shared.saveContext()
        tblSchedule.reloadData()
    }
}
