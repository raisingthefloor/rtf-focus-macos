//
//  LeftMenuView.swift
//  Focus
//
//  Created by Bhavi on 08/09/21.
//  Copyright © 2021 Raising the Floor. All rights reserved.
//

import Cocoa

class LeftMenuView: NSViewController {
    let settings = ["General Settings", "", "", ""]

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }
}

extension LeftMenuView: NSTableViewDataSource {
    // MARK: - NSTableViewDataSource

    func numberOfRows(in tableView: NSTableView) -> Int {
        return SettingOptions.setting_options.count
    }

    func tableView(_ tableView: NSTableView, objectValueFor tableColumn: NSTableColumn?, row: Int) -> Any? {
        return SettingOptions.setting_options[row].title
    }
}
