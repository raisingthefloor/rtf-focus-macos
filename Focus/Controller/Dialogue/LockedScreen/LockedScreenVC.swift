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

class LockedScreenVC: NSViewController {
    @IBOutlet var containerView: NSView!
    @IBOutlet var lblTitle: NSTextField!
    @IBOutlet var lblDesc: NSTextField!
    @IBOutlet var lblInfo: NSTextField!

    var dismiss: ((Bool) -> Void)?
    private var timer: Timer?

    override func viewDidLoad() {
        super.viewDidLoad()
        setUpText()
        setUpViews()
        bindData()
    }
}

extension LockedScreenVC: BasicSetupType {
    func setUpText() {
        lblTitle.stringValue = NSLocalizedString("Lock.title", comment: "Screen is blocked")
        lblDesc.stringValue = NSLocalizedString("Lock.dec", comment: "You set the computer to be locked for one minute at the start of \neach break to encourage you to stand and stretch.")
    }

    func setUpViews() {
        WindowsManager.setDialogueInCenter()
        themeSetUp()
    }

    func themeSetUp() {
        lblTitle.font = NSFont.systemFont(ofSize: 24, weight: .bold)
        lblTitle.textColor = .black
        lblDesc.font = NSFont.systemFont(ofSize: 12, weight: .regular)
        lblDesc.textColor = .black
//        lblInfo.font = NSFont.systemFont(ofSize: 10, weight: .regular) // Bold Italic
//        lblInfo.textColor = Color.blue_color

//        containerView.bgColor = Color.light_blue_color

        view.border_color = Color.green_color
        view.border_width = 1
        view.background_color = Color.dialogue_bg_color
        view.corner_radius = 10
    }

    func bindData() {
        print("Lock Screen \(Date())")
        guard timer == nil else { return }
//        timer = Timer.scheduledTimer(timeInterval: 60, target: self, selector: #selector(releaseView), userInfo: nil, repeats: false)
        DispatchQueue.global(qos: .background).async(execute: { () -> Void in
            self.timer = .scheduledTimer(timeInterval: 60, target: self, selector: #selector(self.releaseView), userInfo: nil, repeats: false)
            RunLoop.current.add(self.timer!, forMode: .default)
            RunLoop.current.run()
        })
    }

    @objc func releaseView() {
        print("Release Screen \(Date())")
        DispatchQueue.main.async {
            guard self.timer != nil else { return }
            self.timer?.invalidate()
            self.timer = nil
            self.dismiss?(true)
            self.dismiss(nil)
        }
    }
}
