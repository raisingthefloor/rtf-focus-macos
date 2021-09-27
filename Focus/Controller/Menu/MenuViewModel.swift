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
    var focusObj: Focuses? { get set }
}

protocol MenuViewModelOutput {
}

protocol MenuViewModelType {
    var input: MenuViewModelIntput { get }
    var output: MenuViewModelOutput { get }
}

class MenuViewModel: MenuViewModelIntput, MenuViewModelOutput, MenuViewModelType {
    var focusObj: Focuses? = {
        DBManager.shared.getFoucsObject()
    }()

    var input: MenuViewModelIntput { return self }
    var output: MenuViewModelOutput { return self }
}

extension MenuViewModel {
    func updateFocusStop(time: Focus.StopTime, callback: @escaping ((Any?, Error?) -> Void)) {
        // update focus time value
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

        case .stop_focus:
            focusObj?.is_focusing = false
            print("stop_focus")
        }
        focusObj?.created_date = Date()
        focusObj?.focus_length_time = time.value
        DBManager.shared.saveContext()
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
        default:
            print("default ::: \(state)")
        }
        DBManager.shared.saveContext()
        callback(state, nil)
    }
}
