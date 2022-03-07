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

class SlotViewCell: NSTableCellView {
    @IBOutlet var stackView: NSStackView!
    @IBOutlet var rightV: NSView!
    @IBOutlet var leftV: NSView!

    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
    }

    func configSlot(row: Int, session: ScheduleSession, tableColumn: NSTableColumn?, isTodaySchedule: Bool) {
        leftV.background_color = .clear
        leftV.border_color = .clear
        rightV.background_color = .clear
        rightV.border_color = .clear

        if let tblIdentifier = tableColumn?.identifier {
            bgColor = TableIdentifier(rawValue: tblIdentifier.rawValue)?.color

            if let scheduleDay = session.days.filter({ NSUserInterfaceItemIdentifier(rawValue: $0.day.identifier.rawValue) == tblIdentifier }).compactMap({ $0 }).first {
                setupSesionData(session: session, scheduleDay: scheduleDay)
            } else {
                if isTodaySchedule {
                    if let scheduleDay = session.days.first {
                        setupSesionData(session: session, scheduleDay: scheduleDay)
                    }
                }
            }
        }
    }

    func setupSesionData(session: ScheduleSession, scheduleDay: ScheduleDay) {
        let color: [NSColor] = scheduleDay.colors

        if scheduleDay.isActive == true && scheduleDay.noOfsession != 0 {
            if scheduleDay.noOfsession == 2 {
                print("scheduleDay.noOfsession ::::::::: \(scheduleDay.noOfsession)")
                print("color.count ::::::::: \(color.count)")
                print("color.count ::::::::: \(color)")
                let leftColor = color.first
                let left_color_type = scheduleDay.color_type.first

                leftV.background_color = ((left_color_type == .hollow) ? Color.list_bg_color : leftColor)
                leftV.border_color = ((left_color_type == .hollow) ? leftColor : .clear)
                leftV.border_width = 2.5
                let rightColor = color.last
                let right_color_type = scheduleDay.color_type.last

                rightV.background_color = ((right_color_type == .hollow) ? Color.list_bg_color : rightColor)
                rightV.border_color = ((right_color_type == .hollow) ? rightColor : .clear)
                rightV.border_width = 2.5

            } else {
                print("Else color.count ::::::::: \(color.count)")
                print("Else color.count ::::::::: \(color)")

                rightV.background_color = .clear
                rightV.border_color = .clear
                rightV.border_width = 2.5

                let leftColor = color.last
                let left_color_type = scheduleDay.color_type.last

                leftV.background_color = ((left_color_type == .hollow) ? Color.list_bg_color : leftColor)
                leftV.border_color = ((left_color_type == .hollow) ? leftColor : .clear)
                leftV.border_width = 2.5
            }
        } else {
            leftV.background_color = .clear
            leftV.border_color = .clear
            rightV.background_color = .clear
            rightV.border_color = .clear
        }
    }
}
