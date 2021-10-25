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

protocol GeneralSettingModelIntput {
    func getGeneralCategoryData() -> (gCat: Block_Category?, subCat: [Block_SubCategory])
    func addAppWebData(data: [[String: Any?]], block_type: BlockType, callback: @escaping ((Bool) -> Void))
}

protocol GeneralSettingModelOutput {
}

protocol GeneralSettingModelType {
    var input: GeneralSettingModelIntput { get }
    var output: GeneralSettingModelOutput { get }
    var objGCategory: Block_Category? { get set }
}

class GeneralSettingModel: GeneralSettingModelIntput, GeneralSettingModelOutput, GeneralSettingModelType {
    var input: GeneralSettingModelIntput { return self }
    var output: GeneralSettingModelOutput { return self }
    var objGCategory: Block_Category?

    func getGeneralCategoryData() -> (gCat: Block_Category?, subCat: [Block_SubCategory]) {
        objGCategory = DBManager.shared.getGeneralCategoryData().gCat
        let subCat = DBManager.shared.getGeneralCategoryData().subCat
        return (objGCategory, subCat)
    }

    func addAppWebData(data: [[String: Any?]], block_type: BlockType, callback: @escaping ((Bool) -> Void)) {
        var arrObj: [Block_SubCategory] = []
        var arrAppWeb = objGCategory?.sub_data?.allObjects as? [Block_SubCategory]
        arrAppWeb = arrAppWeb?.filter({ $0.block_type == block_type.rawValue })
        for val in data {
            let isNotPresent = arrAppWeb?.compactMap({ $0.name != (val["name"] as? String) }).filter({ $0 }).first ?? false
            if isNotPresent {
                let objSubWA = Block_SubCategory(context: DBManager.shared.managedContext)
                for (key, value) in val {
                    objSubWA.setValue(value, forKeyPath: key)
                }
                arrObj.append(objSubWA)
            }
        }
        arrObj = arrObj + (objGCategory?.sub_data?.allObjects as! [Block_SubCategory])
        objGCategory?.sub_data = NSSet(array: arrObj)
        DBManager.shared.saveContext()
        callback(true)
    }
}

enum General_Setting {
    case behavior_foucs
    case allow_unblocking
}

enum CategoryType: Int {
    case general
    case system
}
