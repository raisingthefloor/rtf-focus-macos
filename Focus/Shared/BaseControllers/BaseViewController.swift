//
//  BaseController.swift
//  Focus
//
//  Created by Bhavi on 22/06/21.
//

import Cocoa
import Foundation
import RxCocoa
import RxSwift

class BaseViewController: NSViewController, StackItemBody {
    var disposeBag = DisposeBag()

    @IBOutlet var heightConstraint: NSLayoutConstraint!

    typealias promptResponseClosure = (_ strResponse: String, _ bResponse: Bool) -> Void

    // The original expanded height of this view controller (used to adjust height between disclosure states).
    var savedDefaultHeight: CGFloat = 0

    // Subclasses determine the header title.
    func headerTitle() -> String { return "" }

    // MARK: - View Controller Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        // Remember the default height for disclosing later (subclasses can determine this value in their own viewDidLoad).
    }

    // MARK: - StackItemContainer

    lazy var stackItemContainer: StackItemContainer? = {
        /*    We conditionally decide what flavor of header disclosure to use by "DisclosureTriangleAppearance" compilation flag,
             which is defined in “Active Compilation Conditions” Build Settings (for passing conditional compilation
              flags to the Swift compiler). If you want to use the non-triangle disclosure version, remove that flag.
         */
        var storyboardIdentifier: String = "HeaderViewC"
        let storyboard = NSStoryboard(name: "HeaderView", bundle: nil)
        guard let headerViewController = storyboard.instantiateController(withIdentifier: storyboardIdentifier) as? HeaderViewC else {
            return .none
        }

        headerViewController.title = self.headerTitle()

        return StackItemContainer(header: headerViewController, body: self)
    }()
}

extension BaseViewController {
    /// Encode state. Helps save the restorable state of this view controller.
    override func encodeRestorableState(with coder: NSCoder) {
        // Encode the disclosure state.
        if let container = stackItemContainer {
            // Use the header's title as the encoding key.
            coder.encode(container.state, forKey: String(describing: headerTitle()))
        }
        super.encodeRestorableState(with: coder)
    }

    /// Decode state. Helps restore any previously stored state.
    override func restoreState(with coder: NSCoder) {
        super.restoreState(with: coder)

        // Restore the disclosure state, use the header's title as the decoding key.
        if let disclosureState = coder.decodeObject(forKey: headerTitle()) as? NSControl.StateValue {
            if let container = stackItemContainer {
                container.state = disclosureState

                // Expand/collapse the container's body view controller.
                switch container.state {
                case .on:
                    container.body.show(animated: false)
                case .off:
                    container.body.hide(animated: false)
                default: break
                }
                // Update the header's disclosure.
                container.header.update(toDisclosureState: container.state)
            }
        }
    }

//    func performGlobalCopyShortcut() {
//        func keyEvents(forPressAndReleaseVirtualKey virtualKey: Int) -> [CGEvent] {
//            let eventSource = CGEventSource(stateID: .hidSystemState)
//            return [
//                CGEvent(keyboardEventSource: eventSource, virtualKey: CGKeyCode(virtualKey), keyDown: true)!,
//                CGEvent(keyboardEventSource: eventSource, virtualKey: CGKeyCode(virtualKey), keyDown: false)!,
//            ]
//        }
//
//        let tapLocation = CGEventTapLocation.cghidEventTap
//        let events = keyEvents(forPressAndReleaseVirtualKey: kVK_ANSI_C)
//
//        events.forEach {
//            $0.flags = .maskCommand
//            $0.post(tap: tapLocation)
//        }
//    }
}

// MARK: - Alert

extension BaseViewController {
    func promptForReply(_ strMsg: String, _ strInformative: String, completion: promptResponseClosure) {
        let alert: NSAlert = NSAlert()

        alert.addButton(withTitle: "OK".l10n()) // 1st button
        alert.addButton(withTitle: "Cancel".l10n()) // 2nd button
        alert.messageText = strMsg
        alert.informativeText = strInformative

        let txt = NSTextField(frame: NSRect(x: 0, y: 0, width: 200, height: 24))
        txt.stringValue = ""
        txt.placeholderString = "Enter Url".l10n()
        alert.accessoryView = txt
        let response: NSApplication.ModalResponse = alert.runModal()

        var bResponse = false
        if response == NSApplication.ModalResponse.alertFirstButtonReturn {
            bResponse = true
        }
        completion(txt.stringValue, bResponse)
    }
}
