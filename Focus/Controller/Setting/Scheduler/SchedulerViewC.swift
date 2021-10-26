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
    var arrSession: [ScheduleSession] = []

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

        checkBoxFocusTime.title = NSLocalizedString("GS.provide_focus_time", comment: "Provide short")
        lblBrekInfo.stringValue = NSLocalizedString("GS.break_for", comment: "breaks for every")
        lblFocusInfo.stringValue = NSLocalizedString("GS.schedule_session", comment: "of scheduled Focus sessions")
    }

    func setUpViews() {
        lblTitle.font = NSFont.systemFont(ofSize: 18, weight: .semibold)
        lblTitle.textColor = .black

        checkBoxFocusTime.font = NSFont.systemFont(ofSize: 12, weight: .regular)

        lblBrekInfo.font = NSFont.systemFont(ofSize: 12, weight: .regular)
        lblBrekInfo.textColor = .black
//        lblFocusInfo.font = NSFont.systemFont(ofSize: 12, weight: .semibold) // Italic
        lblFocusInfo.textColor = .black
    }

    func bindData() {
        popFocusTime.menu = Focus.FocusTime.focustimes
        popBreakTime.menu = Focus.BreakTime.breaktimes

        popFocusTime.selectItem(at: 0)
        popBreakTime.selectItem(at: 1)

        popBreakTime.target = self
        popBreakTime.action = #selector(breakTimeSelection(_:))

        popFocusTime.target = self
        popFocusTime.action = #selector(foucsTimeSelection(_:))

        checkBoxFocusTime.target = self
        checkBoxFocusTime.action = #selector(checkBoxEventHandler(_:))

        urllink = Config.focus_schedule_link
        let g = NSClickGestureRecognizer(target: self, action: #selector(openBrowser))
        g.numberOfClicksRequired = 1
        lblInstruction.addGestureRecognizer(g) // Need to set range click

        setupData()
    }

    func setupData() {
        checkBoxFocusTime.state = (viewModel.objGCategory?.general_setting?.provide_short_break_schedule_session == true) ? .on : .off

        let breaktime = Int(viewModel.objGCategory?.general_setting?.break_time ?? 0).secondsToTime().timeInMinutes
        popBreakTime.selectItem(withTitle: "\(breaktime) min")

        let focustime = Int(viewModel.objGCategory?.general_setting?.for_every_time ?? 0).secondsToTime().timeInMinutes
        popFocusTime.selectItem(withTitle: "\(focustime) min")

        arrSession = viewModel.input.getSessionList(day: nil).0
    }
}

extension SchedulerViewC: NSTableViewDataSource, NSTableViewDelegate {
    func tableViewSetup() {
        tblSchedule.delegate = self
        tblSchedule.dataSource = self
        tblSchedule.rowHeight = 44
        tblSchedule.allowsColumnReordering = false
        tblSchedule.selectionHighlightStyle = .none

        tblSession.delegate = self
        tblSession.dataSource = self
        tblSession.allowsColumnReordering = false
        tblSession.rowHeight = 20
        tblSession.selectionHighlightStyle = .none

        let paragraph = NSMutableParagraphStyle()
        paragraph.alignment = .center

        tblSchedule.tableColumns.forEach { column in
            column.headerCell.attributedStringValue = NSAttributedString(string: column.title, attributes: [NSAttributedString.Key.font: NSFont.systemFont(ofSize: 10, weight: .semibold)])
        }

        tblSession.tableColumns.forEach { column in
            column.headerCell.attributedStringValue = NSAttributedString(string: column.title, attributes: [NSAttributedString.Key.font: NSFont.systemFont(ofSize: 10, weight: .semibold), NSAttributedString.Key.paragraphStyle: paragraph])
        }
    }

