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

extension DBManager: DBMangerLogic {
    func saveBlock(data: [String: Any]) {
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
}
