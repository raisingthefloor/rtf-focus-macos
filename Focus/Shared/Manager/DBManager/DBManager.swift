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
    let managedContext = DataController.shared.persistentContainer.viewContext
}

// Block List
extension DBManager: DBMangerLogic {
    func saveBlock(data: [String: Any?]) {
        let entity = NSEntityDescription.entity(forEntityName: "Override_Block", in: managedContext)!
        let block = NSManagedObject(entity: entity, insertInto: managedContext)

        for (key, value) in data {
            block.setValue(value, forKeyPath: key)
        }

        do {
            try managedContext.save()
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
    }

    func getBlockList() -> [Override_Block] {
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Override_Block")
        do {
            let block = try managedContext.fetch(fetchRequest)
            guard let overriedBlocks = block as? [Override_Block] else { return [] }
            return overriedBlocks
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }

        return []
    }

    func getActiveBlockList() -> [Override_Block] {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Override_Block")
        fetchRequest.predicate = NSPredicate(format: "is_selected = true")
        do {
            let block = try managedContext.fetch(fetchRequest)
            guard let overriedBlocks = block as? [Override_Block] else { return [] }
            return overriedBlocks
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
        return []
    }
}

// Focus Create
extension DBManager {
    func createFocus(data: [String: Any]) {
        let entity = NSEntityDescription.entity(forEntityName: Focus.entity_name, in: managedContext)!
        let block = NSManagedObject(entity: entity, insertInto: managedContext)

        for (key, value) in data {
            block.setValue(value, forKeyPath: key)
        }

        do {
            try managedContext.save()
        } catch let error as NSError {
            print("Could not save focus. \(error), \(error.userInfo)")
        }
    }

    func getFoucsObject() -> Focuses? {
        var focusObj: Focuses?
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: Focus.entity_name)
        fetchRequest.predicate = NSPredicate(format: "is_focusing = true")

        do {
            let results = try managedContext.fetch(fetchRequest)
            if results.count > 0 {
                focusObj = results.first as? Focuses
            } else {
                focusObj = Focuses(context: managedContext)
            }
        } catch let error {
            print(error.localizedDescription)
        }
        return focusObj
    }

    func saveApplicationlist(data: [String: Any]) {
        let entity = NSEntityDescription.entity(forEntityName: "Application_List", in: managedContext)!
        let block = NSManagedObject(entity: entity, insertInto: managedContext)

        for (key, value) in data {
            block.setValue(value, forKeyPath: key)
        }

        do {
            try managedContext.save()
        } catch let error as NSError {
            print("Could not save focus. \(error), \(error.userInfo)")
        }
    }

    func getApplicationList() -> [Application_List] {
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Application_List")
        do {
            let block = try managedContext.fetch(fetchRequest)
            guard let applications = block as? [Application_List] else { return [] }
            return applications
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }

        return []
    }
}

// Save Context
extension DBManager {
    func saveContext() {
        do {
            try managedContext.save()
        } catch let error as NSError {
            print("Update the context \(error), \(error.userInfo)")
        }
    }
}
