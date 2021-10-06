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
import Foundation

class Countdowner {
    var counter: Int = 0
    var stop_focus_after_time: Double = 0
    var obj: Focuses!

    init(counter: Int, obj: Focuses) {
        setSessionValue(counter: counter, obj: obj)
    }

    func update(counter: Int, usedValue: Int) -> (popup: FocusDialogue, hours: Int, minutes: Int, seconds: Int) {
        let hours = (counter / 60) / 60
        let minutes = counter / 60
        let seconds = counter % 60

        switch Double(usedValue) {
        case obj.stop_focus_after_time:
            let popup: FocusDialogue = obj.focus_untill_stop ? .long_break_alert : .short_break_alert
            return (popup: popup, hours: hours, minutes: minutes, seconds: seconds)
        default:
            return defaultState(counter: counter)
        }

//        return (popup: .none, hours: hours, minutes: minutes, seconds: seconds)
    }

    // TODO: Need to Set for Hours options

    func defaultState(counter: Int) -> (popup: FocusDialogue, hours: Int, minutes: Int, seconds: Int) {
        let hours = (counter / 60) / 60
        let minutes = counter / 60
        let seconds = counter % 60
        return (popup: .none, hours: hours, minutes: minutes, seconds: seconds)
    }

    func setSessionValue(counter: Int, obj: Focuses) { // Need to set the break time and interval time to display controller
        self.counter = counter
        self.obj = obj
        stop_focus_after_time = obj.stop_focus_after_time
    }
}
