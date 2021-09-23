//
//  DataModel.swift
//  Focus
//
//  Created by Bhavi on 23/09/21.
//  Copyright © 2021 Raising the Floor. All rights reserved.
//

import Cocoa
import Foundation

protocol DataModelIntput {
    func storeCategory()
    func storeBlocklist(data: [String: Any?])
    func getCategoryList(cntrl: ViewCntrl) -> (NSMenu, [Block_Category])
    func getBlockList(cntrl: ViewCntrl) -> (NSMenu, [Block_List])
    var objBlocklist: Block_List? { get set }
}

protocol DataModelOutput {
}

protocol DataModelType {
    var input: DataModelIntput { get }
    var output: DataModelOutput { get }
}

class DataModel: DataModelIntput, DataModelOutput, DataModelType {
    var objBlocklist: Block_List?
    var input: DataModelIntput { return self }
    var output: DataModelOutput { return self }

    let childeren: [String] = ["Facebook", "Intagram", "LinkedIn"]
    let categories = ["Calls & Chat", "Notification (Turns Do Not Disturb ON)", "Social Media", "Games", "News", "Shopping", "Video (apps and sites)", "Dating", "Gambling", "Communication", "Email", "Ads", "Proxies"]

    func getCategoryList(cntrl: ViewCntrl) -> (NSMenu, [Block_Category]) {
        let menus = NSMenu()
        let categories = DBManager.shared.getCategories()
        for obj in categories.reversed() {
            let menuItem = NSMenuItem(title: obj.name ?? "-", action: nil, keyEquivalent: "")
            menus.addItem(menuItem)
        }
        menus.addItem(.separator())
        let title = (cntrl == .edit_blocklist) ? NSLocalizedString("BS.create_new_blocklist", comment: "Create new blocklist...") : NSLocalizedString("Home.show_edit_blocklist", comment: "Show or Edit Blocklist")
        let showOption = NSMenuItem(title: title, action: nil, keyEquivalent: "c")
        showOption.tag = -1
        menus.addItem(showOption)
        return (menus, categories)
    }

    func getBlockList(cntrl: ViewCntrl) -> (NSMenu, [Block_List]) {
        let menus = NSMenu()
        let blocklist = DBManager.shared.getBlockList()
        for obj in blocklist.reversed() {
            let menuItem = NSMenuItem(title: obj.name ?? "-", action: nil, keyEquivalent: "")
            menus.addItem(menuItem)
        }
        menus.addItem(.separator())
        let title = (cntrl == .edit_blocklist) ? NSLocalizedString("BS.create_new_blocklist", comment: "Create new blocklist...") : NSLocalizedString("Home.show_edit_blocklist", comment: "Show or Edit Blocklist")
        let showOption = NSMenuItem(title: title, action: nil, keyEquivalent: "c")
        showOption.tag = -1
        menus.addItem(showOption)
        return (menus, blocklist)
    }

    func storeCategory() {
        if !DBManager.shared.checkDataIsPresent() {
            for val in categories {
                let data: [String: Any?] = ["name": val, "id": UUID(), "created_at": Date()]
                DBManager.shared.saveCategory(data: data)
            }
        }
    }

    func storeBlocklist(data: [String: Any?]) {
        DBManager.shared.saveCategory(data: data)
    }
}

enum ViewCntrl: Int {
    case main_menu
    case custom_setting
    case general_setting
    case edit_blocklist
    case schedule_session
    case today_schedule
}