    func numberOfRows(in tableView: NSTableView) -> Int {
        if tableView.identifier == NSUserInterfaceItemIdentifier(rawValue: "scheduleIdentifier") {
            return viewModel.arrFocusSchedule.count
        } else {
            return arrSession.count
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
                            self.tblSchedule.reloadData(forRowIndexes: IndexSet(integer: row), columnIndexes: IndexSet(arrayLiteral: 0, 1, 2, 3, 4))
                        }
                    }
                    return cellCombo
                }
            } else if tableColumn?.identifier == NSUserInterfaceItemIdentifier(rawValue: "startAtId") {
                if let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "startId"), owner: nil) as? ComboBoxCell {
                    cell.configStartCell(obj: obj, arrTimes: viewModel.arrTimes)
                    cell.refreshTable = { isChange in
                        if isChange {
                            self.processReminderActiveInactive(objFSchedule: obj)
                        }
                    }

                    return cell
                }
            } else if tableColumn?.identifier == NSUserInterfaceItemIdentifier(rawValue: "endAtId") {
                if let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "endId"), owner: nil) as? ComboBoxCell {
                    cell.configEndCell(obj: obj, arrTimes: viewModel.arrTimes)
                    cell.refreshTable = { isChange in
                        if isChange {
                            self.processReminderActiveInactive(objFSchedule: obj)
                        }
                    }

                    return cell
                }
            } else if tableColumn?.identifier == NSUserInterfaceItemIdentifier(rawValue: "daysId") {
                if let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "weekdaysId"), owner: nil) as? WeekDaysCell {
                    cell.configDays(obj: obj)
                    cell.refreshTable = { isChange in
                        if isChange {
                            self.processReminderActiveInactive(objFSchedule: obj)
                            self.tblSchedule.reloadData(forRowIndexes: IndexSet(integer: row), columnIndexes: IndexSet(arrayLiteral: 0, 1, 2, 3, 4))
                        }
                    }
                    return cell
                }
            } else if tableColumn?.identifier == NSUserInterfaceItemIdentifier(rawValue: "actionId") {
                if let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "checkId"), owner: nil) as? CheckBoxCell {
                    cell.configScheduleActive(obj: obj, row: row, target: self, action: #selector(toggleAction(_:)), action_delete: #selector(deleteSchedule(_:)))
                    return cell
                }
            }
        } else {
            let obj = arrSession[row]
            if tableColumn?.identifier == NSUserInterfaceItemIdentifier(rawValue: "timeIdentifier") {
                if let cellTime = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "timeId"), owner: nil) as? LabelCell {
                    cellTime.setupTime(value: obj.time ?? "-")
                    return cellTime
                }
            } else {
                if let slotCell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "dayId"), owner: nil) as? SlotViewCell {
                    slotCell.configSlot(row: row, session: obj, tableColumn: tableColumn)
                    return slotCell
                }
            }
        }
        return nil
    }

    func tableView(_ tableView: NSTableView, rowViewForRow row: Int) -> NSTableRowView? {
        if tableView == tblSchedule {
            let customView = ScheduleRowView()
            return customView
        }
        return nil
    }
}

extension SchedulerViewC {
    // Active and Deactive the Schedule
    @objc func toggleAction(_ sender: NSButton) {
        let objFSchedule = viewModel.arrFocusSchedule[sender.tag]
        objFSchedule.is_active = !objFSchedule.is_active
        objFSchedule.color_type = objFSchedule.is_active ? Int64(ColorType.solid.rawValue) : Int64(ColorType.hollow.rawValue)

        processReminderActiveInactive(objFSchedule: objFSchedule)
        tblSchedule.reloadData(forRowIndexes: IndexSet(integer: sender.tag), columnIndexes: IndexSet(arrayLiteral: 0, 1, 2, 3, 4))
    }

    @objc func deleteSchedule(_ sender: NSButton) {
        let objFSchedule = viewModel.arrFocusSchedule[sender.tag]
        objFSchedule.is_active = false
        objFSchedule.block_list_id = nil
        objFSchedule.block_list_name = nil
        objFSchedule.days = nil
        objFSchedule.start_time = nil
        objFSchedule.end_time = nil
        DBManager.shared.saveContext()
        processReminderActiveInactive(objFSchedule: objFSchedule)
        tblSchedule.reloadData(forRowIndexes: IndexSet(integer: sender.tag), columnIndexes: IndexSet(arrayLiteral: 0, 1, 2, 3, 4))
    }

    @objc func foucsTimeSelection(_ sender: Any) {
        guard let popup = sender as? NSPopUpButton else { return }
        let index = popup.selectedTag()
        viewModel.objGCategory?.general_setting?.for_every_time = Focus.FocusTime(rawValue: index)!.valueInSeconds
        DBManager.shared.saveContext()
    }

    @objc func breakTimeSelection(_ sender: Any) {
        guard let popup = sender as? NSPopUpButton else { return }
        let index = popup.selectedTag()
        viewModel.objGCategory?.general_setting?.break_time = Focus.BreakTime(rawValue: index)!.valueInSeconds
        DBManager.shared.saveContext()
    }

    @objc func checkBoxEventHandler(_ sender: NSButton) {
        let isChecked = (sender.state == .on) ? true : false
        viewModel.objGCategory?.general_setting?.provide_short_break_schedule_session = isChecked
        DBManager.shared.saveContext()
    }

    func processReminderActiveInactive(objFSchedule: Focus_Schedule) {
//        if objFSchedule.is_active {
//            viewModel.input.setReminder(obj: objFSchedule)
//        } else {
//            viewModel.input.removeReminder(obj: objFSchedule)
//        }
        arrSession = viewModel.input.getSessionList(day: nil).0
        tblSession.reloadData()
    }
}
