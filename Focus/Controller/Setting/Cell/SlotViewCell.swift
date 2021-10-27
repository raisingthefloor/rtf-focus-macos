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

    func configSlot(row: Int, session: ScheduleSession, tableColumn: NSTableColumn?) {
        leftV.background_color = .clear
        leftV.border_color = .clear
        rightV.background_color = .clear
        rightV.border_color = .clear

//        if session.sun.0 == true, session.mon.0 == true, session.tue.0 == true, session.wed.0 == true, session.thu.0 == true, session.fri.0 == true, session.sat.0 == true {
//            if session.session != 0 {
//                leftV.background_color = session.color.first
//                rightV.background_color = (session.sun.1 == 1) ? .clear : session.color.last
//            }
//        }

        if tableColumn?.identifier == NSUserInterfaceItemIdentifier(rawValue: "sunIdentifier") {
            setupSesionData(session: session, daySelected: session.sun.0, no_session: session.sun.1, color_type: session.color_type, color: session.sun.colors)
        } else if tableColumn?.identifier == NSUserInterfaceItemIdentifier(rawValue: "monIdentifier") {
            setupSesionData(session: session, daySelected: session.mon.0, no_session: session.mon.1, color_type: session.color_type, color: session.mon.colors)
        } else if tableColumn?.identifier == NSUserInterfaceItemIdentifier(rawValue: "tueIdentifier") {
            setupSesionData(session: session, daySelected: session.tue.0, no_session: session.tue.1, color_type: session.color_type, color: session.tue.colors)
        } else if tableColumn?.identifier == NSUserInterfaceItemIdentifier(rawValue: "wedIdentifier") {
            setupSesionData(session: session, daySelected: session.wed.0, no_session: session.wed.1, color_type: session.color_type, color: session.wed.colors)
        } else if tableColumn?.identifier == NSUserInterfaceItemIdentifier(rawValue: "thuIdentifier") {
            setupSesionData(session: session, daySelected: session.thu.0, no_session: session.thu.1, color_type: session.color_type, color: session.thu.colors)
        } else if tableColumn?.identifier == NSUserInterfaceItemIdentifier(rawValue: "friIdentifier") {
            setupSesionData(session: session, daySelected: session.fri.0, no_session: session.fri.1, color_type: session.color_type, color: session.fri.colors)
        } else if tableColumn?.identifier == NSUserInterfaceItemIdentifier(rawValue: "satIdentifier") {
            setupSesionData(session: session, daySelected: session.sat.0, no_session: session.sat.1, color_type: session.color_type, color: session.sat.colors)
        }
    }

    func setupSesionData(session: ScheduleSession, daySelected: Bool, no_session: Int, color_type: [ColorType], color: [NSColor]) {
        if daySelected == true {
            if no_session != 0 {
                leftV.background_color = ((color_type.first == .hollow) ? Color.list_bg_color : color.first)
                leftV.border_color = ((color_type.last == .hollow) ? color.first : .clear)
                leftV.border_width = 2.5

                rightV.background_color = (no_session == 1) ? .clear : ((color_type.last == .hollow) ? Color.list_bg_color : color.last)
                rightV.border_color = (no_session == 1) ? .clear : ((color_type.last == .hollow) ? color.last : .clear)
                rightV.border_width = 2.5
            }
        } else {
            leftV.background_color = .clear
            leftV.border_color = .clear
            rightV.background_color = .clear
            rightV.border_color = .clear
        }
    }
}
