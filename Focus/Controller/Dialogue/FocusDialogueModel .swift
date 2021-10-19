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
    case short_break_alert
    case long_break_alert // More than 2 hrs
    case end_break_alert
    case launch_block_app_alert // Blocked message
    case notifiction_block_alert
    case seession_completed_alert
    case till_stop_alert // It appears when Focus is set as "utill I stop". It appears when user tap on menu

    case schedule_reminded_without_blocklist_alert // It appears if the user had scheduled a Focus period time - but did not ask that blocking be automatically turned on.
    case schedule_reminded_with_blocklist_alert // This dialogue appears if the person scheduled a Focus session (with blocking)  to start at this time.
    case disincentive_xx_character_alert // These dialogues appears if there is a disincentive programmed for the blocking list
    case disincentive_signout_signin_alert
    case none
}

extension FocusDialogue {
    var title: String {
        switch self {
        case .short_break_alert:
            return NSLocalizedString("Alert.break_time", comment: "Time for a break!")
        case .seession_completed_alert:
            return NSLocalizedString("Alert.session_completed", comment: "Focus Session Completed.")
        case .end_break_alert:
            return NSLocalizedString("Alert.end_break", comment: "End of break!")
        case .launch_block_app_alert, .notifiction_block_alert:
            return NSLocalizedString("Alert.block_app.is_blocked", comment: "%@ is blocked")
        case .long_break_alert:
            let str = NSLocalizedString("Alert.warning_forced_pause_desc", comment: "You have been focusing for %@ or more.")
            return str
        case .schedule_reminded_without_blocklist_alert:
            return NSLocalizedString("Alert.schedule_reminder.title", comment: "Focus Session Reminder")
        case .schedule_reminded_with_blocklist_alert:
            let str = NSLocalizedString("Alert.schedule_session_list.title", comment: "Your scheduled focus session starts in %@ min.")
            return String(format: str, 2)
        default: return ""
        }
    }

    var description: String {
        switch self {
        case .launch_block_app_alert, .notifiction_block_alert:
            return NSLocalizedString("Alert.block_message", comment: "%@ is blocked by the following blocklist,\n%@ \nwhich you selected for this focus session.")
        case .seession_completed_alert, .till_stop_alert:
            let str = NSLocalizedString("Alert.session_completed_desc", comment: "You have been focusing for:\n")
            return String(format: str, 2, 2)
        case .schedule_reminded_without_blocklist_alert:
            return NSLocalizedString("Alert.schedule_reminded_without_blocklist_alert_desc", comment: "You asked to be reminded that you wanted to focus at this time")
        case .schedule_reminded_with_blocklist_alert:
            return NSLocalizedString("Alert.schedule_reminded_with_blocklist_alert_desc", comment: "You scheduled a focus session for this time using the blocklist: \nMorning Meditation") // Append the Block list
        case .disincentive_xx_character_alert:
            return NSLocalizedString("Alert.disincentive_xx_character_alert_desc", comment: "You set the blocklist (currently being used) to require you to complete the task below in order to stop the focus session.")
        case .disincentive_signout_signin_alert:
            return NSLocalizedString("Alert.disincentive_signout_signin_alert_desc", comment: "This BlockList requires that you sign out of Windows (macOS) and back in – in order to turn this particular BlockList off.")
        default: return ""
        }
    }

    var sub_description: String {
        switch self {
        case .disincentive_xx_character_alert:
            return NSLocalizedString("Alert.disincentive_xx_character_sub_desc", comment: "Type the following letters into the space below.")
        case .disincentive_signout_signin_alert:
            return NSLocalizedString("Alert.disincentive_signout_signin_alert_sub_desc", comment: "If you still want to stop the focus session, save your work and then restart your computer.")
        case .seession_completed_alert:
            return NSLocalizedString("Alert.session_complete_subdesc", comment: "I want to focus a little longer.\nExtend focus session for:")
        case .notifiction_block_alert:
            return NSLocalizedString("Alert.block_app.notification", comment: "Turning off <Do Not Disturb/Focus Assistance> would \nallow notifications, so it cannot be turned off while \nthis blocklist is being used.")
        default:
            return ""
        }
    }

    var subdesc_font: NSFont {
        switch self {
        case .disincentive_xx_character_alert:
            return NSFont.systemFont(ofSize: 12, weight: .regular)
        case .disincentive_signout_signin_alert:
            return NSFont.systemFont(ofSize: 12, weight: .regular) // Italic
        default:
            return NSFont.systemFont(ofSize: 12, weight: .regular)
        }
    }

