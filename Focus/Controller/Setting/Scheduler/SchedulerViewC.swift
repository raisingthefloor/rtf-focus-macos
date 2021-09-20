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

        
        let attributedText = NSMutableAttributedString.getAttributedString(fromString: NSLocalizedString("SS.instruction", comment: "Instructions"))
        attributedText.underLine(subString: NSLocalizedString("SS.instruction", comment: "Instructions")) // Need to add seprate string
        attributedText.apply(color: Color.blue_color, subString: NSLocalizedString("SS.instruction", comment: "Instructions"))
        lblInstruction.attributedStringValue = attributedText
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
        tblSchedule.allowsColumnReordering = false

        tblSession.delegate = self
        tblSession.dataSource = self
        tblSession.allowsColumnReordering = false
    }

    func numberOfRows(in tableView: NSTableView) -> Int {
        if tableView.identifier == NSUserInterfaceItemIdentifier(rawValue: "scheduleIdentifier") {
            return 10
        } else {
            return viewModel.input.getSessionList().count
        }
    }

    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        return setupCell(tableView: tableView, tableColumn: tableColumn, row: row)
    }

    func setupCell(tableView: NSTableView, tableColumn: NSTableColumn?, row: Int) -> NSView? {
        if tableView.identifier == NSUserInterfaceItemIdentifier(rawValue: "scheduleIdentifier") {
            if tableColumn?.identifier == NSUserInterfaceItemIdentifier(rawValue: "statusIdentifier") {
                if let cellStatus = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "statusId"), owner: nil) as? NSTableCellView {
                    cellStatus.textField?.backgroundColor = NSColor.random
                    return cellStatus
                }
            } else if tableColumn?.identifier == NSUserInterfaceItemIdentifier(rawValue: "blockIdentifier") {
                if let cellCombo = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "comboId"), owner: nil) as? ComboBoxCell {
                    return cellCombo
                }
            } else if tableColumn?.identifier == NSUserInterfaceItemIdentifier(rawValue: "startAtId") {
                if let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "startId"), owner: nil) as? DateTimeCell {
                    //   cell.configScheduleActionCell(isPause: (row % 2) != 0)
                    return cell
                }
            } else if tableColumn?.identifier == NSUserInterfaceItemIdentifier(rawValue: "endAtId") {
                if let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "endId"), owner: nil) as? DateTimeCell {
                    //  cell.configScheduleActionCell(isPause: (row % 2) != 0)
                    return cell
                }
            } else if tableColumn?.identifier == NSUserInterfaceItemIdentifier(rawValue: "daysId") {
                if let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "weekdaysId"), owner: nil) as? WeekDaysCell {
                    cell.configDays()
                    return cell
                }
            } else if tableColumn?.identifier == NSUserInterfaceItemIdentifier(rawValue: "actionId") {
                if let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "checkId"), owner: nil) as? ButtonCell {
                    //  cell.configScheduleActionCell(isPause: (row % 2) != 0)
                    return cell
                }
            } else {
                if let cellText = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "deleteId"), owner: nil) as? ButtonCell {
                    //  cellText.textField?.stringValue = "-"
                    return cellText
                }
            }
        } else {
            let arrSession = viewModel.input.getSessionList()
            let obj = arrSession[row]
            
            if tableColumn?.identifier == NSUserInterfaceItemIdentifier(rawValue: "timeIdentifier") {
                if let cellTime = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "timeId"), owner: nil) as? LabelCell {
                    cellTime.lblTitle.stringValue = arrSession[row].time ?? "-"
                    return cellTime
                }
//            } else if tableColumn?.identifier == NSUserInterfaceItemIdentifier(rawValue: "sunIdentifier") {
//                if let slotCell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "dayId"), owner: nil) as? SlotViewCell {
//                    slotCell.configSlot(row: row,session: obj)
//                    return slotCell
//                }
//            } else if tableColumn?.identifier == NSUserInterfaceItemIdentifier(rawValue: "monIdentifier") {
//                if let slotCell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "dayId"), owner: nil) as? SlotViewCell {
//                    slotCell.configSlot(row: row,session: obj)
//                    return slotCell
//                }
//            } else if tableColumn?.identifier == NSUserInterfaceItemIdentifier(rawValue: "tueIdentifier") {
//                if let slotCell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "dayId"), owner: nil) as? SlotViewCell {
//                    slotCell.configSlot(row: row,session: obj)
//                    return slotCell
//                }
//            } else if tableColumn?.identifier == NSUserInterfaceItemIdentifier(rawValue: "thuIdentifier") {
//                if let slotCell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "dayId"), owner: nil) as? SlotViewCell {
//                    slotCell.configSlot(row: row,session: obj)
//                    return slotCell
//                }
//            } else if tableColumn?.identifier == NSUserInterfaceItemIdentifier(rawValue: "friIdentifier") {
//                if let slotCell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "dayId"), owner: nil) as? SlotViewCell {
//                    slotCell.configSlot(row: row,session: obj)
//                    return slotCell
//                }
            } else {
                if let slotCell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "dayId"), owner: nil) as? SlotViewCell {
                    slotCell.configSlot(row: row,session: obj)
                    return slotCell
                }
            }
        }
        return nil
    }

    func tableView(_ tableView: NSTableView, rowViewForRow row: Int) -> NSTableRowView? {
        if tableView.identifier == NSUserInterfaceItemIdentifier(rawValue: "scheduleIdentifier") {
            let view = ClearRowView()
            return view
        }
        return nil
    }
}
