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

enum ListDialogue: Int {
    case category_list
    case unblocking_list
    case system_app_list

    var title: String {
        switch self {
        case .category_list:
            return NSLocalizedString("List.category.title", comment: "Apps and websites blocked by the category:")
        case .unblocking_list:
            return NSLocalizedString("List.unblocking_list.title", comment: "Select apps and websites from your blocklists to allow yourself to temporarily unblock.")
        case .system_app_list:
            return NSLocalizedString("List.system_app_list.title", comment: "Select apps from your system app list to allow yourself to block.")
        }
    }

    var add_button_title: String {
        switch self {
        case .category_list:
            return NSLocalizedString("Button.ok", comment: "OK").uppercased()
        case .unblocking_list, .system_app_list:
            return NSLocalizedString("List.add_item", comment: "Add items")
        }
    }

    var font: NSFont {
        switch self {
        case .category_list:
            return NSFont.systemFont(ofSize: 18, weight: .regular)
        case .unblocking_list, .system_app_list:
            return NSFont.systemFont(ofSize: 12, weight: .semibold)
        }
    }

    var isCheckboxVisible: Bool {
        switch self {
        case .category_list:
            return false
        default:
            return true
        }
    }

    var isIconVisible: Bool {
        switch self {
        case .category_list:
            return false
        default:
            return true
        }
    }

    var arrData: [Any] {
        switch self {
        case .category_list:
            return ["www.facebook.com", "www.classmates.com", "www.linkedin.com"]
        case .system_app_list, .unblocking_list:
            return DBManager.shared.getApplicationList()
        }
    }

    var selectedData: [Any] {
        switch self {
        case .category_list:
            return ["www. facebook.com"]
        case .system_app_list, .unblocking_list:
            guard var selectedVal = arrData as? [Application_List] else { return [] }
            selectedVal = selectedVal.filter({ $0.is_selected }).compactMap({ $0 })
            if !selectedVal.isEmpty {
                var storeData: [[String: Any?]] = []
                for val in selectedVal {
                    let data: [String: Any?] = ["url": val.path, "name": val.name, "created_at": Date(), "is_selected": false, "is_deleted": false, "block_type": BlockType.application.rawValue, "id": UUID(), "app_identifier": val.bundle_id, "app_icon_path": val.path]
                    storeData.append(data)
                }
                return storeData
            }
            return []
        }
    }

    var resetSelection: Void {
        guard var selectedVal = arrData as? [Application_List] else { return }
        selectedVal = selectedVal.filter({ $0.is_selected }).compactMap({ $0 })
        _ = selectedVal.map({ $0.is_selected = false })
        DBManager.shared.saveContext()
        return
    }
}
