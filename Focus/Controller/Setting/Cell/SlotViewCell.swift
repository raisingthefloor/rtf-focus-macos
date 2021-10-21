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
        rightV.background_color = .clear
        print(session.time)
        print(session.sun)
        print(session.mon)
        print(session.tue)
        print(session.wed)
        print(session.thu)
        print(session.fri)

//        if session.sun.0 == true, session.mon.0 == true, session.tue.0 == true, session.wed.0 == true, session.thu.0 == true, session.fri.0 == true, session.sat.0 == true {
//            if session.session != 0 {
//                leftV.background_color = session.color.first
//                rightV.background_color = (session.sun.1 == 1) ? .clear : session.color.last
//            }
//        }

        if tableColumn?.identifier == NSUserInterfaceItemIdentifier(rawValue: "sunIdentifier") {
            if session.sun.0 == true {
                if session.session != 0 {
                    leftV.background_color = session.color.first
                    rightV.background_color = (session.sun.1 == 1) ? .clear : session.color.last
                }
            } else {
                leftV.background_color = .clear
                rightV.background_color = .clear
            }

        } else if tableColumn?.identifier == NSUserInterfaceItemIdentifier(rawValue: "monIdentifier") {
            if session.mon.0 == true {
                if session.session != 0 {
                    leftV.background_color = session.color.first
                    rightV.background_color = (session.mon.1 == 1) ? .clear : session.color.last
                }
            } else {
                leftV.background_color = .clear
                rightV.background_color = .clear
            }

        } else if tableColumn?.identifier == NSUserInterfaceItemIdentifier(rawValue: "tueIdentifier") {
            if session.tue.0 == true {
                if session.session != 0 {
                    leftV.background_color = session.color.first
                    rightV.background_color = (session.tue.1 == 1) ? .clear : session.color.last
                }
            } else {
                leftV.background_color = .clear
                rightV.background_color = .clear
            }

        } else if tableColumn?.identifier == NSUserInterfaceItemIdentifier(rawValue: "wedIdentifier") {
            if session.wed.0 == true {
                if session.session != 0 {
                    leftV.background_color = session.color.first
                    rightV.background_color = (session.wed.1 == 1) ? .clear : session.color.last
                }
            } else {
                leftV.background_color = .clear
                rightV.background_color = .clear
            }

        } else if tableColumn?.identifier == NSUserInterfaceItemIdentifier(rawValue: "thuIdentifier") {
            if session.thu.0 == true {
                if session.session != 0 {
                    leftV.background_color = session.color.first
                    rightV.background_color = (session.thu.1 == 1) ? .clear : session.color.last
                }
            } else {
                leftV.background_color = .clear
                rightV.background_color = .clear
            }

        } else if tableColumn?.identifier == NSUserInterfaceItemIdentifier(rawValue: "friIdentifier") {
            if session.fri.0 == true {
                if session.session != 0 {
                    leftV.background_color = session.color.first
                    rightV.background_color = (session.fri.1 == 1) ? .clear : session.color.last
                }
            } else {
                leftV.background_color = .clear
                rightV.background_color = .clear
            }

        } else if tableColumn?.identifier == NSUserInterfaceItemIdentifier(rawValue: "satIdentifier") {
            if session.sat.0 == true {
                if session.session != 0 {
                    leftV.background_color = session.color.first
                    rightV.background_color = (session.sat.1 == 1) ? .clear : session.color.last
                }
            } else {
                leftV.background_color = .clear
                rightV.background_color = .clear
            }
        }
    }
}
