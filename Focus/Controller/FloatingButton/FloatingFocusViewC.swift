//
//  FloatingFocusViewC.swift
//  Focus
//
//  Created by Bhavi on 28/07/21.
//  Copyright © 2021 Raising the Floor. All rights reserved.
//

import Cocoa

class FloatingFocusViewC: NSViewController {
    @IBOutlet var btnFocus: CustomButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        setUpText()
        setUpViews()
        bindData()
    }
}

extension FloatingFocusViewC: BasicSetupType {
    func setUpText() {
        btnFocus.title = NSLocalizedString("Button.Focus", comment: "Focus")
    }

    func setUpViews() {
    }

    func bindData() {
        btnFocus.target = self
        btnFocus.action = #selector(openMenuViewC)
    }

    @objc func openMenuViewC() {
        if let vc = WindowsManager.getVC(withIdentifier: "sidMenuController", ofType: MenuController.self) {
            let window: NSWindow = {
                let w = NSWindow(contentViewController: vc)
                w.styleMask.remove(.fullScreen)
                w.styleMask.remove(.resizable)
                w.styleMask.remove(.miniaturizable)
                w.level = .floating
                return w
            }()
            
            self.presentAsModalWindow(vc)
        }
    }
}
