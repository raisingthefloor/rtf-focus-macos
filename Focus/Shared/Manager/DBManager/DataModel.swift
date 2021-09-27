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
    func updateSelectedBlocklist(data: [[String: Any?]], callback: @escaping ((Bool) -> Void))
    func updateSelectedExceptionlist(data: [[String: Any?]], callback: @escaping ((Bool) -> Void))
    func updateSelectedCategorylist(objCat: Block_Category, callback: @escaping ((Bool) -> Void))
    func resetApplistSelection()
}

protocol DataModelOutput {
}

protocol DataModelType {
    var input: DataModelIntput { get }
    var output: DataModelOutput { get }
    var objBlocklist: Block_List? { get set }
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
        var i = 0
        for obj in categories {
            let menuItem = NSMenuItem(title: obj.name ?? "-", action: nil, keyEquivalent: "")
            menuItem.tag = i
            menus.addItem(menuItem)
            i = i + 1
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
        var i = 0
        for obj in blocklist {
            let menuItem = NSMenuItem(title: obj.name ?? "-", action: nil, keyEquivalent: "")
            menuItem.tag = i
            menus.addItem(menuItem)
            i = i + 1
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
                let data: [String: Any?] = ["name": val, "id": UUID(), "created_at": Date(), "type": CategoryType.system.rawValue]
                DBManager.shared.saveCategory(data: data, type: .system)
            }
            let data: [String: Any?] = ["name": "General", "id": UUID(), "created_at": Date(), "type": CategoryType.general.rawValue]
            DBManager.shared.saveCategory(data: data, type: .general)
        }
    }

    func storeBlocklist(data: [String: Any?]) {
        DBManager.shared.saveBlocklist(data: data)
    }

    func updateSelectedBlocklist(data: [[String: Any?]], callback: @escaping ((Bool) -> Void)) {
        var arrObj: [Block_App_Web] = []
        for val in data {
            let objblockWA = Block_App_Web(context: DBManager.managedContext)
            for (key, value) in val {
                objblockWA.setValue(value, forKeyPath: key)
            }
            arrObj.append(objblockWA)
        }
        arrObj = arrObj + (objBlocklist?.block_app_web?.allObjects as! [Block_App_Web])
        objBlocklist?.block_app_web = NSSet(array: arrObj)
        DBManager.shared.saveContext()
        callback(true)
    }

    func updateSelectedExceptionlist(data: [[String: Any?]], callback: @escaping ((Bool) -> Void)) {
        var arrObj: [Exception_App_Web] = []
        for val in data {
            let objexceptionWA = Exception_App_Web(context: DBManager.managedContext)
            for (key, value) in val {
                objexceptionWA.setValue(value, forKeyPath: key)
            }
            arrObj.append(objexceptionWA)
        }
        arrObj = arrObj + (objBlocklist?.exception_block?.allObjects as! [Exception_App_Web])
        objBlocklist?.exception_block = NSSet(array: arrObj)
        DBManager.shared.saveContext()
        callback(true)
    }

    func updateSelectedCategorylist(objCat: Block_Category, callback: @escaping ((Bool) -> Void)) {
        var arrObj: [Block_List_Category] = []
        if objCat.is_selected {
            let objCategory = Block_List_Category(context: DBManager.managedContext)
            objCategory.setValue(objCat.name, forKeyPath: "name")
            objCategory.setValue(objCat.id, forKeyPath: "id")
            objCategory.setValue(Date(), forKeyPath: "created_at")
            arrObj.append(objCategory)
            arrObj = arrObj + (objBlocklist?.block_category?.allObjects as! [Block_List_Category])
            objBlocklist?.block_category = NSSet(array: arrObj)
        } else {
            let arrCat = objBlocklist?.block_category?.allObjects as! [Block_List_Category]
            guard let obj = arrCat.filter({ $0.id == objCat.id }).compactMap({ $0 }).first else { return callback(false) }
            print(obj)
            DBManager.managedContext.delete(obj)
        }
        DBManager.shared.saveContext()
        callback(true)
    }

    func resetApplistSelection() {
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
