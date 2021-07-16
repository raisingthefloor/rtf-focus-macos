//
//  BlockModel.swift
//  Focus
//
//  Created by Bhavi on 16/07/21.
//  Copyright © 2021 Raising the Floor. All rights reserved.
//

import Cocoa
import Foundation

enum BlockType: Int {
    case application
    case web

    var title: String {
        switch self {
        case .application:
            return "Add App"
        case .web:
            return "Add Website"
        }
    }
}
