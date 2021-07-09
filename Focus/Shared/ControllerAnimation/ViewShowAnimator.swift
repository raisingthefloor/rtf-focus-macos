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
import Foundation

class ViewShowAnimator: NSObject, NSViewControllerPresentationAnimator {
    func animatePresentation(of viewController: NSViewController, from fromViewController: NSViewController) {
        let parentViewC = fromViewController
        let childViewC = viewController
        childViewC.view.wantsLayer = true
        childViewC.view.layerContentsRedrawPolicy = .onSetNeedsDisplay
        childViewC.view.alphaValue = 0
        parentViewC.view.addSubview(childViewC.view)
        var frame: CGRect = NSRectToCGRect(parentViewC.view.frame)
        frame = frame.insetBy(dx: 0, dy: 0)
        childViewC.view.frame = NSRectFromCGRect(frame)
        let color: CGColor = NSColor.darkGray.cgColor
        childViewC.view.layer?.backgroundColor = color
        NSAnimationContext.runAnimationGroup({ (context) -> Void in
            context.duration = 0.5
            childViewC.view.animator().alphaValue = 1
        }, completionHandler: nil)
    }

    func animateDismissal(of viewController: NSViewController, from fromViewController: NSViewController) {
        let childViewC = viewController
        childViewC.view.wantsLayer = true
        childViewC.view.layerContentsRedrawPolicy = .onSetNeedsDisplay

        NSAnimationContext.runAnimationGroup({ (context) -> Void in
            context.duration = 0.5
            childViewC.view.animator().alphaValue = 0
        }, completionHandler: {
            childViewC.view.removeFromSuperview()
        })
    }
}

class CustomSegue: NSStoryboardSegue {
    override func perform() {
        let animator = ViewShowAnimator()
        let sourceController = sourceController as! NSViewController
        let destController = destinationController as! NSViewController
        sourceController.present(destController, animator: animator)
    }
}
