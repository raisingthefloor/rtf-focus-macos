/* Copyright 2020 Raising the Floor - International

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

import CoreData
import Foundation

class DBManager {
    static var shared: DBMangerLogic = DBManager()
    var managedContext: NSManagedObjectContext

    init() {
        let container = DataController.shared.fetchPersistentContainer()
        managedContext = container.viewContext
    }
}

// Block List
extension DBManager: DBMangerLogic {
    func getCurrentBlockList() -> (objFocus: Focuses?, objBl: Block_List?, apps: [Block_Interface], webs: [Block_Interface]) {
        let generalCat = getGeneralCategoryData().subCat

        guard let objFocus = getCurrentSession() else { return (nil, nil, [], []) }

//        if let second_blist_id = objFocus.block_list_second_id, let id = objFocus.block_list_id, second_blist_id != id {
//            second_result = getSecondSessionBlockList(objFocus: objFocus, generalCat: generalCat)
//        }

        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Block_List")
        if let id = objFocus.block_list_id {
            fetchRequest.predicate = NSPredicate(format: "id = %@", id as CVarArg)
        }

        do {
            let block = try DBManager.shared.managedContext.fetch(fetchRequest)

            guard let blocks = (block as? [Block_List])?.first else { return (objFocus, nil, [], []) }

            guard let arrBlocks = blocks.block_app_web?.allObjects as? [Block_Interface] else { return (objFocus, blocks, [], []) }

            var applist: [Block_Interface] = arrBlocks.filter({ $0.block_type == BlockType.application.rawValue }).compactMap({ $0 })
            var weblist: [Block_Interface] = arrBlocks.filter({ $0.block_type == BlockType.web.rawValue }).compactMap({ $0 })

            // Category List Adding
            if let arrCategory = blocks.block_category?.allObjects as? [Block_List_Category], !arrCategory.isEmpty {
                let arrIds = arrCategory.compactMap({ $0.id })
                let arrSubCate = getCategoryData(ids: arrIds)

                applist = applist + arrSubCate.filter({ $0.block_type == BlockType.application.rawValue }).compactMap({ $0 })
                weblist = weblist + arrSubCate.filter({ $0.block_type == BlockType.web.rawValue }).compactMap({ $0 })
            }

            // General Setting App and Site List Filter
            if !generalCat.isEmpty {
                let gCApp = generalCat
                    .filter({ $0.block_type == BlockType.application.rawValue })
                    .compactMap({ $0 })
                    .filter({ $0.is_selected == true }).compactMap({ $0 })

                gCApp.forEach { val in
                    applist.removeAll(where: { $0.app_identifier == val.app_identifier })
                }
//                print("Filter GC App : \(applist)")

                let gCWeb = generalCat.filter({ $0.block_type == BlockType.web.rawValue }).compactMap({ $0 }).filter({ $0.is_selected == true }).compactMap({ $0 })

                gCWeb.forEach { val in
                    weblist.removeAll(where: { $0.name == val.name })
                }
//                print("Filter GC Web: \(weblist)")
            }

            // Exception App and site List Filter
            if let arrExceBlocks = blocks.exception_block?.allObjects as? [Block_Interface], !arrExceBlocks.isEmpty {
                let gEApp = arrExceBlocks.filter({ $0.block_type == BlockType.application.rawValue }).compactMap({ $0 })

                gEApp.forEach { val in
                    applist.removeAll(where: { $0.app_identifier == val.app_identifier })
                }
//                print("Filter Exception App: \(applist)")
                let gEWeb = arrExceBlocks.filter({ $0.block_type == BlockType.web.rawValue }).compactMap({ $0 })

                gEWeb.forEach { val in
                    weblist.removeAll(where: { $0.name == val.name })
                }
//                print("Filter Exception Web: \(weblist)")
            }
//            print("Final applist : \(applist)")
//            print("Final weblist : \(weblist)")

            return (objFocus, blocks, applist, weblist)

        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
        return (objFocus, nil, [], [])
    }
}

//    func getSecondSessionBlockList(objFocus: Focuses, generalCat: [Block_Category_App_Web]) -> (objBl: Block_List?, apps: [Block_Interface], webs: [Block_Interface]) {
//        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Block_List")
//        if let id = objFocus.block_list_second_id {
//            fetchRequest.predicate = NSPredicate(format: "id = %@", id as CVarArg)
//        }
//
//        do {
//            let block = try DBManager.shared.managedContext.fetch(fetchRequest)
//
//            guard let blocks = (block as? [Block_List])?.first else { return (nil, [], []) }
//
//            guard let arrBlocks = blocks.block_app_web?.allObjects as? [Block_Interface] else { return (blocks, [], []) }
//
//            var applist: [Block_Interface] = arrBlocks.filter({ $0.block_type == BlockType.application.rawValue }).compactMap({ $0 })
//            var weblist: [Block_Interface] = arrBlocks.filter({ $0.block_type == BlockType.web.rawValue }).compactMap({ $0 })
//
//            // Category List Adding
//            if let arrCategory = blocks.block_category?.allObjects as? [Block_List_Category], !arrCategory.isEmpty {
//                let arrIds = arrCategory.compactMap({ $0.id })
//
//                let arrSubCate = getCategoryData(ids: arrIds)
//
//                applist = applist + arrSubCate.filter({ $0.block_type == BlockType.application.rawValue }).compactMap({ $0 })
//                weblist = weblist + arrSubCate.filter({ $0.block_type == BlockType.web.rawValue }).compactMap({ $0 })
//            }
//
//            // General Setting App and Site List Filter
//            if !generalCat.isEmpty {
//                let gCApp = generalCat
//                    .filter({ $0.block_type == BlockType.application.rawValue })
//                    .compactMap({ $0 })
//                    .filter({ $0.is_selected == true }).compactMap({ $0 })
//
//                gCApp.forEach { val in
//                    applist.removeAll(where: { $0.app_identifier == val.app_identifier })
//                }
//
//                let gCWeb = generalCat.filter({ $0.block_type == BlockType.web.rawValue }).compactMap({ $0 }).filter({ $0.is_selected == true }).compactMap({ $0 })
//
//                gCWeb.forEach { val in
//                    weblist.removeAll(where: { $0.name == val.name })
//                }
//            }
//
//            // Exception App and site List Filter
//            if let arrExceBlocks = blocks.exception_block?.allObjects as? [Block_Interface], !arrExceBlocks.isEmpty {
//                let gEApp = arrExceBlocks.filter({ $0.block_type == BlockType.application.rawValue }).compactMap({ $0 })
//
//                gEApp.forEach { val in
//                    applist.removeAll(where: { $0.app_identifier == val.app_identifier })
//                }
//                let gEWeb = arrExceBlocks.filter({ $0.block_type == BlockType.web.rawValue }).compactMap({ $0 })
//
//                gEWeb.forEach { val in
//                    weblist.removeAll(where: { $0.name == val.name })
//                }
//            }
//            return (blocks, applist, weblist)
//
//        } catch let error as NSError {
//            print("Could not fetch. \(error), \(error.userInfo)")
//        }
//        return (nil, [], [])
//    }
// }

// Focus Create
extension DBManager {
    func checkAppWebIsPresent(entityName: String, name: String?) -> Bool {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
        fetchRequest.predicate = NSPredicate(format: "name = %@", name ?? "")

        do {
            let results = try DBManager.shared.managedContext.fetch(fetchRequest)
            if results.count > 0 {
                return true
            } else {
                return false
            }
        } catch let error {
            print("Could not Check data. categories \(error), \(error.localizedDescription)")
            return false
        }
    }

    func createFocus(data: [String: Any]) {
        let entity = NSEntityDescription.entity(forEntityName: Focus.entity_name, in: DBManager.shared.managedContext)!
        let block = NSManagedObject(entity: entity, insertInto: DBManager.shared.managedContext)

        for (key, value) in data {
            block.setValue(value, forKeyPath: key)
        }

        do {
            try DBManager.shared.managedContext.save()
        } catch let error as NSError {
            print("Could not save focus. \(error), \(error.userInfo)")
        }
    }

    func getFoucsObject() -> Focuses? {
        var focusObj: Focuses?
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: Focus.entity_name)
//        fetchRequest.predicate = NSPredicate(format: "is_focusing = true")

        do {
            let results = try DBManager.shared.managedContext.fetch(fetchRequest)
            if results.count > 0 {
                focusObj = results.first as? Focuses
            } else {
                focusObj = Focuses(context: DBManager.shared.managedContext)
                focusObj?.uuid = UUID()
            }
        } catch let error {
            print(error.localizedDescription)
        }
        return focusObj
    }

    func getCurrentSession() -> Focuses? {
        var focusObj: Focuses?
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: Focus.entity_name)
        fetchRequest.predicate = NSPredicate(format: "is_focusing = true")

        do {
            let results = try DBManager.shared.managedContext.fetch(fetchRequest)
            if results.count > 0 {
                focusObj = results.first as? Focuses
            }
        } catch let error {
            print(error.localizedDescription)
        }
        return focusObj
    }

    func saveApplicationlist(data: [String: Any]) {
        let entity = NSEntityDescription.entity(forEntityName: "Application_List", in: DBManager.shared.managedContext)!
        let block = NSManagedObject(entity: entity, insertInto: DBManager.shared.managedContext)

        for (key, value) in data {
            block.setValue(value, forKeyPath: key)
        }

        do {
            try DBManager.shared.managedContext.save()
        } catch let error as NSError {
            print("Could not save focus. \(error), \(error.userInfo)")
        }
    }

    func getApplicationList() -> [Application_List] {
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Application_List")
        fetchRequest.predicate = NSPredicate(format: "path BEGINSWITH[cd] '/Application' || path BEGINSWITH[cd] '/System/Applications/' && NOT (path CONTAINS '/System/Applications/Utilities/')")
        fetchRequest.sortDescriptors = [NSSortDescriptor(keyPath: \Application_List.name, ascending: true)]

        do {
            let block = try DBManager.shared.managedContext.fetch(fetchRequest)
            guard let applications = block as? [Application_List] else { return [] }
            return applications
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }

        return []
    }

    func checkAppsIsPresent(bundle_id: String) -> Bool {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Application_List")
        fetchRequest.predicate = NSPredicate(format: "bundle_id = %@", bundle_id)

        do {
            let results = try DBManager.shared.managedContext.fetch(fetchRequest)
            if results.count > 0 {
                return true
            } else {
                return false
            }
        } catch let error {
            print("Could not Check data. categories \(error), \(error.localizedDescription)")
            return false
        }
    }
}

// MARK: Block list Store and Fetch

extension DBManager {
    func saveBlocklist(data: [String: Any?]) {
        let entity = NSEntityDescription.entity(forEntityName: "Block_List", in: DBManager.shared.managedContext)!
        let category = NSManagedObject(entity: entity, insertInto: DBManager.shared.managedContext)

        for (key, value) in data {
            category.setValue(value, forKeyPath: key)
        }

        do {
            try DBManager.shared.managedContext.save()
        } catch let error as NSError {
            print("Could not save category. \(error), \(error.userInfo)")
        }
    }

    func getBlockList() -> [Block_List] {
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Block_List")
        fetchRequest.sortDescriptors = [NSSortDescriptor(keyPath: \Block_List.created_at, ascending: false)]
        do {
            let block = try DBManager.shared.managedContext.fetch(fetchRequest)
            guard let blocklist = block as? [Block_List] else { return [] }
            return blocklist
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }

        return []
    }

    func systemPreAddedBlocklist() {
        let arrBl = DefaultBlocklist.arrDefaultBl

        for bl in arrBl {
            let data: [String: Any?] = ["name": bl.blist_name, "id": UUID(), "created_at": Date()]
            let entity = NSEntityDescription.entity(forEntityName: "Block_List", in: DBManager.shared.managedContext)!
            let blist = NSManagedObject(entity: entity, insertInto: DBManager.shared.managedContext) as? Block_List

            for (key, value) in data {
                blist?.setValue(value, forKeyPath: key)
            }

            blist?.random_character = false
            blist?.restart_computer = false
            blist?.stop_focus_session_anytime = true

            blist?.blocked_all_break = false
            blist?.unblock_short_long_break = true
            blist?.unblock_long_break_only = false

            var arrObj: [Block_List_Category] = []
            // Setting the Category list id
            for cat in bl.set_categories {
                guard let objCate = DBManager.shared.getCategoryBy(name: cat.name) else { continue }
                let categoryData: [String: Any?] = ["id": objCate.id, "name": objCate.name, "created_at": Date()]
                let objblockCate = Block_List_Category(context: DBManager.shared.managedContext)

                for (key, value) in categoryData {
                    objblockCate.setValue(value, forKeyPath: key)
                }
                arrObj.append(objblockCate)
            }
            arrObj = arrObj + (blist?.block_category?.allObjects as! [Block_List_Category])

            blist?.block_category = NSSet(array: arrObj)
            do {
                try DBManager.shared.managedContext.save()
            } catch let error as NSError {
                print("Could not save category. \(error), \(error.userInfo)")
            }
        }
        UserDefaults.standard.set(true, forKey: "pre_added_blocklist")
    }
}

// MARK: Category Store and Fetch

extension DBManager {
    func checkDataIsPresent(entityName: String) -> Bool {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
        do {
            let results = try DBManager.shared.managedContext.fetch(fetchRequest)
            if results.count > 0 {
                return true
            } else {
                return false
            }
        } catch let error {
            print("Could not Check data. \(entityName) \(error), \(error.localizedDescription)")
            return false
        }
    }

    func getCategoryBy(name: String) -> Block_Category? {
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Block_Category")
        fetchRequest.predicate = NSPredicate(format: "name = %@", name)

        do {
            let block = try DBManager.shared.managedContext.fetch(fetchRequest)
            guard let categories = block as? [Block_Category] else { return nil }
            return categories.first
        } catch let error as NSError {
            print("Could not fetch. category by name \(error), \(error.userInfo)")
        }

        return nil
    }

    func saveCategory(data: [String: Any?], type: CategoryType, cat: Categories, isExist: Bool) {
        if !isExist {
            let entity = NSEntityDescription.entity(forEntityName: "Block_Category", in: DBManager.shared.managedContext)!
            let category = NSManagedObject(entity: entity, insertInto: DBManager.shared.managedContext)

            for (key, value) in data {
                category.setValue(value, forKeyPath: key)
            }
            storeCategoryWebApp(type: type, cat: cat, category: category as? Block_Category)
            if type == .general {
                let setting_data: [String: Any?] = ["warning_before_schedule_session_start": false, "provide_short_break_schedule_session": false, "block_screen_first_min_each_break": false, "show_count_down_for_break_start_end": false, "break_time": Focus.BreakTime.five.valueInSeconds, "for_every_time": Focus.FocusTime.fifteen.valueInSeconds]

                let objGS = General_Settings(context: DBManager.shared.managedContext)
                for (key, value) in setting_data {
                    objGS.setValue(value, forKeyPath: key)
                }
                (category as? Block_Category)?.general_setting = objGS
            }
        } else {
            let cate = getCategoryBy(name: cat.name)
            storeCategoryWebApp(type: type, cat: cat, category: cate)
        }

        do {
            try DBManager.shared.managedContext.save()
        } catch let error as NSError {
            print("Could not save category. \(error), \(error.userInfo)")
        }
    }

    func storeCategoryWebApp(type: CategoryType, cat: Categories, category: Block_Category?) {
        if type != .general || cat != .notification {
            var arrSD: [Block_Category_App_Web] = []

            let file_name_site = cat.rawValue + "_site"
            var sub_data = CSVParser.shared.getDataInDictionary(fileName: file_name_site, fileType: "csv")

            let file_name_app = cat.rawValue + "_app"
            sub_data = sub_data + CSVParser.shared.getDataInDictionary(fileName: file_name_app, fileType: "csv")

            for val in sub_data {
                let objSC = Block_Category_App_Web(context: DBManager.shared.managedContext)

                for (key, value) in val {
                    objSC.setValue(value, forKeyPath: key)
                }
                arrSD.append(objSC)
            }
            category?.sub_data = NSSet(array: arrSD)
        }
    }

    func getCategories() -> [Block_Category] {
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Block_Category")
        fetchRequest.sortDescriptors = [NSSortDescriptor(keyPath: \Block_Category.index, ascending: true)]
        fetchRequest.predicate = NSPredicate(format: "type = %d", CategoryType.system.rawValue)

        do {
            let block = try DBManager.shared.managedContext.fetch(fetchRequest)
            guard let categories = block as? [Block_Category] else { return [] }
            return categories
        } catch let error as NSError {
            print("Could not fetch. categories \(error), \(error.userInfo)")
        }

        return []
    }

    func getGeneralCategoryData() -> (gCat: Block_Category?, subCat: [Block_Category_App_Web]) {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Block_Category")
        fetchRequest.predicate = NSPredicate(format: "type = %d", CategoryType.general.rawValue)
        do {
            let categories = try DBManager.shared.managedContext.fetch(fetchRequest)
            guard let category = categories.first as? Block_Category else { return (nil, []) }
            return (category, category.sub_data?.allObjects as! [Block_Category_App_Web])
        } catch let error as NSError {
            print("Could not General Cat fetch. \(error), \(error.userInfo)")
        }
        return (nil, [])
    }

    func getCategoryData(ids: [UUID]) -> [Block_Category_App_Web] {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Block_Category")
        fetchRequest.predicate = NSPredicate(format: "ANY id IN %@", ids)
        do {
            let categories = try DBManager.shared.managedContext.fetch(fetchRequest)
            guard let category = categories as? [Block_Category] else { return [] }

            let arrData = category.compactMap({ $0.sub_data?.allObjects })
            return arrData.joined().compactMap({ $0 as? Block_Category_App_Web })
        } catch let error as NSError {
            print("Could not Category Sub Cat fetch. \(error), \(error.userInfo)")
        }
        return []
    }
}

extension DBManager {
    func getGeneralSetting() -> General_Setting? {
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "General_Setting")
        do {
            let generalSetting = try DBManager.shared.managedContext.fetch(fetchRequest)
            guard let generalSetting = generalSetting as? [General_Setting] else { return nil }
            return generalSetting.first
        } catch let error as NSError {
            print("Could not fetch. categories \(error), \(error.userInfo)")
        }
        return nil
    }
}

// Customize Focus Schedule
extension DBManager {
    func createPreSchedule(data: [String: Any?]) {
        let entity = NSEntityDescription.entity(forEntityName: "Focus_Schedule", in: DBManager.shared.managedContext)!
        let focus_schedule = NSManagedObject(entity: entity, insertInto: DBManager.shared.managedContext)

        for (key, value) in data {
            focus_schedule.setValue(value, forKeyPath: key)
        }

        let extend: [String: Any?] = ["is_extend_very_short": false, "is_extend_short": false, "is_extend_mid": false, "is_extend_long": false]
        let objSCE = Schedule_Focus_Extend(context: DBManager.shared.managedContext)

        for (key, value) in extend {
            objSCE.setValue(value, forKeyPath: key)
        }
        (focus_schedule as? Focus_Schedule)?.extend_info = objSCE

        do {
            try DBManager.shared.managedContext.save()
        } catch let error as NSError {
            print("Could not save category. \(error), \(error.userInfo)")
        }
    }

    func getFocusSchedule() -> [Focus_Schedule] {
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Focus_Schedule")
        do {
            let focusSchedule = try DBManager.shared.managedContext.fetch(fetchRequest)
            guard let focusSchedules = focusSchedule as? [Focus_Schedule] else { return [] }
            return focusSchedules
        } catch let error as NSError {
            print("Could not fetch. categories \(error), \(error.userInfo)")
        }
        return []
    }

    func getScheduleFocus(id: UUID) -> Focus_Schedule? {
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Focus_Schedule")
        fetchRequest.predicate = NSPredicate(format: "id = %@", id as CVarArg)

        do {
            let focusSchedule = try DBManager.shared.managedContext.fetch(fetchRequest)
            guard let focusSchedules = focusSchedule as? [Focus_Schedule] else { return nil }
            return focusSchedules.first
        } catch let error as NSError {
            print("Could not fetch. SF \(error), \(error.userInfo)")
        }
        return nil
    }
}

extension DBManager {
    func checkAvailablReminder(day: Int, time: String, type: ScheduleType) -> (isPresent: Bool, objFS: Focus_Schedule?) {
        let timeV = time.replacingOccurrences(of: ":00", with: "")
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Focus_Schedule")
        fetchRequest.predicate = NSPredicate(format: "ANY days_.day = %d && start_time = %@ && type = %d && is_active = true", day, timeV, type.rawValue)
        do {
            let results = try DBManager.shared.managedContext.fetch(fetchRequest)
            if results.count > 0 {
                let objFS = results.first as? Focus_Schedule
                return (true, objFS)
            } else {
                return (false, nil)
            }
        } catch let error {
            print("Could not Check data. Focus_Schedule \(error), \(error.localizedDescription)")
            return (false, nil)
        }
    }

    func getScheduleFocus(time: String, day: Int?) -> [Focus_Schedule] {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Focus_Schedule")
        if day == nil {
            fetchRequest.predicate = NSPredicate(format: "start_time = %@", time)
        } else {
            guard let day = day else { return [] }
            if time.isEmpty || time == "" {
                fetchRequest.predicate = NSPredicate(format: "ANY days_.day = %d", day)
            } else {
                fetchRequest.predicate = NSPredicate(format: "start_time = %@ && ANY days_.day = %d", time, day)
            }
        }

        do {
            let results = try DBManager.shared.managedContext.fetch(fetchRequest)
            if results.count > 0 {
                let arrFS = results as! [Focus_Schedule]
                return arrFS
            } else {
                return []
            }
        } catch let error {
            print("Could not Check data. Focus_Schedule \(error), \(error.localizedDescription)")
            return []
        }
    }

    func checkForTwoScheduleSession(s_time: Date, e_time: Date, day: [Int], id: UUID) -> Bool {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Focus_Schedule")

        let start_end_predict = NSPredicate(format: "(start_time_ = %@ && end_time_ <= %@ && end_time_ >= %@)", s_time as CVarArg, e_time as CVarArg, e_time as CVarArg)
        let day_predict = NSPredicate(format: "id != %@ && ANY days_.day IN %@", id as CVarArg, day)

        fetchRequest.predicate = NSCompoundPredicate(type: .and, subpredicates: [start_end_predict, day_predict])

        print("Predicate Compound  :::: \(fetchRequest.predicate)")

        do {
            let results = try DBManager.shared.managedContext.fetch(fetchRequest)
            if results.count > 2 {
                return true
            } else {
                return false
            }
        } catch let error {
            print("Could not Check data. Focus_Schedule \(error), \(error.localizedDescription)")
            return false
        }
    }

    func checkScheduleSession(s_time: Date, e_time: Date, day: [Int], id: UUID) -> Bool {
        let twoSessionResult = checkForTwoScheduleSession(s_time: s_time, e_time: e_time, day: day, id: id)
        return twoSessionResult
//        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Focus_Schedule")
        ////        let start_end_predicate = NSPredicate(format: "(start_time_ = %@ && end_time_ < %@ && end_time_ > %@)", s_time as CVarArg, e_time as CVarArg, e_time as CVarArg)
//        let end_predict = NSPredicate(format: "(end_time_ >= %@ || end_time_ <= %@)", s_time as CVarArg, s_time as CVarArg)
//        let start_predict = NSPredicate(format: "(start_time_ >= %@ || start_time_ <= %@)", e_time as CVarArg, e_time as CVarArg)
//        let orCondition = NSCompoundPredicate(type: .or, subpredicates: [end_predict, start_predict])
//        let day_predict = NSPredicate(format: "id != %@ && ANY days_.day IN %@", id as CVarArg, day)
//        fetchRequest.predicate = NSCompoundPredicate(type: .and, subpredicates: [orCondition, day_predict])
//
//        print("Predicate Compound  :::: \(fetchRequest.predicate)")
//
//        do {
//            let results = try DBManager.shared.managedContext.fetch(fetchRequest)
//            if results.count > 0 {
//                return true
//            } else {
//                return twoSessionResult
//            }
//        } catch let error {
//            print("Could not Check data. Focus_Schedule \(error), \(error.localizedDescription)")
//            return twoSessionResult
//        }
    }
}

extension DBManager {
    func truncateTable(name: String) {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: name)
        if let result = try? DBManager.shared.managedContext.fetch(fetchRequest) {
            for object in result {
                DBManager.shared.managedContext.delete(object as! NSManagedObject)
            }
        }
        do {
            try DBManager.shared.managedContext.save()
            print("saved")
        } catch let error as NSError {
            print("Could not save \(error), \(error.userInfo)")
        }
    }

    func deleteObject(name: String, predicate: NSPredicate?) {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: name)
        if predicate != nil {
            fetchRequest.predicate = predicate
        }
        if let result = try? DBManager.shared.managedContext.fetch(fetchRequest) {
            for object in result {
                DBManager.shared.managedContext.delete(object as! NSManagedObject)
            }
        }
        do {
            try DBManager.shared.managedContext.save()
            print("saved")
        } catch let error as NSError {
            print("Could not save \(error), \(error.userInfo)")
        }
    }
}

// Save Context
extension DBManager {
    func saveContext() {
        do {
            try DBManager.shared.managedContext.save()
        } catch let error as NSError {
            print("Update the context \(error), \(error.userInfo)")
        }
    }
}
