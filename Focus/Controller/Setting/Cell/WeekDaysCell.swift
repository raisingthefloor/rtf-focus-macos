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

class WeekDaysCell: NSTableCellView {
    @IBOutlet var stackView: NSStackView!
    @IBOutlet var btnDay: NSButton!
    @IBOutlet var btnM: NSButton!
    @IBOutlet var btnT: NSButton!
    @IBOutlet var btnW: NSButton!
    @IBOutlet var btnTh: NSButton!
    @IBOutlet var btnF: NSButton!
    @IBOutlet var btnS: NSButton!

    var objFSchedule: Focus_Schedule?
    var refreshTable: ((Bool) -> Void)?

    override func prepareForReuse() {
        super.prepareForReuse()
    }

    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        setUpText()
        setUpViews()
    }
}

extension WeekDaysCell: BasicSetupType {
    func setUpText() {
    }

    func setUpViews() {
    }

    func configBlockCell() {
        btnDay.title = BlockType.application.title
        btnDay.title = BlockType.web.title
    }

    func bindTarget(target: AnyObject?) {
        btnDay.target = target
        btnDay.tag = BlockType.application.rawValue
    }

    func configDays(obj: Focus_Schedule?) {
        objFSchedule = obj
        let arrDays = objFSchedule?.days?.components(separatedBy: ",") ?? []
        var isSelected: Bool = false
        var i = 0
        let isActive = !(objFSchedule?.is_active ?? false)
        let isSetBlock = (obj?.block_list_id != nil)

        stackView.removeSubviews()
        for day in Calendar.current.veryShortWeekdaySymbols {
            let view = NSView(frame: NSRect(x: 0, y: -2, width: 14, height: 18))

            let btn = CustomButton(frame: NSRect(x: 0, y: 0, width: 18, height: 18))

            btn.tag = i
            btn.target = self
            btn.action = #selector(toggleDay(_:))
            if !arrDays.isEmpty {
                isSelected = arrDays.compactMap({ Int($0) == i }).filter({ $0 }).first ?? false
            }

            //  btn.state = isSelected ? .on : .off
            btn.font = NSFont.systemFont(ofSize: 10, weight: .regular)
            btn.title = day
            btn.alignment = .center
            btn.corner_radius = btn.frame.height / 2
            btn.buttonColor = (isActive && isSetBlock) ? .darkGray : (isSelected ? .blue : .white)
            btn.activeButtonColor = (isActive && isSetBlock) ? .darkGray : (isSelected ? .blue : .white)
            btn.textColor = (isActive && isSetBlock) ? .white : (isSelected ? .white : .black)
            btn.borderWidth = 0.5
            btn.borderColor = .black
            btn.isEnabled = (isActive && isSetBlock) ? false : true
            view.addSubview(btn)

            stackView.addArrangedSubview(view)
            i = i + 1
        }
    }

    @objc func toggleDay(_ sender: CustomButton) {
        var arrDays = objFSchedule?.days?.components(separatedBy: ",") ?? []
        let tag = sender.tag
        var isSelected = false
        if !arrDays.isEmpty {
            isSelected = arrDays.compactMap({ Int($0) == tag }).filter({ $0 }).first ?? false
        }

        if isSelected {
            if let index = arrDays.firstIndex(of: String(tag)) {
                arrDays.remove(at: index)
                objFSchedule?.days = arrDays.joined(separator: ",")
            }
        } else {
            arrDays.append(String(tag))
            objFSchedule?.days = arrDays.joined(separator: ",")
        }
        DBManager.shared.saveContext()
        configDays(obj: objFSchedule)
        refreshTable?(true)
    }
}
