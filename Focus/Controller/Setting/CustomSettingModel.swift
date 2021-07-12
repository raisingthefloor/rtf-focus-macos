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

import Foundation

enum SettingOptions: Int, CaseIterable {
    case general_setting
    case block_setting
    case schedule_setting

    var title: String {
        switch self {
        case .general_setting:
            return "General Settings".uppercased().l10n()
        case .block_setting:
            return "Blocklists".uppercased().l10n() + " (view & edit)".l10n()
        case .schedule_setting:
            return "Scheduler".uppercased().l10n() + " (view, edit & activate)".l10n()
        }
    }

    var identifier: String {
        switch self {
        case .general_setting:
            return "GeneralSettingView"
        case .block_setting:
            return "BlockListView"
        case .schedule_setting:
            return "SchedulerView"
        }
    }
}
