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

class TimeCBDataSource: NSObject, NSComboBoxCellDataSource, NSComboBoxDataSource, NSComboBoxDelegate {
    var arrTimes: [String] = ["12 AM", "1 AM", "2 AM", "3 AM", "4 AM", "5 AM", "6 AM", "7 AM", "8 AM",
                              "9 AM", "10 AM", "11 AM", "12 PM", "1 PM", "2 PM", "3 PM", "4 PM", "5 PM",
                              "6 PM", "7 PM", "8 PM", "9 PM", "10 PM", "11 PM"]
    var objFSchedule: Focus_Schedule?

    func comboBox(_ comboBox: NSComboBox, completedString string: String) -> String? {
        for time in arrTimes {
            // substring must have less characters then stings to search
            if string.count < arrTimes.count {
                // only use first part of the strings in the list with length of the search string
                let statePartialStr = time.lowercased()[time.lowercased().startIndex ..< time.lowercased().index(time.lowercased().startIndex, offsetBy: string.count)]
                if statePartialStr.range(of: string.lowercased()) != nil {
                    updateTimeValue(comboBox, time: time)
                    return time
                }
            }
        }
        return ""
    }

    func numberOfItems(in comboBox: NSComboBox) -> Int {
        return arrTimes.count
    }

    func comboBox(_ comboBox: NSComboBox, objectValueForItemAt index: Int) -> Any? {
        return arrTimes[index]
    }

    func comboBoxWillDismiss(_ notification: Notification) {
        let comboBox: NSComboBox = (notification.object as? NSComboBox)!
    }

    func updateTimeValue(_ comboBox: NSComboBox, time: String?) {
        if comboBox.tag == 1 {
            objFSchedule?.start_time = time
        } else {
            objFSchedule?.end_time = time
        }
        DBManager.shared.saveContext()
    }

//    func comboBox(_ comboBox: NSComboBox, indexOfItemWithStringValue string: String) -> Int {
//        if let index = arrTimes.firstIndex(of: string) {
//            return index
//        }
//
//        return 0
//    }
}
