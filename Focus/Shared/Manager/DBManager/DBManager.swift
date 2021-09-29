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
    static let managedContext = DataController.shared.persistentContainer.viewContext
}

// Block List
extension DBManager: DBMangerLogic {
//    func saveBlock(data: [String: Any?]) {
//        let entity = NSEntityDescription.entity(forEntityName: "Override_Block", in: DBManager.managedContext)!
//        let block = NSManagedObject(entity: entity, insertInto: DBManager.managedContext)
//
//        for (key, value) in data {
//            block.setValue(value, forKeyPath: key)
//        }
//
//        do {
//            try DBManager.managedContext.save()
//        } catch let error as NSError {
//            print("Could not save. \(error), \(error.userInfo)")
//        }
//    }

    func getCurrentBlockList() -> (objFocus: Focuses?, objBl: Block_List?, apps: [Block_Interface], webs: [Block_Interface]) {
        guard let objFocus = getCurrentSession() else { return (nil, nil, [], []) }

        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Block_List")
        fetchRequest.predicate = NSPredicate(format: "id = %@", objFocus.block_list_id! as CVarArg)

        do {
            let block = try DBManager.managedContext.fetch(fetchRequest)

            guard let blocks = (block as? [Block_List])?.first else { return (objFocus, nil, [], []) }

            guard let arrBlocks = blocks.block_app_web?.allObjects as? [Block_Interface] else { return (objFocus, blocks, [], []) }
            if let arrExceBlocks = blocks.exception_block?.allObjects as? [Block_Interface] {
                
                //Category list here or merge into applist and weblist
                
                let applist = arrBlocks.filter { obj in
                    arrExceBlocks.contains { objEx in
                        objEx.app_identifier != obj.app_identifier
                    }
                }

                let weblist = arrBlocks.filter { obj in
                    arrExceBlocks.contains { objEx in
                        objEx.name != obj.name
                    }
                }

                return (objFocus, blocks, applist, weblist)
            }
            return (objFocus, blocks, arrBlocks, [])
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
        return (objFocus, nil, [], [])
    }
}

// Focus Create
extension DBManager {
    func createFocus(data: [String: Any]) {
        let entity = NSEntityDescription.entity(forEntityName: Focus.entity_name, in: DBManager.managedContext)!
        let block = NSManagedObject(entity: entity, insertInto: DBManager.managedContext)

        for (key, value) in data {
            block.setValue(value, forKeyPath: key)
        }

        do {
            try DBManager.managedContext.save()
        } catch let error as NSError {
            print("Could not save focus. \(error), \(error.userInfo)")
        }
    }

    func getFoucsObject() -> Focuses? {
        var focusObj: Focuses?
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: Focus.entity_name)
//        fetchRequest.predicate = NSPredicate(format: "is_focusing = true")

        do {
            let results = try DBManager.managedContext.fetch(fetchRequest)
            if results.count > 0 {
                focusObj = results.first as? Focuses
            } else {
                focusObj = Focuses(context: DBManager.managedContext)
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
            let results = try DBManager.managedContext.fetch(fetchRequest)
            if results.count > 0 {
                focusObj = results.first as? Focuses
            }
        } catch let error {
            print(error.localizedDescription)
        }
        return focusObj
    }

    func saveApplicationlist(data: [String: Any]) {
        let entity = NSEntityDescription.entity(forEntityName: "Application_List", in: DBManager.managedContext)!
        let block = NSManagedObject(entity: entity, insertInto: DBManager.managedContext)

        for (key, value) in data {
            block.setValue(value, forKeyPath: key)
        }

        do {
            try DBManager.managedContext.save()
        } catch let error as NSError {
            print("Could not save focus. \(error), \(error.userInfo)")
        }
    }

    func getApplicationList() -> [Application_List] {
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Application_List")
        fetchRequest.sortDescriptors = [NSSortDescriptor(keyPath: \Application_List.created_at, ascending: false)]

        do {
            let block = try DBManager.managedContext.fetch(fetchRequest)
            guard let applications = block as? [Application_List] else { return [] }
            return applications
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }

        return []
    }
}

// MARK: Block list Store and Fetch

extension DBManager {
    func saveBlocklist(data: [String: Any?]) {
        let entity = NSEntityDescription.entity(forEntityName: "Block_List", in: DBManager.managedContext)!
        let category = NSManagedObject(entity: entity, insertInto: DBManager.managedContext)

        for (key, value) in data {
            category.setValue(value, forKeyPath: key)
        }

        do {
            try DBManager.managedContext.save()
        } catch let error as NSError {
            print("Could not save category. \(error), \(error.userInfo)")
        }
    }

    func getBlockList() -> [Block_List] {
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Block_List")
        fetchRequest.sortDescriptors = [NSSortDescriptor(keyPath: \Block_List.created_at, ascending: false)]
        do {
            let block = try DBManager.managedContext.fetch(fetchRequest)
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
    func checkDataIsPresent() -> Bool {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Block_Category")
        do {
            let results = try DBManager.managedContext.fetch(fetchRequest)
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

    func saveCategory(data: [String: Any?], type: CategoryType) {
        let entity = NSEntityDescription.entity(forEntityName: "Block_Category", in: DBManager.managedContext)!
        let category = NSManagedObject(entity: entity, insertInto: DBManager.managedContext)

        for (key, value) in data {
            category.setValue(value, forKeyPath: key)
        }

        if type == .general {
            let setting_data: [String: Any?] = ["warning_before_schedule_session_start": true, "provide_short_break_schedule_session": false, "block_screen_first_min_each_break": false, "show_count_down_for_break_start_end": false, "break_time": 5, "for_every_time": 15]
            let objGS = General_Settings(context: DBManager.managedContext)
            for (key, value) in setting_data {
                objGS.setValue(value, forKeyPath: key)
            }
            (category as? Block_Category)?.general_setting = objGS
        }

        do {
            try DBManager.managedContext.save()
        } catch let error as NSError {
            print("Could not save category. \(error), \(error.userInfo)")
        }
    }

    func getCategories() -> [Block_Category] {
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Block_Category")
        fetchRequest.sortDescriptors = [NSSortDescriptor(keyPath: \Block_Category.created_at, ascending: false)]
        fetchRequest.predicate = NSPredicate(format: "type = %d", CategoryType.system.rawValue)

        do {
            let block = try DBManager.managedContext.fetch(fetchRequest)
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
            let categories = try DBManager.managedContext.fetch(fetchRequest)
            guard let category = categories.first as? Block_Category else { return (nil, []) }
            return (category, category.sub_data?.allObjects as! [Block_SubCategory])
        } catch let error as NSError {
            print("Could not General Cat fetch. \(error), \(error.userInfo)")
        }
        return (nil, [])
    }
}

// Save Context
extension DBManager {
    func saveContext() {
        do {
            try DBManager.managedContext.save()
        } catch let error as NSError {
            print("Update the context \(error), \(error.userInfo)")
        }
    }
}
