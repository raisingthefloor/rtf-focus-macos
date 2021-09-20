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

    func configSlot(row: Int, session: ScheduleSession) {
        leftV.background_color = .clear
        rightV.background_color = .clear
        print(session.time)
        print(session.sun)
        print(session.mon)
        print(session.tue)
        print(session.wed)
        print(session.thu)
        print(session.fri)
        
        if session.sun == true, session.mon == true, session.tue == true, session.wed == true, session.thu == true, session.fri == true, session.sat == true {
            if session.session != 0 {
                leftV.background_color = Color.dark_grey_border
                rightV.background_color = (session.session == 1) ? .clear : Color.blue_color
            }
        }

        if session.sun == true {
            if session.session != 0 {
                leftV.background_color = Color.dark_grey_border
                rightV.background_color = (session.session == 1) ? .clear : Color.blue_color
            }
        } else {
            leftV.background_color = .clear
            rightV.background_color = .clear
        }

        if session.mon == true {
            if session.session != 0 {
                leftV.background_color = Color.dark_grey_border
                rightV.background_color = (session.session == 1) ? .clear : Color.blue_color
            }
        } else {
            leftV.background_color = .clear
            rightV.background_color = .clear
        }
        
        if session.tue == true {
            if session.session != 0 {
                leftV.background_color = Color.dark_grey_border
                rightV.background_color = (session.session == 1) ? .clear : Color.blue_color
            }
        } else {
            leftV.background_color = .clear
            rightV.background_color = .clear
        }
        
        if session.wed == true {
            if session.session != 0 {
                leftV.background_color = Color.dark_grey_border
                rightV.background_color = (session.session == 1) ? .clear : Color.blue_color
            }
        } else {
            leftV.background_color = .clear
            rightV.background_color = .clear
        }
        
        if session.thu == true {
            if session.session != 0 {
                leftV.background_color = Color.dark_grey_border
                rightV.background_color = (session.session == 1) ? .clear : Color.blue_color
            }
        } else {
            leftV.background_color = .clear
            rightV.background_color = .clear
        }
        
        if session.fri == true {
            if session.session != 0 {
                leftV.background_color = Color.dark_grey_border
                rightV.background_color = (session.session == 1) ? .clear : Color.blue_color
            }
        } else {
            leftV.background_color = .clear
            rightV.background_color = .clear
        }
        
        if session.sat == true {
            if session.session != 0 {
                leftV.background_color = Color.dark_grey_border
                rightV.background_color = (session.session == 1) ? .clear : Color.blue_color
            }
        } else {
            leftV.background_color = .clear
            rightV.background_color = .clear
        }
    }
}
