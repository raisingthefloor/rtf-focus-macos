//
//  CustomSplitViewController.swift
//  Focus
//
//  Created by Bhavi on 08/09/21.
//  Copyright © 2021 Raising the Floor. All rights reserved.
//

import Cocoa
import Foundation

final class CustomSplitViewController: NSSplitViewController {
    private func patch() {
        let v = NSSplitView()
        v.isVertical = true
        v.dividerStyle = .thin
        splitView = v
        splitViewItems = [
            NSSplitViewItem(viewController: NSTabViewController()),
            NSSplitViewItem(viewController: NSTabViewController()),
        ]
    }

    override init(nibName nibNameOrNil: NSNib.Name?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        patch()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        patch()
    }
}
