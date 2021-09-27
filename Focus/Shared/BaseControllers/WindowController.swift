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

class WindowController: NSWindowController, NSWindowRestoration {
    override func windowDidLoad() {
        super.windowDidLoad()

        /*    We support state restoration for this window and all its embedded view controllers.
             In order for all the view controllers to be restored, this window must be restorable too.
              This can also be done in the storyboard.
         */
        window?.preventsApplicationTerminationWhenModal = false
        window?.styleMask.remove(.fullScreen)
        window?.styleMask.remove(.fullSizeContentView)
        window?.styleMask.remove(.resizable)
        window?.isRestorable = false
        window?.identifier = NSUserInterfaceItemIdentifier("WindowController")

        // This will ensure restoreWindow will be called.
        window?.restorationClass = WindowController.self
    }

    // MARK: - Window Restoration

    /// Sent to request that this window be restored.
    static func restoreWindow(withIdentifier identifier: NSUserInterfaceItemIdentifier,
                              state: NSCoder,
                              completionHandler: @escaping (NSWindow?, Error?) -> Swift.Void) {
        let identifier = identifier.rawValue

        var restoreWindow: NSWindow?
        if identifier == "WindowController" { // This is the identifier for the NSWindow.
            // We didn't create the window, it was created from the storyboard.
            restoreWindow = windowController.window
        }
        completionHandler(restoreWindow, nil)
    }
}
