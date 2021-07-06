//
//  SchedulerViewC.swift
//  Focus
//
//  Created by Bhavi on 29/06/21.
//

import Cocoa

class SchedulerViewC: BaseViewController {

    
    override func headerTitle() -> String { return SettingOptions.schedule_setting.title }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        savedDefaultHeight = view.bounds.height
    }
    
}
