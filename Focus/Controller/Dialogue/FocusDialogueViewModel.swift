//
//  FocusDialogueViewModel.swift
//  Focus
//
//  Created by Bhavi on 22/07/21.
//  Copyright © 2021 Raising the Floor. All rights reserved.
//

import Foundation

enum FocusDialogue: Int {
    case break_alert
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
        case .break_alert:
            return NSLocalizedString("Alert.break_time", comment: "Break Time")
        case .launch_app_alert:
            return NSLocalizedString("Alert.break_alert_title", comment: "Break Time")
        case .seession_completed_alert:
            return NSLocalizedString("Alert.break_alert_title", comment: "Break Time")
        case .warning_forced_pause_alert:
            return NSLocalizedString("Alert.break_alert_title", comment: "Break Time")
        case .till_stop_alert:
            return NSLocalizedString("Alert.break_alert_title", comment: "Break Time")
        case .end_break_alert:
            return NSLocalizedString("Alert.break_alert_title", comment: "Break Time")
        case .schedule_reminded_without_blocklist_alert:
            return NSLocalizedString("Alert.break_alert_title", comment: "Break Time")
        case .schedule_reminded_with_blocklist_alert:
            return NSLocalizedString("Alert.break_alert_title", comment: "Break Time")
        case .disincentive_xx_character_alert:
            return NSLocalizedString("Alert.break_alert_title", comment: "Break Time")
        case .disincentive_signout_signin_alert:
            return NSLocalizedString("Alert.break_alert_title", comment: "Break Time")
        }
    }

    var description: String {
        switch self {
        case .break_alert:
            return ""
        case .launch_app_alert:
            return NSLocalizedString("Alert.break_alert_title", comment: "Break Time")
        case .seession_completed_alert:
            return NSLocalizedString("Alert.break_alert_title", comment: "Break Time")
        case .warning_forced_pause_alert:
            return NSLocalizedString("Alert.break_alert_title", comment: "Break Time")
        case .till_stop_alert:
            return NSLocalizedString("Alert.break_alert_title", comment: "Break Time")
        case .end_break_alert:
            return NSLocalizedString("Alert.break_alert_title", comment: "Break Time")
        case .schedule_reminded_without_blocklist_alert:
            return NSLocalizedString("Alert.break_alert_title", comment: "Break Time")
        case .schedule_reminded_with_blocklist_alert:
            return NSLocalizedString("Alert.break_alert_title", comment: "Break Time")
        case .disincentive_xx_character_alert:
            return NSLocalizedString("Alert.break_alert_title", comment: "Break Time")
        case .disincentive_signout_signin_alert:
            return NSLocalizedString("Alert.break_alert_title", comment: "Break Time")
        }
    }

    var extented_title: String {
        switch self {
        case .break_alert:
            return NSLocalizedString("Alert.break_time_extented_title", comment: "I want to finish something remind me to break again in")
        case .launch_app_alert:
            return NSLocalizedString("Alert.break_alert_title", comment: "Break Time")
        case .seession_completed_alert:
            return NSLocalizedString("Alert.break_alert_title", comment: "Break Time")
        case .warning_forced_pause_alert:
            return NSLocalizedString("Alert.break_alert_title", comment: "Break Time")
        case .till_stop_alert:
            return NSLocalizedString("Alert.break_alert_title", comment: "Break Time")
        case .end_break_alert:
            return NSLocalizedString("Alert.break_alert_title", comment: "Break Time")
        case .schedule_reminded_without_blocklist_alert:
            return NSLocalizedString("Alert.break_alert_title", comment: "Break Time")
        case .schedule_reminded_with_blocklist_alert:
            return NSLocalizedString("Alert.break_alert_title", comment: "Break Time")
        case .disincentive_xx_character_alert:
            return NSLocalizedString("Alert.break_alert_title", comment: "Break Time")
        case .disincentive_signout_signin_alert:
            return NSLocalizedString("Alert.break_alert_title", comment: "Break Time")
        }
    }

    var extented_buttons: [String] {
        switch self {
        case .break_alert:
            return [NSLocalizedString("Alert.five_min", comment: "5 min"), NSLocalizedString("Alert.fifteen_min", comment: "15 min"), NSLocalizedString("Alert.thirty_min", comment: "30 min")]
        case .launch_app_alert:
            return [NSLocalizedString("Alert.break_alert_title", comment: "Break Time")]
        case .seession_completed_alert:
            return [NSLocalizedString("Alert.break_alert_title", comment: "Break Time")]
        case .warning_forced_pause_alert:
            return [NSLocalizedString("Alert.break_alert_title", comment: "Break Time")]
        case .till_stop_alert:
            return [NSLocalizedString("Alert.break_alert_title", comment: "Break Time")]
        case .end_break_alert:
            return [NSLocalizedString("Alert.break_alert_title", comment: "Break Time")]
        case .schedule_reminded_without_blocklist_alert:
            return [NSLocalizedString("Alert.break_alert_title", comment: "Break Time")]
        case .schedule_reminded_with_blocklist_alert:
            return [NSLocalizedString("Alert.break_alert_title", comment: "Break Time")]
        case .disincentive_xx_character_alert:
            return [NSLocalizedString("Alert.break_alert_title", comment: "Break Time")]
        case .disincentive_signout_signin_alert:
            return [NSLocalizedString("Alert.break_alert_title", comment: "Break Time")]
        }
    }
    
    var option_buttons: [String] {
        switch self {
        case .break_alert:
            return [NSLocalizedString("Buttons.ok", comment: "Ok"), NSLocalizedString("Button.stop_focusing", comment: "I want to Stop Focusing")]
        case .launch_app_alert:
            return [NSLocalizedString("Alert.break_alert_title", comment: "Break Time")]
        case .seession_completed_alert:
            return [NSLocalizedString("Alert.break_alert_title", comment: "Break Time")]
        case .warning_forced_pause_alert:
            return [NSLocalizedString("Alert.break_alert_title", comment: "Break Time")]
        case .till_stop_alert:
            return [NSLocalizedString("Alert.break_alert_title", comment: "Break Time")]
        case .end_break_alert:
            return [NSLocalizedString("Alert.break_alert_title", comment: "Break Time")]
        case .schedule_reminded_without_blocklist_alert:
            return [NSLocalizedString("Alert.break_alert_title", comment: "Break Time")]
        case .schedule_reminded_with_blocklist_alert:
            return [NSLocalizedString("Alert.break_alert_title", comment: "Break Time")]
        case .disincentive_xx_character_alert:
            return [NSLocalizedString("Alert.break_alert_title", comment: "Break Time")]
        case .disincentive_signout_signin_alert:
            return [NSLocalizedString("Alert.break_alert_title", comment: "Break Time")]
        }
    }

}
