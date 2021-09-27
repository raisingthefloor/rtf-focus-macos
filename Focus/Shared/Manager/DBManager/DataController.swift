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

import Cocoa
import CoreData
import Foundation

class DataController: NSObject {
    var managedObjContext: NSManagedObjectContext?

    static var shared: DataController = DataController()

    // MARK: - Core Data stack

    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "Focus")

        let dbURL = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).last!.appendingPathComponent("Focus/Focus")
        let description = NSPersistentStoreDescription(url: dbURL)
        description.shouldInferMappingModelAutomatically = true
        description.shouldMigrateStoreAutomatically = true
        description.type = NSSQLiteStoreType

        container.persistentStoreDescriptions = [description]

        container.loadPersistentStores(completionHandler: { _, error in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }

            container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
            container.viewContext.automaticallyMergesChangesFromParent = true
        })
        return container
    }()

    override init() {
    }

    // MARK: - Core Data Saving

    func saveContext() {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
}
