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

    func registerLocalNotification() {
        appDelegate?.registerhLocalDelegate()
        appDelegate?.registerLocalNotification()
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
        if DBManager.shared.checkAppsIsPresent() {
            var i = 1
            for result in query.results {
                guard let item = result as? NSMetadataItem else {
                    continue
                }
                if let name = item.value(forAttribute: kMDItemDisplayName as String) as? String {
                    if let bundleName = Bundle.bundleIDFor(appNamed: name) {
                        if let path = NSWorkspace.shared.absolutePathForApplication(withBundleIdentifier: bundleName) {
                            let data: [String: Any] = ["name": name, "bundle_id": bundleName, "path": path, "created_at": Date(), "index": i]
                            DBManager.shared.saveApplicationlist(data: data)
                            i = i + 1
                        }
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

        NSWorkspace.shared.notificationCenter.addObserver(self, selector: #selector(appDidLaunch(notification:)), name: NSWorkspace.didActivateApplicationNotification, object: nil)
    }

    func removeObserver() {
        NSWorkspace.shared.notificationCenter.removeObserver(self, name: NSWorkspace.willLaunchApplicationNotification, object: nil)
        NSWorkspace.shared.notificationCenter.removeObserver(self, name: NSWorkspace.didActivateApplicationNotification, object: nil)
    }

    @objc func appDidLaunch(notification: NSNotification) {
        let arrBlockerApp = DBManager.shared.getCurrentBlockList().apps
        guard let app = notification.userInfo else { return }
        if let identifier = app["NSApplicationBundleIdentifier"] as? String {
            let runningApplications = NSWorkspace.shared.runningApplications
            // filter here to get only that application which are in block list and also check here if focus is running
            let bundle_id = arrBlockerApp.filter({ $0.app_identifier == identifier }).map({ $0 }).first?.app_identifier ?? ""

            print(runningApplications)

            if let application = NSRunningApplication.runningApplications(withBundleIdentifier: bundle_id).first {
//            if let application = runningApplications.first(where: { application in
//                application.bundleIdentifier == bundle_id
//            }) {
                application.forceTerminate()
                kill(application.processIdentifier, SIGTERM)
//            }

                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "appLaunchNotification_session"), object: application)
            }
        } else if let application = app["NSWorkspaceApplicationKey"] as? NSRunningApplication {
            let identifier = application.bundleIdentifier
            if let _ = arrBlockerApp.filter({ $0.app_identifier == identifier }).map({ $0 }).first?.app_identifier {
                application.forceTerminate()
                kill(application.processIdentifier, SIGTERM)
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "appLaunchNotification_session"), object: application)
            }
        }
    }
}