    var extented_title: String {
        switch self {
        case .short_break_alert:
            return NSLocalizedString("Alert.break_time_extented_title", comment: "I want to focus a little longer. Remind me to break again in:")
        case .seession_completed_alert:
            return NSLocalizedString("Alert.session_completed_extend_title", comment: "I want to finish something Extend focus session for")
        case .long_break_alert:
            return NSLocalizedString("Alert.warning_forced_pause_extend_title", comment: "Would you like to take a longer break?")
        case .end_break_alert:
            return NSLocalizedString("Alert.extend_break_title", comment: "Or, extend my break by...")
        case .schedule_reminded_without_blocklist_alert:
            return NSLocalizedString("Alert.schedule_reminded_without_blocklist_alert", comment: "Remind me again in")
        case .schedule_reminded_with_blocklist_alert:
            return NSLocalizedString("Alert.schedule_reminded_with_blocklist_alert_title", comment: "No, instead start session:")
        default:
            return ""
        }
    }

    var extented_buttons: [String] {
        switch self {
        case .short_break_alert, .seession_completed_alert, .schedule_reminded_with_blocklist_alert:
            return [NSLocalizedString("Alert.five_min", comment: "5 min"), NSLocalizedString("Alert.fifteen_min", comment: "15 min"), NSLocalizedString("Alert.thirty_min", comment: "30 min")]
        case .launch_block_app_alert, .till_stop_alert, .disincentive_xx_character_alert, .disincentive_signout_signin_alert, .notifiction_block_alert:
            return []
        case .long_break_alert:
            return [NSLocalizedString("Alert.fifteen_min", comment: "15 min"), NSLocalizedString("Alert.thirty_min", comment: "30 min"), NSLocalizedString("Alert.one_hr", comment: "1 hr")]
        case .end_break_alert:
            return [NSLocalizedString("Alert.one_min", comment: "1 min"), NSLocalizedString("Alert.five_min", comment: "5 min"), NSLocalizedString("Alert.fifteen_min", comment: "15 min")]
        case .schedule_reminded_without_blocklist_alert:
            return [NSLocalizedString("Alert.five_min", comment: "5 min"), NSLocalizedString("Alert.fifteen_min", comment: "15 min"), NSLocalizedString("Alert.thirty_min", comment: "30 min"), NSLocalizedString("Alert.sixty_min", comment: "60 min")]
        case .none:
            return []
        }
    }

    var option_buttons: (titles: [String], position: ButtonPosition) {
        switch self {
        case .short_break_alert, .launch_block_app_alert, .notifiction_block_alert:
            return ([NSLocalizedString("Button.stop_focus_session", comment: "Stop focus session"), NSLocalizedString("Button.ok", comment: "Ok")], .bottom)
        case .seession_completed_alert:
            let btnString = NSLocalizedString("Button.ok", comment: "Ok") + " - " + NSLocalizedString("Button.done", comment: "Done")
            return ([btnString], .bottom)
        case .long_break_alert:
            let str = NSLocalizedString("Alert.continue_with", comment: "Continue with") + " %@ " + NSLocalizedString("Alert.breaks", comment: "Breaks")
            let btnString = str
            return ([NSLocalizedString("Button.stop_focus_session", comment: "Stop focus session"), btnString], .bottom)
        case .till_stop_alert:
            return ([NSLocalizedString("Button.continue_focusing", comment: "Continue Focusing"), NSLocalizedString("Button.stop_focusing", comment: "Stop Focusing")], .bottom)
        case .end_break_alert: // Option  top n bottom
            let btnString = NSLocalizedString("Button.ok", comment: "Ok") + ", " + NSLocalizedString("Button.back_to_focus", comment: "back to focus")
            return ([NSLocalizedString("Button.stop_focus_session", comment: "Stop focus session"), btnString], .up_down)
        case .schedule_reminded_without_blocklist_alert:
            return ([NSLocalizedString("Button.skip_session", comment: "Skip this focus session"), NSLocalizedString("Button.start_focus", comment: "Start focus session")], .up_down)
        case .schedule_reminded_with_blocklist_alert:

            let btnString = NSLocalizedString("Button.ok", comment: "Ok") + ", " + String(format: NSLocalizedString("Button.start_in", comment: "start in %d min"), 2)
            return ([NSLocalizedString("Button.skip_session", comment: "Skip this focus session"), btnString], .up_down)
        case .disincentive_xx_character_alert:
            return ([NSLocalizedString("Button.never_mind", comment: "Nevermind, go back"), NSLocalizedString("Button.stop_focus_session", comment: "Stop focus session")], .bottom)
        case .disincentive_signout_signin_alert:
            return ([NSLocalizedString("Button.never_mind", comment: "Nevermind, go back"), NSLocalizedString("Button.take_me_signout", comment: "OK, I’ll restart the computer")], .bottom)
        case .none:
            return ([], .bottom)
        }
    }

