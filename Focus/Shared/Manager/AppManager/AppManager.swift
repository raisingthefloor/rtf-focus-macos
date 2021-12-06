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

import AppleScriptObjC
import Cocoa
import Foundation

class AppManager {
    static var shared = AppManager()

    var breakTimerModel: TimerModelType = BreakTimerManager()
    var focusTimerModel: TimerModelType = FocusTimerManager()

    var query: NSMetadataQuery? {
        willSet {
            if let query = self.query {
                query.stop()
            }
        }
    }

//    let appDelegate = NSApplication.shared.delegate as! AppDelegate
    var browserBridge: AppleScriptProtocol?
    var reminderModel: ReminderModelType = ReminderTimerManager()

    func registerLocalNotification() {
        Config.delegate.registerhLocalDelegate()
        Config.delegate.registerLocalNotification()
    }

    func initialSetup() {
        NotificationCenter.default.addObserver(self, selector: #selector(calendarDayDidChange), name: .NSCalendarDayChanged, object: nil)
        loadScript()
        doSpotlightQuery()
        DataModel.preAddSchedule()
        DataModel.storeCategory()

        addObserverForDockQuit()
        startCheckingReminder()

        if !UserDefaults.standard.bool(forKey: "pre_added_blocklist") {
            DBManager.shared.systemPreAddedBlocklist()
        }

        FocusFirewall.shared.initialConfiguration()
    }

    func addObserverForDockQuit() {
        let appleEventManager: NSAppleEventManager = NSAppleEventManager.shared()
        appleEventManager.setEventHandler(self, andSelector: #selector(handleQuitEvent(event:withReplyEvent:)), forEventClass: kCoreEventClass, andEventID: kAEQuitApplication)

        NSWorkspace.shared.notificationCenter.addObserver(self,
                                                          selector: #selector(macPowerOff),
                                                          name: NSWorkspace.willPowerOffNotification,
                                                          object: nil)
    }

    func loadScript() {
        BrowserScript.load()
        guard let bridgeScript = BrowserScript.loadScript() as? AppleScriptProtocol else { return }
        browserBridge = bridgeScript
    }

    func startCheckingReminder() {
        reminderModel.input.setupInitial()
    }

    @objc func macPowerOff() {
        guard let obj = DBManager.shared.getCurrentSession(), let objBl = DBManager.shared.getCurrentBlockList().arrObjBl.last else {
            resetFocusSession()
            stopScriptObserver()
            NSApplication.shared.terminate(self)
            return
        }

        let is_restart_computer = DBManager.shared.getCurrentBlockList().arrObjBl.compactMap({ $0.restart_computer }).filter({ $0 }).first ?? false

        if is_restart_computer && obj.is_focusing {
            resetFocusSession()
            stopScriptObserver()
            NSApplication.shared.terminate(self)
        } else if !obj.is_focusing {
            resetFocusSession()
            stopScriptObserver()
            NSApplication.shared.terminate(self)
        }
    }

    @objc func handleQuitEvent(event: NSAppleEventDescriptor, withReplyEvent: NSAppleEventDescriptor) {
        guard let obj = DBManager.shared.getCurrentSession(), let _ = DBManager.shared.getCurrentBlockList().arrObjBl.last else {
            resetFocusSession()
            stopScriptObserver()
            NSApplication.shared.terminate(self)
            return
        }

        let is_restart_computer = DBManager.shared.getCurrentBlockList().arrObjBl.compactMap({ $0.restart_computer }).filter({ $0 }).first ?? false

        if is_restart_computer && obj.is_focusing {
            resetFocusSession()
            stopScriptObserver()
            NSApplication.shared.terminate(self)
        } else if !obj.is_focusing {
            resetFocusSession()
            stopScriptObserver()
            NSApplication.shared.terminate(self)
        }
    }
}

extension AppManager {
    @objc func calendarDayDidChange() {
        let arrSubCat = DBManager.shared.getGeneralCategoryData().subCat
        _ = arrSubCat.map({ $0.is_selected = false })
        DBManager.shared.saveContext()
    }

    public func doSpotlightQuery() {
        query = NSMetadataQuery()
        let predicate = NSPredicate(format: "kMDItemKind == 'Application'")
        NotificationCenter.default.addObserver(self, selector: #selector(queryDidFinish(_:)), name: NSNotification.Name.NSMetadataQueryDidFinishGathering, object: nil)
        query?.predicate = predicate
        query?.start()
    }

    @objc public func queryDidFinish(_ notification: NSNotification) {
        guard let query = notification.object as? NSMetadataQuery else {
            return
        }

        var i = 1
        for result in query.results {
            guard let item = result as? NSMetadataItem else {
                continue
            }
            if let name = item.value(forAttribute: kMDItemDisplayName as String) as? String {
                if let bundleName = Bundle.bundleIDFor(appNamed: name) {
                    if let path = NSWorkspace.shared.absolutePathForApplication(withBundleIdentifier: bundleName) {
                        if !DBManager.shared.checkAppsIsPresent(bundle_id: bundleName) {
                            let data: [String: Any] = ["name": name, "bundle_id": bundleName, "path": path, "created_at": Date(), "index": i]
                            DBManager.shared.saveApplicationlist(data: data)
                            i = i + 1
                        }
                    }
                }
            }
        }
        print("Count \(i)")
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

                NotificationCenter.default.post(name: NSNotification.Name(rawValue: ObserverName.appLaunch_event.rawValue), object: application)
            }
        } else if let application = app["NSWorkspaceApplicationKey"] as? NSRunningApplication {
            let identifier = application.bundleIdentifier
            if let _ = arrBlockerApp.filter({ $0.app_identifier == identifier }).map({ $0 }).first?.app_identifier {
                application.forceTerminate()
                kill(application.processIdentifier, SIGTERM)
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: ObserverName.appLaunch_event.rawValue), object: application)
            }
        }
    }
}

