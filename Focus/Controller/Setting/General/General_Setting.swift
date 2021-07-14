//
//  General_Setting.swift
//  Focus
//
//  Created by Bhavi on 13/07/21.
//  Copyright © 2021 Raising the Floor. All rights reserved.
//

import Foundation

struct Behavior_Focus {
    
    var title: String?
    var sub_title: String?
    var is_checked: Bool
    var allowed_block: [Allowed_Block]
}

struct Allowed_Block {
    var name: String?
    var is_checked: Bool
    var created_date: Date?
}


