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

protocol BlockListViewModelIntput {
    func getBlockList() -> ([BlockCategory], [Override_Block], [Override_Block])
    func storeOverridesBlock(data: [String: Any?], callback: @escaping (([Override_Block]) -> Void))
}

protocol BlockListViewModelOutput {
}

protocol BlockListViewModelType {
    var input: BlockListViewModelIntput { get }
    var output: BlockListViewModelOutput { get }
}

class BlockListViewModel: BlockListViewModelIntput, BlockListViewModelOutput, BlockListViewModelType {
    var input: BlockListViewModelIntput { return self }
    var output: BlockListViewModelOutput { return self }

    let blockNames: [String] = ["Calls", "Notification (Turn DND on)", "Social Media", "Games", "News", "Shopping", "Projects", "Medical"]
    let childeren: [String] = ["Facebook", "Intagram", "LinkedIn"]

    func getBlockList() -> ([BlockCategory], [Override_Block], [Override_Block]) {
        var blockCategories: [BlockCategory] = []

        for i in 0 ..< blockNames.count {
            var childrenBlock: [BlockData] = []
            if (i % 2) != 0 {
                for i in 0 ..< childeren.count {
                    let block = BlockData(id: i, name: childeren[i])
                    childrenBlock.append(block)
                }
            }

            let block = BlockCategory(id: i, name: blockNames[i], childeren: childrenBlock)
            blockCategories.append(block)
        }
        let override_bloks = DBManager.shared.getBlockList()
        return (blockCategories, override_bloks, override_bloks)
    }

    func storeOverridesBlock(data: [String: Any?], callback: @escaping (([Override_Block]) -> Void)) {
        DBManager.shared.saveBlock(data: data)
        let override_bloks = DBManager.shared.getBlockList()
        callback(override_bloks)
    }
}

struct BlockCategory {
    var id: Int?
    var name: String?
    var childeren: [BlockData?]
}

struct BlockData {
    var id: Int?
    var name: String?
}
