/* Copyright 2020 Raising the Floor - International

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

// MARK: Protocol Delarations

// Contain both the header and body.
protocol ItemHostSV: AnyObject {
    func disclose(_ itemContainer: ItemContainerS)
}

//  header part.
protocol ItemHeader: AnyObject {
    var viewController: NSViewController { get }
    var disclose: (() -> Swift.Void)? { get set }

    func update(toDisclosureState: NSControl.StateValue)
}

// body part.
protocol ItemBody: AnyObject {
    var viewController: NSViewController { get }

    func show(animated: Bool)
    func hide(animated: Bool)
}

// MARK: - Protocol implementations

extension ItemHostSV {
    /// The action function for the disclosure button.
    func disclose(_ itemContainer: ItemContainerS) {
        switch itemContainer.state {
        case .on:
            hide(itemContainer, animated: true)
            itemContainer.state = .off
        case .off:
            show(itemContainer, animated: true)
            itemContainer.state = .on
        default: break
        }
    }

    // Show the Body Item
    func show(_ item: ItemContainerS, animated: Bool) {
        item.body.show(animated: animated)

        if let bodyViewController = item.body.viewController as? BaseViewController {
            bodyViewController.invalidateRestorableState()
        }
        item.body.viewController.view.isHidden = false
        item.header.update(toDisclosureState: .on)
    }

    // Hide the Body Item
    func hide(_ item: ItemContainerS, animated: Bool) {
        item.body.hide(animated: animated)

        if let bodyViewController = item.body.viewController as? BaseViewController {
            bodyViewController.invalidateRestorableState()
        }
        item.body.viewController.view.isHidden = true
        item.header.update(toDisclosureState: .off)
    }
}

// MARK: -

extension ItemHeader where Self: NSViewController {
    var viewController: NSViewController { return self }
}

// MARK: -

extension ItemBody where Self: NSViewController {
    var viewController: NSViewController { return self }

    func animateDisclosure(disclose: Bool, animated: Bool) {
        if let viewController = self as? BaseViewController {
//            if let constraint = viewController.heightConstraint {
//                let heightValue = disclose ? viewController.savedDefaultHeight : 0
            if animated {
                NSAnimationContext.runAnimationGroup({ (context) -> Void in
                    context.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
//                        constraint.animator().constant = heightValue
                    viewController.view.isHidden = disclose
                }, completionHandler: { () -> Void in
                    // animation completed
                })
            } else {
//                    constraint.constant = heightValue
                viewController.view.isHidden = disclose
            }
//            }
        }
    }

    func show(animated: Bool) {
        animateDisclosure(disclose: true, animated: animated)
    }

    func hide(animated: Bool) {
        animateDisclosure(disclose: false, animated: animated)
    }
}

// MARK: -

/// - Tag: Container
class ItemContainerS {
    // Disclosure state of this container.
    var state: NSControl.StateValue

    let header: ItemHeader
    let body: ItemBody

    init(header: ItemHeader, body: ItemBody) {
        self.header = header
        self.body = body
        state = .off
    }
}

// MARK: -

class CustomStackView: NSStackView {
    var continerViews: [ItemContainerS?] = []
    override var isFlipped: Bool { return true }
}

class FlippedClipView: NSClipView {
    override var isFlipped: Bool { return true }
}

class FlippedNSView: NSView {
    override var isFlipped: Bool { return true }
}
