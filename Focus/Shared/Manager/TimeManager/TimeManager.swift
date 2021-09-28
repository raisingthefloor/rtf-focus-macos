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
    var alert: Double = 0
    var danger: Double = 0

    init(counter: Int) {
        setCountdownValue(counter: counter)
    }

    func update(counter: Int) -> (window: Any, color: CGColor, minutes: Int, seconds: Int) {
        let minutes = counter / 60
        let seconds = counter % 60

        switch Double(counter) {
        case danger ... alert: break
        case 0 ... danger: break
        default:
            return defaultState(counter: counter)
        }

        return (window: "", color: Color.light_blue_color.cgColor, minutes: minutes, seconds: seconds)
    }
//TODO: Need to Set for Hours options
    func secondsToTime(seconds: Int) -> (timeInMinutes: Int, timeInSeconds: Int) {
        return (timeInMinutes: seconds / 60, timeInSeconds: seconds % 60)
    }

    func defaultState(counter: Int) -> (window: Any, color: CGColor, minutes: Int, seconds: Int) {
        let minutes = counter / 60
        let seconds = counter % 60
        return (window: "", color: Color.light_blue_color.cgColor, minutes: minutes, seconds: seconds)
    }

    func setCountdownValue(counter: Int) {
        self.counter = counter
        alert = Double(counter) * 0.33
        danger = Double(counter) * 0.17
    }
}
