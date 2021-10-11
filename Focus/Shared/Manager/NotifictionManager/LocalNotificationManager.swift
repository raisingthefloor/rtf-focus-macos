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
import UserNotifications

protocol NotificationMangerLogic {
    func validate(response: [AnyHashable: Any], completionHandler: ((UNNotificationPresentationOptions) -> Void)?)
    func setLocalNotification(info: LocalNotificationInfo)
    func removePendingNotificationRequests(identifiers: [String])
    func clearAll()
}

struct LocalNotificationInfo {
    let title: String
    let body: String?
    let dateComponents: DateComponents
    let identifier: String
    let repeats: Bool
}

enum Notification_Type: Int {
    case reminder = 1
    case schedule_focus_session
}

class NotificationManager: NotificationMangerLogic {
    static var shared: NotificationMangerLogic = NotificationManager()

    func clearAll() {
        UNUserNotificationCenter.current().removeAllDeliveredNotifications()
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }

    func validate(response: [AnyHashable: Any], completionHandler: ((UNNotificationPresentationOptions) -> Void)? = nil) {
        guard let typeString = response["responseType"] as? String, let type = Int(typeString), let uuid = response["id"] as? String else { return }

        print(uuid)
        let notificationType = Notification_Type(rawValue: type) ?? .none
        let presentCtrl = WindowsManager.getPresentingController()

        switch notificationType {
        case .reminder:
            let controller = FocusDialogueViewC(nibName: "FocusDialogueViewC", bundle: nil)
            controller.dialogueType = .schedule_reminded_without_blocklist_alert
            // set here reminder id = reminder_id
            controller.breakAction = { _, _, _ in
                // self.updateViewnData(dialogueType: .schedule_reminded_without_blocklist_alert, action: action, value: value, valueType: valueType)
            }
            presentCtrl?.presentAsSheet(controller)

        default:
            if response["responseType"] != nil {
                completionHandler?([.alert, .sound])
            }
        }
    }
}

extension AppDelegate: UNUserNotificationCenterDelegate {
    func registerhLocalDelegate() {
        UNUserNotificationCenter.current().delegate = self
    }

    func registerLocalNotification() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { granted, error in
            if let error = error {
                print("request authorization error: \(error)")
            } else if granted {
                print("autorization granted")
            } else {
                print("user denied notifications")
            }
        }
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        NSLog("**** didReceive response: UNNotificationResponse \(NotificationManager.shared)")
        NotificationManager.shared.validate(response: response.notification.request.content.userInfo,
                                            completionHandler: nil)
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        NSLog("#### willPresent notification: UNNotification \(notification.request.content.userInfo)")
        NotificationManager.shared.validate(response: notification.request.content.userInfo,
                                            completionHandler: completionHandler)
    }
}

extension NotificationManager {
    func setLocalNotification(info: LocalNotificationInfo) {
        let notificationContent = UNMutableNotificationContent()
        notificationContent.title = info.title
        notificationContent.body = info.body ?? ""
        notificationContent.userInfo = ["responseType": String(format: "%d", Notification_Type.reminder.rawValue), "id": info.identifier]
        notificationContent.sound = .default
        let trigger = UNCalendarNotificationTrigger(dateMatching: info.dateComponents, repeats: info.repeats)
        let request = UNNotificationRequest(identifier: info.identifier,
                                            content: notificationContent,
                                            trigger: trigger)

        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Notification Error: \(error)")
            } else {
                #if DEV
                    logInfo(" TITLE: \(info.body ?? "") \n Notification Set \(request)")
                #endif
            }
        }
    }

    func removePendingNotificationRequests(identifiers: [String]) {
        #if DEV
            logInfo("Notification identifiers Remove \(identifiers)")

            UNUserNotificationCenter.current().getPendingNotificationRequests { notifications in
                logInfo("Register Notification identifiers \(notifications.map({ $0.identifier }))")
            }
        #endif

        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: identifiers)

        #if DEV
            UNUserNotificationCenter.current().getPendingNotificationRequests { notifications in
                logInfo("After Remove Notification identifiers \(notifications.map({ $0.identifier }))")
            }
        #endif
    }
}
