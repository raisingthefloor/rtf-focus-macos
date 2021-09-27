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

class FloatingFocusViewC: NSViewController {
    @IBOutlet var btnFocus: CustomButton!
    let viewModel: MenuViewModelType = MenuViewModel()

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
        // If in GS Coundt down is on then show timer It appears below button else 
        // If focus is running then Show "FOCUS"
        // If Break mode is on then Show "BREAK"
        
        guard let obj = viewModel.input.focusObj else { return }
        if obj.is_focusing {            
            btnFocus.buttonColor = Color.very_light_grey
            btnFocus.activeButtonColor = Color.very_light_grey
            btnFocus.textColor = Color.black_color
            btnFocus.borderColor = Color.dark_grey_border
            btnFocus.borderWidth = 0.6
        } else {
            btnFocus.buttonColor = Color.green_color
            btnFocus.activeButtonColor = Color.green_color
            btnFocus.textColor = .white
        }
    }

    func bindData() {
        btnFocus.target = self
        btnFocus.action = #selector(openMenuViewC)
    }

    @objc func openMenuViewC() {
        guard let obj = viewModel.input.focusObj else { return }

        if obj.is_focusing {
            if let vc = WindowsManager.getVC(withIdentifier: "sidCurrentController", ofType: CurrentSessionVC.self) {
                presentAsModalWindow(vc)
            }
        } else {
            if let vc = WindowsManager.getVC(withIdentifier: "sidMenuController", ofType: MenuController.self) {
                presentAsModalWindow(vc)
            }
        }

//        DispatchQueue.main.async {
//            appDelegate?.browserBridge?.stopScript()
//        }
    }
}
