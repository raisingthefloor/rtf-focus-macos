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

enum ErrorDialogue: Int {
    case focus_schedule_error // It is used when that Schedule is active
    case edit_blocklist_error
    case schedule_error
    case general_setting_error
    case validation_error

    var title: String {
        switch self {
        case .focus_schedule_error:
            return NSLocalizedString("Error.active_session_error", comment: "Changes cannot be made to an active Focus session")
        case .edit_blocklist_error:
            return NSLocalizedString("Error.change_blocklist_error", comment: "Changes cannot be made to this Blocklist")
        case .schedule_error:
            return NSLocalizedString("Error.scheduler", comment: "Two Focus sessions already scheduled")
        case .general_setting_error:
            return NSLocalizedString("Error.active_focus_error", comment: "Changes cannot be made during active Focus session")
        case .validation_error:
            return NSLocalizedString("Error.validation_error", comment: "Validation error")
        }
    }

    var description: String {
        switch self {
        case .focus_schedule_error:
            return NSLocalizedString("Error.active_session_error_desc", comment: "A Focus session cannot be changed while it is in progress.\nYou must stop this session to make changes.")
        case .edit_blocklist_error:
            return NSLocalizedString("Error.change_blocklist_error_desc", comment: "A Blocklist cannot be changed while it is being used during a Focus session.\nYou must stop this session to make changes.")
        case .schedule_error:
            return NSLocalizedString("Error.scheduler_desc", comment: "More than two Focus sessions cannot be scheduled for the same time.\nTry editing your schedule.")
        case .general_setting_error:
            return NSLocalizedString("Error.active_focus_error_desc", comment: "General settings cannot be changed when at least one Focus session is in progress.\nYou must stop this session to make changes.")
        case .validation_error:
            return NSLocalizedString("Error.validation_error_desc", comment: "End time should be greater than start time")
        }
    }

    var info_random_charcter: String {
        switch self {
        case .focus_schedule_error, .edit_blocklist_error, .general_setting_error:
            return NSLocalizedString("Error.random_character_info", comment: "< include “stop task” message if there is as stop task>")
        case .schedule_error,.validation_error:
            return ""
        }
    }

    var info_restart_computer: String {
        switch self {
        case .focus_schedule_error, .edit_blocklist_error, .general_setting_error:
            return NSLocalizedString("Error.restart_computer_info", comment: "< include “stop task” message if there is as stop task>")
        case .schedule_error,.validation_error:
            return ""
        }
    }

    var islinkVisible: Bool {         
        switch self {
        case .schedule_error:
            return false
        default:
            return true
        }
    }
}
