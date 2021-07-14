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

class CustomSettingController: NSViewController, ItemHostSV {
    @IBOutlet var topView: NSView!
    @IBOutlet var btnClose: NSButton!
    @IBOutlet var lblTitle: NSTextField!
    @IBOutlet var scrollView: NSScrollView!

    @IBOutlet var containerView: NSView!

    @IBOutlet var stackView: CustomStackView!

    var customSV: CustomStackView?

    override func viewDidLoad() {
        super.viewDidLoad()
        setUpText()
        setUpViews()
        bindData()
    }

    override func viewDidLayout() {
        super.viewDidLayout()
        scrollView.needsLayout = true
        scrollView.needsDisplay = true
    }
}

extension CustomSettingController: BasicSetupType {
    func setUpText() {
        lblTitle.stringValue = "Cutomize Settings"
    }

    func setUpViews() {
        setupCollapseExpandViewC(SettingOptions.general_setting) // set controller's identifier which is set in storyboard
        setupCollapseExpandViewC(SettingOptions.block_setting)
        setupCollapseExpandViewC(SettingOptions.schedule_setting)
    }

    func bindData() {
        btnClose.target = self
        btnClose.action = #selector(closeWindow)
    }

    @objc func closeWindow() {
        if presentingViewController != nil {
            presentingViewController?.dismiss(self)
        } else {
            view.window?.close()
        }
    }
}

extension CustomSettingController {
    private func setupCollapseExpandViewC(_ settingOption: SettingOptions) {
        let storyboard = NSStoryboard(name: "CustomSetting", bundle: nil)
        guard let viewController = storyboard.instantiateController(withIdentifier: settingOption.identifier) as? BaseViewController else { return }

        let containerView = viewController.headerContinerV!

        containerView.header.disclose = {
            self.disclose(containerView)
            // self.closeOtherController(containerView)
        }
        stackView.addArrangedSubview(containerView.header.viewController.view)
        stackView.addArrangedSubview(containerView.body.viewController.view)
        stackView.continerViews.append(containerView)
        hide(containerView, animated: false)
    }

    func closeOtherController(_ containerView: ItemContainerS) {
        // One issue when tap on same button then it should be off not on
        for view in stackView.continerViews {
            guard let containerViewC = view else { return }
            containerViewC.state = .on
            disclose(containerViewC)
        }
        disclose(containerView)
    }
}
