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

class TodayScheduleViewC: BaseViewController {
    @IBOutlet var lblTitle: NSTextField!
    @IBOutlet var lblSubTitle: NSTextField!

    @IBOutlet var lblChange: NSTextField!

    @IBOutlet var scheduleView: NSView!
    @IBOutlet var tblSchedule: NSTableView!

    @IBOutlet var statusView: NSView!
    @IBOutlet var tblSession: NSTableView!

    let viewModel: ScheduleViewModelType = ScheduleViewModel()
    var arrSession: [ScheduleSession] = []
    var arrFocusS: [Focus_Schedule] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        setUpText()
        setUpViews()
        bindData()
        tableViewSetup()
    }
}

extension TodayScheduleViewC: BasicSetupType {
    func setUpText() {
        lblTitle.stringValue = NSLocalizedString("TS.title", comment: "Today’s Schedule")
        lblSubTitle.stringValue = NSLocalizedString("TS.subTitle", comment: "These are the focus sessions you scheduled for today. You can edit today’s schedule, but you can only edit or disable a scheduled focus session before it starts.)")
        lblChange.stringValue = NSLocalizedString("TS.change", comment: "Changes made on this page are one-time and will only affect your schedule TODAY.")
    }

    func setUpViews() {
        statusView.background_color = Color.light_green_color
    }

    func bindData() {
        let result = viewModel.input.getSessionList(day: Date().currentDateComponent().weekday)
        arrSession = result.0
        arrFocusS = result.1
    }
}

extension TodayScheduleViewC: NSTableViewDataSource, NSTableViewDelegate {
    func tableViewSetup() {
        tblSchedule.delegate = self
        tblSchedule.dataSource = self
        tblSchedule.usesAutomaticRowHeights = true
        tblSchedule.selectionHighlightStyle = .none

        tblSession.delegate = self
        tblSession.dataSource = self
        tblSession.allowsColumnReordering = false
        tblSession.rowHeight = 15
        tblSession.selectionHighlightStyle = .none

        tblSchedule.tableColumns.forEach { column in
            column.headerCell.attributedStringValue = NSAttributedString(string: column.title.uppercased(), attributes: [NSAttributedString.Key.font: NSFont.systemFont(ofSize: 9, weight: .semibold)])
        }

        tblSession.tableColumns.forEach { column in
            if column.identifier != NSUserInterfaceItemIdentifier(rawValue: "timeIdentifier") {
                let paragraph = NSMutableParagraphStyle()
                paragraph.alignment = .center

                column.headerCell.attributedStringValue = NSAttributedString(string: Date.getDayName().uppercased()
                                                                             , attributes: [NSAttributedString.Key.font: NSFont.systemFont(ofSize: 10, weight: .semibold), NSAttributedString.Key.paragraphStyle: paragraph])
            }
        }
    }

    func numberOfRows(in tableView: NSTableView) -> Int {
        if tableView.identifier == NSUserInterfaceItemIdentifier(rawValue: "scheduleIdentifier") {
            return arrFocusS.count
        } else {
            return arrSession.count
        }
    }

    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        return setupCell(tableView: tableView, tableColumn: tableColumn, row: row)
    }

    func setupCell(tableView: NSTableView, tableColumn: NSTableColumn?, row: Int) -> NSView? {
        if tableView.identifier == NSUserInterfaceItemIdentifier(rawValue: "scheduleIdentifier") {
            let obj = arrFocusS[row]
            if tableColumn?.identifier == NSUserInterfaceItemIdentifier(rawValue: "blockIdentifier") {
                if let cellCombo = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "nameId"), owner: nil) as? LabelCell {
                    cellCombo.setupColor(objFS: obj)
                    return cellCombo
                }
            } else if tableColumn?.identifier == NSUserInterfaceItemIdentifier(rawValue: "startAtId") {
                if let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "startId"), owner: nil) as? ComboBoxCell {
                    cell.configStartCell(obj: obj, arrTimes: viewModel.arrTimes)
                    cell.refreshTable = { isChange in
                        if isChange {
                            self.reloadSession()
                        }
                    }

                    return cell
                }
            } else if tableColumn?.identifier == NSUserInterfaceItemIdentifier(rawValue: "endAtId") {
                if let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "endId"), owner: nil) as? ComboBoxCell {
                    cell.configEndCell(obj: obj, arrTimes: viewModel.arrTimes)
                    cell.refreshTable = { isChange in
                        if isChange {
                            self.reloadSession()
                        }
                    }

                    return cell
                }
            } else {
                if let cellCheck = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "checkId"), owner: nil) as? CheckBoxCell {
                    cellCheck.configScheduleActive(obj: obj, row: row, target: self, action: #selector(toggleAction(_:)), action_delete: nil)
                    return cellCheck
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


    @objc func toggleAction(_ sender: NSButton) {
        let objFSchedule = arrFocusS[sender.tag]
        objFSchedule.is_active = !objFSchedule.is_active
        objFSchedule.color_type = objFSchedule.is_active ? Int64(ColorType.solid.rawValue) : Int64(ColorType.hollow.rawValue)
        DBManager.shared.saveContext()
        tblSchedule.reloadData(forRowIndexes: IndexSet(integer: sender.tag), columnIndexes: IndexSet(arrayLiteral: 0, 1, 2, 3))
    }

    func reloadSession() {
        let result = viewModel.input.getSessionList(day:Date().currentDateComponent().weekday)
        arrSession = result.0
        tblSession.reloadData()
    }
}
