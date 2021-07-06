//
//  MenuViewModel.swift
//  Focus
//
//  Created by Bhavi on 22/06/21.
//

import Cocoa
import Foundation
import L10n_swift
import RxRelay
import RxSwift

protocol MenuViewModelIntput {
    func getBlockList() -> (NSMenu, [String])
}

protocol MenuViewModelOutput: ActivityIndicatorProtocol {
    var onResult: PublishSubject<Result<Void, ErrorHandler>> { get set }
}

protocol MenuViewModelType {
    var input: MenuViewModelIntput { get }
    var output: MenuViewModelOutput { get }
}

class MenuViewModel: MenuViewModelIntput, MenuViewModelOutput, MenuViewModelType {
    var onResult: PublishSubject<Result<Void, ErrorHandler>> = PublishSubject()

    var input: MenuViewModelIntput { return self }
    var output: MenuViewModelOutput { return self }
    var is_animating: BehaviorRelay<Bool> = BehaviorRelay(value: false)
    let blockList = ["Starter block list", "Weekend block list", "Social", "Pirate"]

    var bag = DisposeBag()

    func getBlockList() -> (NSMenu, [String]) {
        let menus = NSMenu()
        for title in blockList {
            let menuItem = NSMenuItem(title: title, action: nil, keyEquivalent: "")
            menus.addItem(menuItem)
        }
        menus.addItem(.separator())
        let showOption = NSMenuItem(title: "Show or Edit Blocklist".l10n(), action: nil, keyEquivalent: "o")
        showOption.tag = -1
        menus.addItem(showOption)
        return (menus, blockList)
    }
}

enum FocusStopTime: Int {
    case half_past // 30 min
    case one_hr
    case two_hr
    case untill_press_stop
    case stop_focus

    var title: String {
        switch self {
        case .half_past:
            return "30 Min".l10n()
        case .one_hr:
            return "1 Hr".l10n()
        case .two_hr:
            return "2 Hr".l10n()
        case .untill_press_stop:
            return "Focus untill I press stop".l10n()
        case .stop_focus:
            return "STOP FOCUS".l10n()
        }
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
}

enum FocusOptions: Int {
    case dnd
    case focus_break
    case focus_break_1
    case focus_break_2
    case block_program_website
    case block_list

    var title: String {
        switch self {
        case .dnd:
            return "Turn on “Do Not Disturb” while focusing".l10n()
        case .focus_break:
            return "Provide short".l10n()
        case .focus_break_1:
            return "min Breaks for every".l10n()
        case .focus_break_2:
            return "min of Focus".l10n()
        case .block_program_website:
            return "Block select programs & websites while focusing".l10n()
        case .block_list:
            return "Use this blocklist: ".l10n()
        }
    }

    var information: String {
        switch self {
        case .dnd:
            return "(turns off notifications and calls)".l10n()
        case .focus_break, .focus_break_1, .focus_break_2:
            return "(click number to change)".l10n()
        case .block_program_website:
            return "Turn on FOCUS for the following length of the time.".l10n()
        case .block_list:
            return ""
        }
    }
}
