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
    var focusObj: Current_Focus? { get set }
}

protocol MenuViewModelOutput {
}

protocol MenuViewModelType {
    var input: MenuViewModelIntput { get }
    var output: MenuViewModelOutput { get }
    var model: DataModelType { get set }
    var viewCntrl: ViewCntrl { get set }
    var focusDict: [String: Any?] { get set }
}

class MenuViewModel: MenuViewModelIntput, MenuViewModelOutput, MenuViewModelType {
    var focusObj: Current_Focus? = {
        DBManager.shared.getFoucsObject()
    }()

    var input: MenuViewModelIntput { return self }
    var output: MenuViewModelOutput { return self }
    var model: DataModelType = DataModel()
    var viewCntrl: ViewCntrl = .main_menu
    var focusDict: [String: Any?] = [:]
}

extension MenuViewModel {
    func updateFocusStop(time: Focus.StopTime, callback: @escaping ((Any?, Error?) -> Void)) {
        // update focus time value
        focusObj?.focus_untill_stop = false

        switch time {
        case .half_past:
            focusObj?.is_focusing = true // Need to check what to do.
        case .one_hr:
            focusObj?.is_focusing = true
        case .two_hr:
            focusObj?.is_focusing = true
        case .untill_press_stop:
            focusObj?.is_focusing = true
            if !(focusDict[Focus.Options.focus_break.key_name] as? Bool ?? false) {
                focusDict[Focus.Options.focus_stop_length.key_name] = Focus.FocusTime.long_focus_stop_lenght
                focusDict[Focus.Options.focus_break_length.key_name] = Focus.FocusTime.fifteen.valueInSeconds
            }
            focusDict["focus_untill_stop"] = true
            focusObj?.focus_untill_stop = true

        case .stop_focus:
            focusObj?.is_focusing = false
            print("stop_focus")
        }
        createFocus(time: time)
        callback(true, nil)
    }

    func updateFocusOption(option: Focus.Options, state: NSControl.StateValue, callback: @escaping ((Any?, Error?) -> Void)) {
        // update focus options value
        print("Options Key : \(option.key_name)")

        focusDict[option.key_name] = (state == .on) ? true : false
        switch option {
        case .focus_break:
            focusObj?.is_provided_short_break = (state == .on) ? true : false
            if focusDict[Focus.Options.focus_stop_length.key_name] == nil {
                focusDict[Focus.Options.focus_stop_length.key_name] = Focus.FocusTime.fifteen.valueInSeconds
            }

            if focusDict[Focus.Options.focus_break_length.key_name] == nil {
                focusDict[Focus.Options.focus_break_length.key_name] = Focus.BreakTime.five.valueInSeconds
            }

        case .block_program_website:
            print("block_program_website ::: \(state)")
            let arrBlock = model.input.getBlockList(cntrl: .main_menu).blists
            focusDict[Focus.Options.block_list.key_name] = (state == .on) ? (!arrBlock.isEmpty ? arrBlock[0].id : nil) : nil
            focusDict["is_block_list_dnd"] = (!arrBlock.isEmpty) ? arrBlock[0].is_dnd_category_on : false // This one used for cause If any blocklist has selected notification Category then it set here
        default:
            print("default ::: \(state)")
        }
        callback(state, nil)
    }

    func createFocus(time: Focus.StopTime) {
        var arrFocus: [Focus_List] = focusObj?.focuses?.allObjects as? [Focus_List] ?? []
        guard let obj = DBManager.shared.createFocus(data: focusDict) else { return }
        obj.created_date = Date()
        obj.focus_id = UUID()
        obj.focus_length_time = time.value
        obj.session_start_time = Date()
        let endTime = Int(time.value).secondsToTime()
        obj.session_end_time = Date().adding(hour: endTime.timeInHours, min: endTime.timeInMinutes, sec: endTime.timeInSeconds)
        obj.focus_type = Int16(ScheduleType.none.rawValue)
        arrFocus.append(obj)

        focusObj?.created_date = Date()
        focusObj?.focuses = NSSet(array: arrFocus)

        if focusObj?.extended_value == nil {
            let objExVal = Focuses_Extended_Value(context: DBManager.shared.managedContext)
            focusObj?.extended_value = objExVal
        }

        updateParallelFocusSession(time: time, focuslist: arrFocus)

        DBManager.shared.saveContext()
    }

    func updateParallelFocusSession(time: Focus.StopTime, focuslist: [Focus_List]) {
        print("Count focuslist :: \(focuslist.count)")
        let total_stop_focus = focuslist.reduce(0) { $0 + $1.focus_stop_after_length }
        let total_break_focus = focuslist.reduce(0) { $0 + $1.break_length_time }
        let total_focus_length = focuslist.reduce(0) { $0 + $1.focus_length_time }
        let is_dnd_mode = focuslist.compactMap({ $0.is_dnd_mode || $0.is_block_list_dnd }).filter({ $0 }).first ?? false
        let is_block_programe_select = focuslist.compactMap({ $0.is_block_programe_select }).filter({ $0 }).first ?? false

        let timeVal = (viewCntrl != .main_menu) ? total_focus_length : time.value
        focusObj?.combine_focus_length_time = total_focus_length
        focusObj?.combine_stop_focus_after_time = total_stop_focus
        focusObj?.combine_break_lenght_time = total_break_focus
        focusObj?.is_dnd_mode = is_dnd_mode
        focusObj?.is_block_programe_select = is_block_programe_select

        print("Remaining Time : \((total_focus_length - (focusObj?.used_focus_time ?? 0)))")
        focusObj?.remaining_focus_time = (viewCntrl != .main_menu) ? (total_focus_length - (focusObj?.used_focus_time ?? 0)) : timeVal
        focusObj?.remaining_break_time = total_break_focus
    }
}