extension AppManager {
    func stopBothTimer() {
        guard let objCurrent = DBManager.shared.getCurrentSession() else { return }
        if objCurrent.is_focusing || objCurrent.is_break_time {
            focusTimerModel.input.stopTimer()
            breakTimerModel.input.stopTimer()
        }
    }

    func resumeTimer() {
        guard let objCurrent = DBManager.shared.getCurrentSession() else { return }
        if objCurrent.is_break_time {
            breakTimerModel.input.updateTimerStatus()
        } else {
            focusTimerModel.input.updateTimerStatus()
        }
    }

    func resetFocusSession() {
        guard let obj = DBManager.shared.getCurrentSession() else { return }
        let objEx = obj.extended_value
        obj.is_focusing = false
        obj.is_break_time = false
        obj.focus_untill_stop = false
        obj.used_focus_time = 0
        obj.decrease_break_time = 0
        obj.remaining_focus_time = 0
        obj.remaining_break_time = 0
        obj.extended_break_time = 0
        obj.extended_focus_time = 0
        obj.combine_break_lenght_time = 0
        obj.combine_stop_focus_after_time = 0
        obj.combine_focus_length_time = 0
        objEx?.is_mid_focus = false
        objEx?.is_small_focus = false
        objEx?.is_long_focus = false
        objEx?.is_mid_break = false
        objEx?.is_small_break = false
        objEx?.is_long_break = false
        objEx?.is_mid_done_focus = false
        objEx?.is_small_done_focus = false
        objEx?.is_long_done_focus = false
        if let arrFocus = obj.focuses?.allObjects as? [Focus_List] {
            for obj in arrFocus {
                DBManager.shared.managedContext.delete(obj)
            }
        }
        DBManager.shared.saveContext()
    }

    func stopScriptObserver() {
        WindowsManager.stopBlockWebSite()
        removeObserver()
        WindowsManager.runDndCommand(cmd: "off")
    }
}
