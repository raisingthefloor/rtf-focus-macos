//
//  CustomSettingController.swift
//  Focus
//
//  Created by Bhavi on 23/06/21.
//

import Cocoa
import RxCocoa
import RxSwift

class CustomSettingController: BaseViewController, StackItemHost {
    @IBOutlet var topView: NSView!
    @IBOutlet var btnClose: NSButton!
    @IBOutlet var btnTitle: NSButton!
    @IBOutlet weak var scrollView: NSScrollView!
    
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
        addViewController(withIdentifier: "GeneralSettingView")
        addViewController(withIdentifier: "BlockListView")
        addViewController(withIdentifier: "SchedulerView")
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
    /// - Tag: Configure
    /// Used to add a particular view controller as an item to the stack view.
    private func addViewController(withIdentifier identifier: String) {
        let storyboard = NSStoryboard(name: "CustomSetting", bundle: nil)
        guard let viewController = storyboard.instantiateController(withIdentifier: identifier) as? BaseViewController else { return }

        // Set up the view controller's item container.
        let stackItemContainer = viewController.stackItemContainer!

        // Set the appropriate action function for toggling the disclosure state of each header.
        stackItemContainer.header.disclose = {
            self.disclose(viewController.stackItemContainer!)
        }

        // Add the header view.
        stackView.addArrangedSubview(stackItemContainer.header.viewController.view)
        // Add the main body content view.
        stackView.addArrangedSubview(stackItemContainer.body.viewController.view)

        // Set the default disclosure states (state restoration may restore them to their requested value).
        hide(stackItemContainer, animated: false)
    }
}
