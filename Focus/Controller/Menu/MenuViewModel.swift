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

protocol MenuViewModelIntput {
    func updateFocusStop(time: Focus.StopTime, callback: @escaping ((Any?, Error?) -> Void))
    func updateFocusOption(option: Focus.Options, state: NSControl.StateValue, callback: @escaping ((Any?, Error?) -> Void))
    var focusObj: Focuses? { get set } // TODO: Need to update as per dynamic
}

protocol MenuViewModelOutput {
}

protocol MenuViewModelType {
    var input: MenuViewModelIntput { get }
    var output: MenuViewModelOutput { get }
    var model: DataModelType { get set }
    var viewCntrl: ViewCntrl { get set }
}

class MenuViewModel: MenuViewModelIntput, MenuViewModelOutput, MenuViewModelType {
    var focusObj: Focuses? = { // TODO: Need to update as per dynamic
        DBManager.shared.getFoucsObject()
    }()

    var input: MenuViewModelIntput { return self }
    var output: MenuViewModelOutput { return self }
    var model: DataModelType = DataModel()
    var viewCntrl: ViewCntrl = .main_menu
}

extension MenuViewModel {
    func updateFocusStop(time: Focus.StopTime, callback: @escaping ((Any?, Error?) -> Void)) {
        // update focus time value
        focusObj?.focus_untill_stop = false

        switch time {
        case .half_past:
            print("half_past")
            focusObj?.is_focusing = true // Need to check what to do.

        case .one_hr:
            print("one_hr")
            focusObj?.is_focusing = true

        case .two_hr:
            print("two_hr")
            focusObj?.is_focusing = true

        case .untill_press_stop:
            print("untill_press_stop")
            focusObj?.is_focusing = true
            if !(focusObj?.is_provided_short_break ?? false) {
                focusObj?.stop_focus_after_time = Focus.FocusTime.long_focus_stop_lenght
            }
            focusObj?.focus_untill_stop = true

        case .stop_focus:
            focusObj?.is_focusing = false
            print("stop_focus")
        }
        updateParallelFocusSession(time: time)
        callback(true, nil)
    }

    func updateFocusOption(option: Focus.Options, state: NSControl.StateValue, callback: @escaping ((Any?, Error?) -> Void)) {
        // update focus options value
        switch option {
        case .dnd:
            print("dnd ::: \(state)")
            focusObj?.is_dnd_mode = (state == .on) ? true : false
        case .focus_break:
            print("focus_break ::: \(state)")
            focusObj?.is_provided_short_break = (state == .on) ? true : false
        case .block_program_website:
            print("block_program_website ::: \(state)")
            focusObj?.is_block_programe_select = (state == .on) ? true : false
            let arrBlock = model.input.getBlockList(cntrl: .main_menu).blists
            focusObj?.block_list_id = (state == .on) ? (!arrBlock.isEmpty ? arrBlock[0].id : nil) : nil
            focusObj?.is_dnd_mode = (!arrBlock.isEmpty) ? arrBlock[0].is_dnd_category_on : (focusObj?.is_dnd_mode ?? false) // This one used for cause If any blocklist has selected notification Category then it set here
        default:
            print("default ::: \(state)")
        }
        DBManager.shared.saveContext()
        callback(state, nil)
    }

    func updateParallelFocusSession(time: Focus.StopTime) {
        focusObj?.created_date = Date()
//        focusObj?.is_parallels_session = (viewCntrl != .main_menu) ? true : false
        let timeVal = (viewCntrl != .main_menu) ? (focusObj?.focus_length_time ?? 0) + time.value : time.value

        focusObj?.focus_length_time = timeVal
        focusObj?.remaining_time = (viewCntrl != .main_menu) ? ((timeVal + (focusObj?.remaining_time ?? 0)) - (focusObj?.used_focus_time ?? 0)) : timeVal
        focusObj?.session_start_time = Date()

        let timecomp = Int(timeVal).secondsToTime()
        focusObj?.session_end_time = Date().adding(hour: timecomp.timeInHours, min: timecomp.timeInMinutes, sec: timecomp.timeInSeconds)

        if focusObj?.extended_value == nil {
            let objExVal = Focuses_Extended_Value(context: DBManager.shared.managedContext)
            focusObj?.extended_value = objExVal
        }
        DBManager.shared.saveContext()
    }
}
