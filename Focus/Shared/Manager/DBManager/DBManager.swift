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
        fetchRequest.predicate = NSPredicate(format: "path BEGINSWITH[cd] '/Application' || path BEGINSWITH[cd] '/System/Applications/'")
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

    func saveCategory(data: [String: Any?], type: CategoryType) {
        let entity = NSEntityDescription.entity(forEntityName: "Block_Category", in: DBManager.shared.managedContext)!
        let category = NSManagedObject(entity: entity, insertInto: DBManager.shared.managedContext)

        for (key, value) in data {
            category.setValue(value, forKeyPath: key)
        }

        let sub_data = [["name": "Messages", "app_identifier": "com.apple.MobileSMS", "app_icon_path": "/System/Applications/Messages.app", "created_at": Date(), "block_type": BlockType.application.rawValue], ["name": "www.instagram.com", "url": "www.instagram.com", "created_at": Date(), "block_type": BlockType.web.rawValue]]

        var arrSD: [Block_SubCategory] = []
        for val in sub_data {
            let objSC = Block_SubCategory(context: DBManager.shared.managedContext)

            for (key, value) in val {
                objSC.setValue(value, forKeyPath: key)
            }
            arrSD.append(objSC)
        }
        (category as? Block_Category)?.sub_data = NSSet(array: arrSD)

        if type == .general {
            let setting_data: [String: Any?] = ["warning_before_schedule_session_start": false, "provide_short_break_schedule_session": false, "block_screen_first_min_each_break": false, "show_count_down_for_break_start_end": false, "break_time": Focus.BreakTime.five.valueInSeconds, "for_every_time": Focus.FocusTime.fifteen.valueInSeconds]

            let objGS = General_Settings(context: DBManager.shared.managedContext)
            for (key, value) in setting_data {
                objGS.setValue(value, forKeyPath: key)
            }
            (category as? Block_Category)?.general_setting = objGS
        }

        do {
            try DBManager.shared.managedContext.save()
        } catch let error as NSError {
            print("Could not save category. \(error), \(error.userInfo)")
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

    func getGeneralCategoryData() -> (gCat: Block_Category?, subCat: [Block_SubCategory]) {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Block_Category")
        fetchRequest.predicate = NSPredicate(format: "type = %d", CategoryType.general.rawValue)
        do {
            let categories = try DBManager.shared.managedContext.fetch(fetchRequest)
            guard let category = categories.first as? Block_Category else { return (nil, []) }
            return (category, category.sub_data?.allObjects as! [Block_SubCategory])
        } catch let error as NSError {
            print("Could not General Cat fetch. \(error), \(error.userInfo)")
        }
        return (nil, [])
    }

    func getCategoryData(ids: [UUID]) -> [Block_SubCategory] {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Block_Category")
        fetchRequest.predicate = NSPredicate(format: "ANY id IN %@", ids)
        do {
            let categories = try DBManager.shared.managedContext.fetch(fetchRequest)
            guard let category = categories as? [Block_Category] else { return [] }

            let arrData = category.compactMap({ $0.sub_data?.allObjects })
            return arrData.joined().compactMap({ $0 as? Block_SubCategory })
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
    func checkAvailablReminder(day: String, time: String, type: ScheduleType) -> (Bool, Focus_Schedule?) {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Focus_Schedule")
        fetchRequest.predicate = NSPredicate(format: "days CONTAINS[c] %@ && start_time = %@ && type = %d && is_active = true", day, time, type.rawValue)

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
