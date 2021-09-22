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

class ErrorDialogueViewC: NSViewController {
    @IBOutlet var lblTitle: NSTextField!
    @IBOutlet var lblDesc: NSTextField!
    @IBOutlet var lblInfo: NSTextField!
    @IBOutlet var btnOk: CustomButton!

    var errorType: ErrorDialogue = .edit_blocklist_error

    override func viewDidLoad() {
        super.viewDidLoad()
        setUpText()
        setUpViews()
        themeSetUp()
        bindData()
    }
}

extension ErrorDialogueViewC: BasicSetupType {
    func setUpText() {
        lblTitle.stringValue = errorType.title
        lblDesc.stringValue = errorType.description
        lblInfo.stringValue = errorType.link

       // lblInfo.isHidden = !errorType.islinkVisible

        btnOk.title = NSLocalizedString("Button.ok", comment: "OK").uppercased()
    }

    func setUpViews() {
        view.window?.level = .floating
        view.background_color = Color.edit_bg_color

        btnOk.buttonColor = Color.green_color
        btnOk.activeButtonColor = Color.green_color
        btnOk.textColor = .white
        btnOk.borderColor = Color.green_color
        btnOk.borderWidth = 0.5
    }

    func themeSetUp() {
        lblTitle.textColor = .black
        lblDesc.textColor = .black
        lblInfo.textColor = Color.info_blue_color

        lblTitle.font = NSFont.systemFont(ofSize: 16, weight: .medium)
        lblDesc.font = NSFont.systemFont(ofSize: 12, weight: .regular)
        lblInfo.font = NSFont.systemFont(ofSize: 12, weight: .regular)
    }

    func bindData() {
        btnOk.target = self
        btnOk.action = #selector(okAction(_:))
    }

    @objc func okAction(_ sender: NSButton) {
        dismiss(sender)
    }
}
