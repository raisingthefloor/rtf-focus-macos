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
import Foundation

class AppManager {
    static var shared = AppManager()

    var query: NSMetadataQuery? {
        willSet {
            if let query = self.query {
                query.stop()
            }
        }
    }
}

extension AppManager {
    public func doSpotlightQuery() {
        query = NSMetadataQuery()
        let predicate = NSPredicate(format: "kMDItemContentType == 'com.apple.application-bundle'")
        NotificationCenter.default.addObserver(self, selector: #selector(queryDidFinish(_:)), name: NSNotification.Name.NSMetadataQueryDidFinishGathering, object: nil)
        query?.predicate = predicate
        query?.start()
    }

    @objc public func queryDidFinish(_ notification: NSNotification) {
        guard let query = notification.object as? NSMetadataQuery else {
            return
        }

        for result in query.results {
            guard let item = result as? NSMetadataItem else {
//                print("Result was not an NSMetadataItem, \(result)")
                continue
            }
//            print("Spotlit Result: \(item.value(forAttribute: kMDItemIdentifier as String))")
//            print("item \(item.values(forAttributes: [kMDItemDisplayName as String, kMDItemPath as String]))")

            if let name = item.value(forAttribute: kMDItemDisplayName as String) as? String {
                if let bundleName = Bundle.bundleIDFor(appNamed: name) {
//                    print("\n")
//                    print("bundleName: \(bundleName)")
                    if let path = NSWorkspace.shared.absolutePathForApplication(withBundleIdentifier: bundleName) {
//                        print("path: \(path)")
                        let icon = NSWorkspace.shared.icon(forFile: path)
//                        print("icon: \(icon)")
                        let data = ["name": name, "bundle_id": bundleName, "path": path]
                        DBManager.shared.saveApplicationlist(data: data)
                    }
                }
            }
        }
    }
}

// MARK: Application launch Observer and Restrict the App If its Blocked

extension AppManager {
    func addObserverToCheckAppLaunch() {
        NSWorkspace.shared.notificationCenter.addObserver(self, selector: #selector(appDidLaunch(notification:)), name: NSWorkspace.willLaunchApplicationNotification, object: nil)
    }

    @objc func appDidLaunch(notification: NSNotification) {
        let arrBlockerApp = DBManager.shared.getActiveBlockList()
        if let app = notification.userInfo,
           let identifier = app["NSApplicationBundleIdentifier"] as? String {
            let runningApplications = NSWorkspace.shared.runningApplications
            // filter here to get only that application which are in block list and also check here if focus is running

            if let application = runningApplications.first(where: { application in
                let bundle_id = arrBlockerApp.filter({ $0.bundle_id == identifier }).map({ $0 }).first?.bundle_id ?? ""
                return application.bundleIdentifier == bundle_id
            }) {
                application.forceTerminate()
                kill(application.processIdentifier, SIGTERM)

                let controller = FocusDialogueViewC(nibName: "FocusDialogueViewC", bundle: nil)
                controller.dialogueType = .launch_app_alert
                windowController.contentViewController?.presentAsSheet(controller)
            }
        }
    }
}
