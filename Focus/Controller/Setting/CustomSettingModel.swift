//
//  CustomSettingModel.swift
//  Focus
//
//  Created by Bhavi on 29/06/21.
//

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
}
