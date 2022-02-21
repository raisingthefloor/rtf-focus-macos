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

enum InputDialogue: Int {
    case add_block_list_name
    case add_website

    var title: String {
        switch self {
        case .add_block_list_name:
            return NSLocalizedString("Input.add_block_list_name.title", comment: "Name blocklist:")
        case .add_website:
            return NSLocalizedString("Input.add_website.title", comment: "Type or paste a website URL:")
        }
    }

    var link: String {
        switch self {
        case .add_block_list_name:
            return ""
        case .add_website:
            return NSLocalizedString("Input.add_website.link", comment: "Opens the URL in your internet browser.")
        }
    }

    var add_button_title: String {
        switch self {
        case .add_block_list_name:
            return NSLocalizedString("Input.create_block_list", comment: "Create blocklist")
        case .add_website:
            return NSLocalizedString("Input.add_website", comment: "Add Website")
        }
    }

    var error_message: String {
        switch self {
        case .add_block_list_name:
            return NSLocalizedString("Input.add_block_list_name.error", comment: "Blocklist name is missing")
        case .add_website:
            return UrlError.empty.error
        }
    }

    /*
     Invalid URL message: “This link does not appear to work.”
     Missing URL message: “Website link is missing.”
     */

    var isTestUrlVisible: Bool {
        switch self {
        case .add_block_list_name:
            return false
        default:
            return true
        }
    }
}

enum UrlError: Int {
    case empty
    case invalid_url

    var error: String {
        switch self {
        case .empty:
            return NSLocalizedString("Input.add_website.error", comment: "URL is missing")
        case .invalid_url:
            return NSLocalizedString("Error.invalid_url", comment: "This is not a valid URL")
        }
    }
}
