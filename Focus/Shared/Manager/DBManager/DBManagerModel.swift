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

protocol DBMangerLogic {
    var managedContext: NSManagedObjectContext { get set }
    func createFocus(data: [String: Any]) // Not Used
    func getFoucsObject() -> Focuses?
    func getCurrentSession() -> Focuses?
    func getCurrentBlockList() -> (objFocus: Focuses?, objBl: Block_List?, apps: [Block_Interface], webs: [Block_Interface])

    func saveApplicationlist(data: [String: Any])
    func getApplicationList() -> [Application_List]
    func checkAppsIsPresent(bundle_id: String) -> Bool

    func systemPreAddedBlocklist()
    func checkAppWebIsPresent(entityName: String, name: String?) -> Bool
    func saveBlocklist(data: [String: Any?])
    func getBlockList() -> [Block_List]

    func checkDataIsPresent(entityName: String) -> Bool
    func getCategories() -> [Block_Category]
    func saveCategory(data: [String: Any?], type: CategoryType, cat: Categories)
    func getCategoryBy(name: String) -> Block_Category?

    func getGeneralCategoryData() -> (gCat: Block_Category?, subCat: [Block_SubCategory])

    func getGeneralSetting() -> General_Setting?

    func createPreSchedule(data: [String: Any?])
    func getFocusSchedule() -> [Focus_Schedule]
    func getScheduleFocus(id: UUID) -> Focus_Schedule?
    func checkAvailablReminder(day: String, time: String, type: ScheduleType) -> (Bool, Focus_Schedule?)

    func getScheduleFocus(time: String, day: Int?) -> [Focus_Schedule]
    func checkScheduleSession(time: String, day: Int) -> Bool

    func truncateTable(name: String)
    func deleteObject(name: String, predicate: NSPredicate?)

    func saveContext()
}
