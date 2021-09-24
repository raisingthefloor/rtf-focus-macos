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

protocol DismissViewCDelegate: AnyObject {
    func dismissViewC()
}

class BaseViewController: NSViewController, ItemBody {
    typealias alertActionClosure = (_ value: String, _ action: Bool) -> Void

    //  header title.
    func setTitle() -> String { return "" }

    // MARK: - View Controller Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    // MARK: CollapseExpand Setup

    lazy var headerContinerV: ItemContainerS? = {
        let storyboard = NSStoryboard(name: "HeaderView", bundle: nil)
        guard let headerViewC = storyboard.instantiateController(withIdentifier: "HeaderViewC") as? HeaderViewC else {
            return .none
        }
        headerViewC.title = self.setTitle()
        return ItemContainerS(header: headerViewC, body: self)
    }()
}

extension BaseViewController {
    override func encodeRestorableState(with coder: NSCoder) {
        if let container = headerContinerV {
            coder.encode(container.state, forKey: String(describing: setTitle()))
        }
        super.encodeRestorableState(with: coder)
    }

    override func restoreState(with coder: NSCoder) {
        super.restoreState(with: coder)
        if let disclosureState = coder.decodeObject(forKey: setTitle()) as? NSControl.StateValue {
            if let container = headerContinerV {
                container.state = disclosureState
                switch container.state {
                case .on:
                    container.body.show(animated: false)
                case .off:
                    container.body.hide(animated: false)
                default: break
                }
                container.header.update(toDisclosureState: container.state)
            }
        }
    }
}

// MARK: - Alert

extension BaseViewController {
    func promptToForInput(_ msg: String, _ information: String, completion: alertActionClosure) {
        let alert: NSAlert = NSAlert()

        alert.addButton(withTitle: "OK")
        alert.addButton(withTitle: "Cancel")
        alert.messageText = msg
        alert.informativeText = information

        let txtField = NSTextField(frame: NSRect(x: 0, y: 0, width: 200, height: 24))
        txtField.stringValue = ""
        txtField.placeholderString = "Enter Url"
        alert.accessoryView = txtField
        let response: NSApplication.ModalResponse = alert.runModal()

        var actionState = false
        if response == NSApplication.ModalResponse.alertFirstButtonReturn {
            actionState = true
        }
        completion(txtField.stringValue, actionState)
    }

    func systemAlert(title: String, description: String, btnOk: String) {
        let alert = NSAlert()
        alert.messageText = title
        alert.informativeText = description
        alert.alertStyle = .informational
        alert.addButton(withTitle: btnOk)
        alert.runModal()
    }
}
