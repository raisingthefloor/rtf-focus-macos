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

enum FocusDialogue: Int {
    case break_sequence_alert
    case launch_app_alert // Blocked message
    case seession_completed_alert
    case warning_forced_pause_alert // More than 2 hrs
    case till_stop_alert // It appears when Focus is set as "utill I stop". It appears when user tap on menu
    case end_break_alert
    case schedule_reminded_without_blocklist_alert // It appears if the user had scheduled a Focus period time - but did not ask that blocking be automatically turned on.
    case schedule_reminded_with_blocklist_alert // This dialogue appears if the person scheduled a Focus session (with blocking)  to start at this time.
    case disincentive_xx_character_alert // These dialogues appears if there is a disincentive programmed for the blocking list
    case disincentive_signout_signin_alert
}

extension FocusDialogue {
    var title: String {
        switch self {
        case .break_sequence_alert:
            return NSLocalizedString("Alert.break_time", comment: "Break Time")
        case .seession_completed_alert:
            return NSLocalizedString("Alert.session_completed", comment: "Focus Session Completed.")
        case .end_break_alert:
            return NSLocalizedString("Alert.end_break", comment: "End of Break")
        default: return ""
        }
    }

    var description: String {
        switch self {
        case .launch_app_alert:
            return NSLocalizedString("Alert.block_message", comment: "You selected this to be blocked during your focus session.")
        case .seession_completed_alert, .till_stop_alert:
            let str = NSLocalizedString("Alert.session_completed_desc", comment: "You have been focusing for %d hrs and %d min")
            return String(format: str, 2, 2)
        case .warning_forced_pause_alert:
            let str = NSLocalizedString("Alert.warning_forced_pause_desc", comment: "You have been focusing for %d hours or more.")
            return String(format: str, 2)
        case .schedule_reminded_without_blocklist_alert:
            return NSLocalizedString("Alert.schedule_reminded_without_blocklist_alert_desc", comment: "You asked to be reminded that you wanted to focus at this time")
        case .schedule_reminded_with_blocklist_alert:
            return NSLocalizedString("Alert.schedule_reminded_with_blocklist_alert_desc", comment: "You Scheduled and AUTO-FOCUS session with BLOCKING for right now") // Append the Block list
        case .disincentive_xx_character_alert:
            return NSLocalizedString("Alert.disincentive_xx_character_alert_desc", comment: "You set the blocklist (currently being used) to require you to complete the task below in order to stop the focus session.")
        case .disincentive_signout_signin_alert:
            return NSLocalizedString("Alert.disincentive_signout_signin_alert_desc", comment: "This BlockList requires that you sign out of Windows (macOS) and back in – in order to turn this particular BlockList off.")
        default: return ""
        }
    }

    var sub_description: String {
        switch self {
        case .schedule_reminded_with_blocklist_alert:
            return "Social, Facebook, Twitter" // TODO: Data will be comes from selected focus object and its block list
        case .disincentive_xx_character_alert:
            return NSLocalizedString("Alert.disincentive_xx_character_sub_desc", comment: "Type the following letters into the space below.")
        case .disincentive_signout_signin_alert:
            return NSLocalizedString("Alert.disincentive_signout_signin_alert_sub_desc", comment: "If you still want to stop the focus session, save your work and then restart your computer.")
        default:
            return ""
        }
    }

    var extented_title: String {
        switch self {
        case .break_sequence_alert:
            return NSLocalizedString("Alert.break_time_extented_title", comment: "I want to finish something remind me to break again in")
        case .seession_completed_alert:
            return NSLocalizedString("Alert.session_completed_extend_title", comment: "I want to finish something Extend focus session for")
        case .warning_forced_pause_alert:
            return NSLocalizedString("Alert.warning_forced_pause_extend_title", comment: "Take a longer break ?")
        case .end_break_alert:
            return NSLocalizedString("Alert.extend_break_title", comment: "Please Extend my break by")
        case .schedule_reminded_without_blocklist_alert:
            return NSLocalizedString("Alert.schedule_reminded_without_blocklist_alert", comment: "Remind me again in")
        case .schedule_reminded_with_blocklist_alert:
            return NSLocalizedString("Alert.schedule_reminded_with_blocklist_alert_title", comment: "Give me a few minutes First")
        default:
            return ""
        }
    }

