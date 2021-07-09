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
import RxCocoa
import RxSwift

class CustomSettingController: BaseViewController, ItemHostSV {
    @IBOutlet var topView: NSView!
    @IBOutlet var btnClose: NSButton!
    @IBOutlet var btnTitle: NSButton!
    @IBOutlet var scrollView: NSScrollView!

    @IBOutlet var containerView: NSView!

    @IBOutlet var stackView: CustomStackView!

    override func viewDidLoad() {
        super.viewDidLoad()
        setUpText()
        setUpViews()
        bindData()
    }
}

extension CustomSettingController: BasicSetupType {
    func setUpText() {
        btnTitle.title = "  Cutomize Settings".l10n()
    }

    func setUpViews() {
        setupCollapseExpandViewC("GeneralSettingView") //set controller's identifier which is set in storyboard
        setupCollapseExpandViewC("BlockListView")
        setupCollapseExpandViewC("SchedulerView")
    }

    func bindData() {
        btnClose.rx.tap.subscribe(onNext: { [weak self] _ in
            guard let self = self else { return }
            if self.presentingViewController != nil {
                self.presentingViewController?.dismiss(self)
            } else {
                self.view.window?.close()
            }
        }).disposed(by: disposeBag)
    }
}

extension CustomSettingController {
    private func setupCollapseExpandViewC(_ identifier: String) {
        let storyboard = NSStoryboard(name: "CustomSetting", bundle: nil)
        guard let viewController = storyboard.instantiateController(withIdentifier: identifier) as? BaseViewController else { return }

        let containerView = viewController.headerContinerV!

        containerView.header.disclose = {
            self.disclose(viewController.headerContinerV!)
        }
        stackView.addArrangedSubview(containerView.header.viewController.view)
        stackView.addArrangedSubview(containerView.body.viewController.view)
        hide(containerView, animated: false)
    }
}
