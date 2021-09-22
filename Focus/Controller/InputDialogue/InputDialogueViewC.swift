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

class InputDialogueViewC: NSViewController {
    @IBOutlet var lblTitle: NSTextField!
    @IBOutlet var txtField: NSTextField!

    @IBOutlet var testView: NSView!

    @IBOutlet var btnTestUrl: CustomButton!
    @IBOutlet var lblInfo: NSTextField!
    @IBOutlet var btnCreate: CustomButton!
    @IBOutlet var btnCancel: CustomButton!

    var inputType: InputDialogue = .add_website

    override func viewDidLoad() {
        super.viewDidLoad()
        setUpText()
        setUpViews()
        themeSetUp()
        bindData()
    }
}

extension InputDialogueViewC: BasicSetupType {
    func setUpText() {
        lblTitle.stringValue = inputType.title
        lblInfo.stringValue = inputType.link

        testView.isHidden = !inputType.isTestUrlVisible

        btnCancel.title = NSLocalizedString("Button.cancel", comment: "Cancel")
        btnTestUrl.title = NSLocalizedString("ID.test_url", comment: "Test URL")
        btnCreate.title = inputType.add_button_title
    }

    func setUpViews() {
        view.window?.level = .floating
        view.background_color = Color.edit_bg_color
    }

    func themeSetUp() {
        lblTitle.textColor = .black
        lblInfo.textColor = Color.info_blue_color

        lblTitle.font = NSFont.systemFont(ofSize: 12, weight: .semibold)
        // lblInfo.font = NSFont.systemFont(ofSize: 12, weight: .regular) // Italic

        btnCreate.buttonColor = Color.green_color
        btnCreate.activeButtonColor = Color.green_color
        btnCreate.textColor = .white
        btnCreate.borderColor = Color.green_color
        btnCreate.borderWidth = 0.5

        btnCancel.buttonColor = Color.very_light_grey
        btnCancel.activeButtonColor = Color.very_light_grey
        btnCancel.textColor = .black
        btnCancel.borderColor = Color.dark_grey_border
        btnCancel.borderWidth = 0.5

        btnTestUrl.buttonColor = Color.light_green_color
        btnTestUrl.activeButtonColor = Color.light_green_color
        btnTestUrl.textColor = Color.green_color
        btnTestUrl.borderColor = Color.green_color
        btnTestUrl.borderWidth = 0.5
    }

    func bindData() {
        btnCreate.target = self
        btnCreate.action = #selector(createAction(_:))

        btnCancel.target = self
        btnCancel.action = #selector(cancelAction(_:))

        btnTestUrl.target = self
        btnTestUrl.action = #selector(testUrlAction(_:))
    }

    @objc func createAction(_ sender: NSButton) {
        dismiss(sender)
    }

    @objc func cancelAction(_ sender: NSButton) {
        dismiss(sender)
    }

    @objc func testUrlAction(_ sender: NSButton) {
        dismiss(sender)
    }
}