    var extented_buttons: [String] {
        switch self {
        case .break_sequence_alert, .seession_completed_alert, .schedule_reminded_with_blocklist_alert:
            return [NSLocalizedString("Alert.five_min", comment: "5 min"), NSLocalizedString("Alert.fifteen_min", comment: "15 min"), NSLocalizedString("Alert.thirty_min", comment: "30 min")]
        case .launch_app_alert, .till_stop_alert, .disincentive_xx_character_alert, .disincentive_signout_signin_alert:
            return []
        case .warning_forced_pause_alert:
            return [NSLocalizedString("Alert.fifteen_min", comment: "15 min"), NSLocalizedString("Alert.thirty_min", comment: "30 min"), NSLocalizedString("Alert.one_hr", comment: "1 hr")]
        case .end_break_alert:
            return [NSLocalizedString("Alert.one_min", comment: "1 min"), NSLocalizedString("Alert.five_min", comment: "5 min"), NSLocalizedString("Alert.fifteen_min", comment: "15 min")]
        case .schedule_reminded_without_blocklist_alert:
            return [NSLocalizedString("Alert.five_min", comment: "5 min"), NSLocalizedString("Alert.fifteen_min", comment: "15 min"), NSLocalizedString("Alert.thirty_min", comment: "30 min"), NSLocalizedString("Alert.sixty_min", comment: "60 min")]
        }
    }

    var option_buttons: (titles: [String], position: ButtonPosition) {
        switch self {
        case .break_sequence_alert, .launch_app_alert:
            return ([NSLocalizedString("Button.ok", comment: "Ok"), NSLocalizedString("Button.stop_focusing", comment: "I want to Stop Focusing")], .bottom)
        case .seession_completed_alert:
            let btnString = NSLocalizedString("Button.ok", comment: "Ok") + " - " + NSLocalizedString("Button.done", comment: "Done")
            return ([btnString], .bottom)
        case .warning_forced_pause_alert:
            let str = NSLocalizedString("Alert.continue_with", comment: "Continue with") + " %@ " + NSLocalizedString("Alert.breaks", comment: "min Breaks")
            let btnString = String(format: str, "2")
            return ([btnString], .bottom)
        case .till_stop_alert:
            return ([NSLocalizedString("Button.continue_focusing", comment: "Continue Focusing"), NSLocalizedString("Button.stop_focusing", comment: "Stop Focusing")], .bottom)
        case .end_break_alert: // Option  top n bottom
            return ([NSLocalizedString("Button.back_to_focus", comment: "Back To Focus"), NSLocalizedString("Button.want_stop_focusing", comment: "I want to Stop Focusing")], .up_down)
        case .schedule_reminded_without_blocklist_alert:
            return ([NSLocalizedString("Button.ready_to_focus", comment: "OK - Ready to focus"), NSLocalizedString("Button.dont_remind", comment: "Don't Remind me until NEXT scheduled session")], .up_down)
        case .schedule_reminded_with_blocklist_alert:
            return ([NSLocalizedString("Button.ready_to_focus", comment: "OK - Ready to focus"), NSLocalizedString("Button.cancel_session", comment: "Cancel Focus Session")], .up_down)
        case .disincentive_xx_character_alert:
            return ([NSLocalizedString("Button.never_mind", comment: "Nevermind, go back"), NSLocalizedString("Button.stop_focus_session", comment: "Stop focus session")], .bottom)
        case .disincentive_signout_signin_alert:
            return ([NSLocalizedString("Button.never_mind", comment: "Nevermind, go back"), NSLocalizedString("Button.take_me_signout", comment: "OK, I’ll restart the computer")], .bottom)
        }
    }

    var green: NSColor {
        return Color.green_color
    }

    var mixedColor: NSColor {
        switch self {
        case .warning_forced_pause_alert:
            return Color.navy_blue_color
        case .disincentive_xx_character_alert, .seession_completed_alert:
            return Color.green_color
        default:
            return Color.red_color
        }
    }

    var option_buttons_theme: (bg_color: [NSColor], border_color: [NSColor], font_color: [NSColor], border_width: CGFloat) {
        let width: CGFloat = 0.6
        switch self {
        case .break_sequence_alert, .launch_app_alert:
            return ([], [], [], width)
        case .seession_completed_alert:
            return ([], [], [], width)
        case .warning_forced_pause_alert:
            return ([], [], [], width)
        case .till_stop_alert:
            return ([], [], [], width)
        case .end_break_alert: // Option  top n bottom
            return ([], [], [], width)
        case .schedule_reminded_without_blocklist_alert:
            return ([], [], [], width)
        case .schedule_reminded_with_blocklist_alert:
            return ([], [], [], width)
        case .disincentive_xx_character_alert:
            return ([Color.green_color, Color.very_light_grey], [Color.green_color, Color.dark_grey_border], [.white, Color.black_color], width)
        case .disincentive_signout_signin_alert:
            return ([Color.light_green_color, Color.green_color], [Color.green_color, Color.green_color], [Color.txt_green_color, .white], width)
        }
    }
}

enum ButtonPosition {
    case up_down
    case bottom
}
