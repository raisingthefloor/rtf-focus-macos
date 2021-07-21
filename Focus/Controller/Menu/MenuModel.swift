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

enum Focus {
    static var entity_name: String {
        return "Focus"
    }

    enum Relationship {
        case block_data
        case override_data

        var key_name: String {
            switch self {
            case .block_data:
                return "block_data"
            case .override_data:
                return "override_block_data"
            }
        }
    }
}

extension Focus {
    enum StopTime: Int {
        case half_past = 0 // 30 min
        case one_hr
        case two_hr
        case untill_press_stop
        case stop_focus

        var title: String {
            switch self {
            case .half_past:
                return NSLocalizedString("Home.half_last", comment: "30 Min1")
            case .one_hr:
                return NSLocalizedString("Home.one_hr", comment: "1 Hr1")
            case .two_hr:
                return NSLocalizedString("Home.two_hr", comment: "2 Hr")
            case .untill_press_stop:
                return NSLocalizedString("Home.untill_press_stop", comment: "Focus untill I press stop")
            case .stop_focus:
                return NSLocalizedString("Home.stop_focus", comment: "STOP FOCUS")
            }
        }

        static var key_name: String {
            return "focus_length_time"
        }
    }

    enum BreakTime: Int, CaseIterable {
        case one
        case three
        case five
        case ten

        var value: Int {
            switch self {
            case .one:
                return 1
            case .three:
                return 3
            case .five:
                return 5
            case .ten:
                return 10
            }
        }

        static var breaktimes: NSMenu {
            let menus = NSMenu()
            for time in BreakTime.allCases {
                let menuItem = NSMenuItem(title: String(time.value), action: nil, keyEquivalent: "")
                menuItem.tag = time.rawValue
                menus.addItem(menuItem)
            }
            return menus
        }

        static var key_name: String {
            return "short_break_time"
        }
    }

    enum FocusTime: Int, CaseIterable {
        case fifteen
        case twenty
        case twentyfive
        case thirty
        case fourtyfive
        case sixty

        var value: Int {
            switch self {
            case .fifteen:
                return 15
            case .twenty:
                return 20
            case .twentyfive:
                return 25
            case .thirty:
                return 30
            case .fourtyfive:
                return 45
            case .sixty:
                return 60
            }
        }

        static var focustimes: NSMenu {
            let menus = NSMenu()
            for time in FocusTime.allCases {
                let menuItem = NSMenuItem(title: String(time.value), action: nil, keyEquivalent: "")
                menuItem.tag = time.rawValue
                menus.addItem(menuItem)
            }
            return menus
        }

        static var key_name: String {
            return "stop_focus_after_time"
        }
    }

    enum Options: Int {
        case dnd = 0
        case focus_break
        case block_program_website
        case focus_break_1
        case focus_break_2
        case block_list

        var title: String {
            switch self {
            case .dnd:
                return NSLocalizedString("Home.turn_on_dnd", comment: "Turn on “Do Not Disturb” while focusing")
            case .focus_break:
                return NSLocalizedString("Home.provide_short_1", comment: "Provide short")
            case .focus_break_1:
                return NSLocalizedString("Home.provide_short_2", comment: "min Breaks for every")
            case .focus_break_2:
                return NSLocalizedString("Home.provide_short_3", comment: "min of Focus")
            case .block_program_website:
                return NSLocalizedString("Home.block_select_prog_web", comment: "Block select programs & websites while focusing")
            case .block_list:
                return NSLocalizedString("Home.use_this_block_list", comment: "Use this blocklist: ")
            }
        }

        var information: String {
            switch self {
            case .dnd:
                return NSLocalizedString("Home.turn_on_dnd_info", comment: "(turns off notifications and calls)")
            case .focus_break, .focus_break_1, .focus_break_2:
                return NSLocalizedString("Home.provide_short_info", comment: "(click number to change)")
            case .block_program_website:
                return NSLocalizedString("Home.focus_lenght_title", comment: "Turn on FOCUS for the following length of the time.")
            case .block_list:
                return ""
            }
        }

        var isOn: NSControl.StateValue {
            switch self {
            case .dnd:
                return .on // set as per the prefrence or as per the DB
            case .focus_break:
                return .off
            case .block_program_website:
                return .on
            default:
                return .off
            }
        }

        var key_name: String {
            switch self {
            case .dnd:
                return "is_dnd_mode"
            case .focus_break_1:
                return "short_break_time"
            case .focus_break_2:
                return "stop_focus_after_time"
            default:
                return ""
            }
        }
    }
}
