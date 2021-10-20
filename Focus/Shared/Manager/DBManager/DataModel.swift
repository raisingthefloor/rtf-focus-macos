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

//    let categories = ["Calls & Chat", "Notification (Turns Do Not Disturb ON)", "Social Media", "Games", "News", "Shopping", "Video (apps and sites)", "Dating", "Gambling", "Communication", "Email", "Ads", "Proxies"]

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

//        if cntrl == .main_menu {
//            let showOption = NSMenuItem(title: "Starter Blocklist", action: nil, keyEquivalent: "")
//            showOption.tag = -2
//            menus.addItem(showOption)
//        }
        var i = 0
        for obj in blocklist {
            var title = obj.name ?? "-"
            if obj.restart_computer || obj.random_character {
                title = "🔒" + " " + title
            }
            let menuItem = NSMenuItem(title: title, action: nil, keyEquivalent: "")
            menuItem.tag = i
            menus.addItem(menuItem)
            i = i + 1
        }

        if cntrl != .schedule_session {
            menus.addItem(.separator())
        }

        let title = cntrl.combolast_option_title
        let showOption = NSMenuItem(title: title, action: nil, keyEquivalent: "")
        showOption.tag = -1
        menus.addItem(showOption)
        return (menus, blocklist)
    }

    func storeCategory() {
        if !DBManager.shared.checkDataIsPresent(entityName: "Block_Category") {
            var i = 1
            for val in Categories.arrCategories {
                let data: [String: Any?] = ["name": val.name, "id": UUID(), "created_at": Date(), "type": CategoryType.system.rawValue, "index": i, "show_link": val.show_link]
                DBManager.shared.saveCategory(data: data, type: .system, cat: val)
                i = i + 1
            }
            let data: [String: Any?] = ["name": "General", "id": UUID(), "created_at": Date(), "type": CategoryType.general.rawValue]
            DBManager.shared.saveCategory(data: data, type: .general, cat: .general)
        }
    }

    func storeBlocklist(data: [String: Any?]) {
        DBManager.shared.saveBlocklist(data: data)
    }

    func updateSelectedBlocklist(data: [[String: Any?]], callback: @escaping ((Bool) -> Void)) {
        var arrObj: [Block_App_Web] = []
        for val in data {
            if !DBManager.shared.checkAppWebIsPresent(entityName: "Block_App_Web", name: val["name"] as? String) {
                let objblockWA = Block_App_Web(context: DBManager.shared.managedContext)
                for (key, value) in val {
                    objblockWA.setValue(value, forKeyPath: key)
                }
                arrObj.append(objblockWA)
            }
        }
        arrObj = arrObj + (objBlocklist?.block_app_web?.allObjects as! [Block_App_Web])
        objBlocklist?.block_app_web = NSSet(array: arrObj)
        DBManager.shared.saveContext()
        callback(true)
    }

    func updateSelectedExceptionlist(data: [[String: Any?]], callback: @escaping ((Bool) -> Void)) {
        var arrObj: [Exception_App_Web] = []
        for val in data {
            if !DBManager.shared.checkAppWebIsPresent(entityName: "Exception_App_Web", name: val["name"] as? String) {
                let objexceptionWA = Exception_App_Web(context: DBManager.shared.managedContext)
                for (key, value) in val {
                    objexceptionWA.setValue(value, forKeyPath: key)
                }
                arrObj.append(objexceptionWA)
            }
        }
        arrObj = arrObj + (objBlocklist?.exception_block?.allObjects as! [Exception_App_Web])
        objBlocklist?.exception_block = NSSet(array: arrObj)
        DBManager.shared.saveContext()
        callback(true)
    }

    func updateSelectedCategorylist(objCat: Block_Category, callback: @escaping ((Bool) -> Void)) {
        var arrObj: [Block_List_Category] = []
        if objCat.is_selected {
            let objCategory = Block_List_Category(context: DBManager.shared.managedContext)
            objCategory.setValue(objCat.name, forKeyPath: "name")
            objCategory.setValue(objCat.id, forKeyPath: "id")
            objCategory.setValue(Date(), forKeyPath: "created_at")
            arrObj.append(objCategory)
            arrObj = arrObj + (objBlocklist?.block_category?.allObjects as! [Block_List_Category])
            objBlocklist?.block_category = NSSet(array: arrObj)
        } else {
            let arrCat = objBlocklist?.block_category?.allObjects as! [Block_List_Category]
            guard let obj = arrCat.filter({ $0.id == objCat.id }).compactMap({ $0 }).first else { return callback(false) }
            DBManager.shared.managedContext.delete(obj)
        }
        DBManager.shared.saveContext()
        callback(true)
    }

    func resetApplistSelection() {
    }

    static func preAddSchedule() {
        if !DBManager.shared.checkDataIsPresent(entityName: "Focus_Schedule") {
            let colors: [String] = [Color.schedule_one_color.hex, Color.schedule_two_color.hex, Color.schedule_three_color.hex, Color.schedule_four_color.hex, Color.schedule_five_color.hex]
            var i = 0
            for color in colors {
                let color_type = (i == 3 || i == 4) ? ColorType.hollow.rawValue : ColorType.solid.rawValue
                let dict: [String: Any?] = ["id": UUID(), "block_list_id": nil, "block_list_name": nil, "session_color": color,
                                            "is_active": false, "start_time": nil, "end_time": nil, "created_at": Date(), "days": nil, "type": ScheduleType.none.rawValue, "color_type": color_type]
                DBManager.shared.createPreSchedule(data: dict)
                i = i + 1
            }
        }
    }
}

enum ViewCntrl: Int {
    case main_menu
    case custom_setting
    case general_setting
    case edit_blocklist
    case schedule_session
    case today_schedule

    var combolast_option_title: String {
        switch self {
        case .main_menu:
            return NSLocalizedString("Home.show_edit_blocklist", comment: "Show or Edit Blocklist")
        case .edit_blocklist:
            return NSLocalizedString("BS.create_new_blocklist", comment: "Create new blocklist...")
        case .schedule_session:
            return NSLocalizedString("SS.Reminder", comment: "Reminder")
        default:
            return ""
        }
    }
}

enum ColorType: Int {
    case solid = 1
    case hollow
}

enum Categories: String {
    // "Calls & Chat", "Ads" not in provided doc
    case notification
    case email
    case communication
    case games
    case proxies
    case videos
    case social_media
    case shopping
    case porn
    case news
    case gambling
    case dating
    case general

    var name: String {
        switch self {
        case .notification:
            return "Notification (Turns Do Not Disturb ON)"
        case .email:
            return "Email"
        case .communication:
            return "Communication"
        case .games:
            return "Games"
        case .proxies:
            return "Proxies"
        case .videos:
            return "Video (apps and sites)"
        case .social_media:
            return "Social Media"
        case .shopping:
            return "Shopping"
        case .porn:
            return "Porn"
        case .news:
            return "News"
        case .gambling:
            return "Gambling"
        case .dating:
            return "Dating"
        case .general:
            return "General"
        }
    }

    var show_link: Bool {
        switch self {
        case .porn, .notification, .general:
            return false
        default:
            return true
        }
    }

    static var arrCategories: [Categories] = [.notification, .social_media, .games, .news, .shopping, .videos, .dating, .gambling, .communication, .email, .porn, .proxies]
}