    var green: NSColor {
        return Color.green_color
    }

    var light_green: NSColor {
        return Color.light_green_color
    }

    var stop_color: NSColor {
        return Color.very_light_grey
    }

    var mixedColor: NSColor {
        switch self {
        case .long_break_alert:
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
        case .short_break_alert:
            return ([], [], [], width)
        case .launch_block_app_alert, .notifiction_block_alert:
            return ([Color.green_color, Color.very_light_grey], [Color.green_color, Color.dark_grey_border], [.white, Color.black_color], width)
        case .seession_completed_alert:
            return ([], [], [], width)
        case .long_break_alert:
            return ([], [], [], width)
        case .till_stop_alert:
            return ([], [], [], width)
        case .end_break_alert: // Option  top n bottom
            return ([], [], [], width)
        case .schedule_reminded_without_blocklist_alert:
            return ([], [], [], width)
        case .schedule_reminded_with_blocklist_alert:
            return ([], [], [], width)
        case .none:
            return ([], [], [], width)
        case .disincentive_xx_character_alert:
            return ([Color.green_color, Color.very_light_grey], [Color.green_color, Color.dark_grey_border], [.white, Color.black_color], width)
        case .disincentive_signout_signin_alert:
            return ([Color.light_green_color, Color.green_color], [Color.green_color, Color.green_color], [Color.txt_green_color, .white], width)
        }
    }

    var value: [Int] {
        switch self {
        case .short_break_alert, .seession_completed_alert, .schedule_reminded_with_blocklist_alert:
            return [5 * 60, 15 * 60, 30 * 60]
        case .launch_block_app_alert, .till_stop_alert, .disincentive_xx_character_alert, .disincentive_signout_signin_alert, .notifiction_block_alert:
            return []
        case .long_break_alert:
            return [15 * 60, 30 * 60, 60 * 60]
        case .end_break_alert:
            return [1 * 60, 5 * 60, 15 * 60]
        case .schedule_reminded_without_blocklist_alert:
            return [5, 15, 30, 60]
        case .none:
            return []
        }
    }

    var action: ButtonAction {
        switch self {
        case .short_break_alert, .seession_completed_alert:
            return .extend_focus
        case .end_break_alert:
            return .extent_break
        case .launch_block_app_alert, .notifiction_block_alert:
            return .normal_ok
        case .long_break_alert:
            return .normal_ok
        case .schedule_reminded_without_blocklist_alert, .schedule_reminded_with_blocklist_alert:
            return .extend_reminder
        default:
            return .normal_ok
        }
    }

    var is_extented_buttons: [Bool] {
        let objExte = DBManager.shared.getCurrentSession()?.extended_value
        switch self {
        case .short_break_alert:
            return [objExte?.is_small_focus ?? false, objExte?.is_mid_focus ?? false, objExte?.is_long_focus ?? false]
        case .long_break_alert:
            return [objExte?.is_small_focus ?? false, objExte?.is_mid_focus ?? false, objExte?.is_long_focus ?? false]
        case .end_break_alert:
            return [objExte?.is_small_break ?? false, objExte?.is_mid_break ?? false, objExte?.is_long_break ?? false]
        case .schedule_reminded_without_blocklist_alert:
            return []
        case .seession_completed_alert: return []
        case .schedule_reminded_with_blocklist_alert: return []
        default:
            return []
        }
    }
}

enum ButtonPosition {
    case up_down
    case bottom
}

enum ButtonAction {
    case extend_focus
    case extent_break
    case stop_session
    case skip_session
    case normal_ok
    case extend_reminder
}

enum ButtonValueType: Int {
    case small
    case mid
    case long
    case long_long
    case none
}
