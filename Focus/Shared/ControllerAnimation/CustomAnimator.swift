//
//  CustomAnimator.swift
//  Focus
//
//  Created by Bhavi on 24/06/21.
//

import Cocoa
import Foundation

class CustomAnimator: NSObject, NSViewControllerPresentationAnimator {
    func animatePresentation(of viewController: NSViewController, from fromViewController: NSViewController) {
        let bottomVC = fromViewController
        let topVC = viewController
        topVC.view.wantsLayer = true
        topVC.view.layerContentsRedrawPolicy = .onSetNeedsDisplay
        topVC.view.alphaValue = 0
        bottomVC.view.addSubview(topVC.view)
        var frame: CGRect = NSRectToCGRect(bottomVC.view.frame)
        frame = frame.insetBy(dx: 0, dy: 0)
        topVC.view.frame = NSRectFromCGRect(frame)
        let color: CGColor = NSColor.darkGray.cgColor
        topVC.view.layer?.backgroundColor = color
        NSAnimationContext.runAnimationGroup({ (context) -> Void in
            context.duration = 0.5
            topVC.view.animator().alphaValue = 1

        }, completionHandler: nil)
    }

    func animateDismissal(of viewController: NSViewController, from fromViewController: NSViewController) {
        let topVC = viewController
        topVC.view.wantsLayer = true
        topVC.view.layerContentsRedrawPolicy = .onSetNeedsDisplay

        NSAnimationContext.runAnimationGroup({ (context) -> Void in
            context.duration = 0.5
            topVC.view.animator().alphaValue = 0
        }, completionHandler: {
            topVC.view.removeFromSuperview()
        })
    }
}

class CustomSegue: NSStoryboardSegue {
    override func perform() {
        let animator = CustomAnimator()
        let sourceVC = sourceController as! NSViewController
        let destVC = destinationController as! NSViewController
        sourceVC.present(destVC, animator: animator)
    }
}
