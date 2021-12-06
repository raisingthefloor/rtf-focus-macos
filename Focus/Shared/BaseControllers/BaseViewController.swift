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

class BaseViewController: NSViewController {
    typealias alertActionClosure = (_ value: String, _ action: Bool) -> Void

    //  header title.
    func setTitle() -> String { return "" }

    var urllink: String = Config.block_list

    // MARK: - View Controller Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
    }
}

extension BaseViewController {
    override func encodeRestorableState(with coder: NSCoder) {
        super.encodeRestorableState(with: coder)
    }

    override func restoreState(with coder: NSCoder) {
        super.restoreState(with: coder)
    }
}

// MARK: - Alert

extension BaseViewController {
    @objc func openBrowser() {
        let urlString = urllink
        guard let url = URL(string: urlString) else { return }
        if NSWorkspace.shared.open(url) {
            print("default browser was successfully opened")
        }
    }

    func systemAlert(title: String, description: String, btnOk: String) {
        let alert = NSAlert()
        alert.messageText = title
        alert.informativeText = description
        alert.alertStyle = .informational
        alert.addButton(withTitle: btnOk)
        alert.runModal()
    }

    func openErrorDialogue(errorType: ErrorDialogue, objBL: Block_List?) {
        let errorDialog = ErrorDialogueViewC(nibName: "ErrorDialogueViewC", bundle: nil)
        errorDialog.errorType = errorType
        errorDialog.objBl = objBL
        presentAsSheet(errorDialog)
    }
}
