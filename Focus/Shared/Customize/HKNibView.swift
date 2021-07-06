//
//  HKNibView.swift
//  Focus
//
//  Created by Bhavi on 01/07/21.
//

import AppKit
import Cocoa
import Foundation

import Cocoa

protocol LoadableView: AnyObject {
    var mainView: NSView? { get set }
    func load(fromNIBNamed nibName: String) -> Bool
}

extension LoadableView where Self: NSView {
    func load(fromNIBNamed nibName: String) -> Bool {
        var nibObjects: NSArray?
        let nibName = NSNib.Name(stringLiteral: nibName)

        if Bundle.main.loadNibNamed(nibName, owner: self, topLevelObjects: &nibObjects) {
            guard let nibObjects = nibObjects else { return false }

            let viewObjects = nibObjects.filter { $0 is NSView }

            if viewObjects.count > 0 {
                guard let view = viewObjects[0] as? NSView else { return false }
                mainView = view
                addSubview(mainView!)

                mainView?.translatesAutoresizingMaskIntoConstraints = false
                mainView?.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
                mainView?.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
                mainView?.topAnchor.constraint(equalTo: topAnchor).isActive = true
                mainView?.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true

                return true
            }
        }

        return false
    }
}
