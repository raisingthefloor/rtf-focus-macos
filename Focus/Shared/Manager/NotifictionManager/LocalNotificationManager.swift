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
    let uuid: UUID
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
        guard let typeString = response["responseType"] as? String, let type = Int(typeString), let uuidStr = response["uuid"] as? String, let uuid = UUID(uuidString: uuidStr) else { return }

        print("Validate Notification Response: \(uuid)")
        let notificationType = Notification_Type(rawValue: type) ?? .none
        switch notificationType {
        case .reminder:
            displayScheduleReminder(scheduleId: uuid)
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
        print("**** didReceive response: UNNotificationResponse \(NotificationManager.shared)")
        NotificationManager.shared.validate(response: response.notification.request.content.userInfo,
                                            completionHandler: nil)
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        print("#### willPresent notification: UNNotification \(notification.request.content.userInfo)")
        NotificationManager.shared.validate(response: notification.request.content.userInfo,
                                            completionHandler: completionHandler)
    }
}

extension NotificationManager {
    func setLocalNotification(info: LocalNotificationInfo) {
        let notificationContent = UNMutableNotificationContent()
        notificationContent.title = info.title
        notificationContent.body = info.body ?? ""
        notificationContent.userInfo = ["responseType": String(format: "%d", Notification_Type.reminder.rawValue), "id": info.identifier, "uuid": info.uuid.uuidString]
        notificationContent.sound = .default
        let trigger = UNCalendarNotificationTrigger(dateMatching: info.dateComponents, repeats: info.repeats)
        let request = UNNotificationRequest(identifier: info.identifier,
                                            content: notificationContent,
                                            trigger: trigger)

        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Notification Error: \(error)")
            } else {
                print(" TITLE: \(info.identifier) \n Notification Set \(request)")
            }
        }
    }

    func removePendingNotificationRequests(identifiers: [String]) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: identifiers)
    }
}

extension NotificationManager {
    func displayScheduleReminder(scheduleId: UUID) {
        let presentCtrl = WindowsManager.getPresentingController()
        guard let obj = DBManager.shared.getScheduleFocus(id: scheduleId), let objEx = obj.extend_info else { return }
        if objEx.is_extend_long, objEx.is_extend_mid, objEx.is_extend_short, objEx.is_extend_very_short {
            redirectToMainMenu()
            return
        }
        let controller = FocusDialogueViewC(nibName: "FocusDialogueViewC", bundle: nil)
        controller.dialogueType = .schedule_reminded_without_blocklist_alert
        controller.viewModel.reminderSchedule = obj
        controller.breakAction = { action, value, valueType in
            self.updateViewnData(dialogueType: .schedule_reminded_without_blocklist_alert, action: action, value: value, valueType: valueType, scheduleId: scheduleId)
        }
        presentCtrl?.presentAsSheet(controller)
    }

    func updateViewnData(dialogueType: FocusDialogue, action: ButtonAction, value: Int, valueType: ButtonValueType, scheduleId: UUID) {
        guard let obj = DBManager.shared.getScheduleFocus(id: scheduleId) else { return }
        switch action {
        case .extend_reminder:
            obj.extend_min_time = Int64(value)
            updateExtendedObject(dialogueType: dialogueType, valueType: valueType, obj: obj)
            DBManager.shared.saveContext()
            updateReminder(obj: obj)
        case .skip_session:
            break
        case .normal_ok:
            redirectToMainMenu()
        default: break
        }
    }

    func updateExtendedObject(dialogueType: FocusDialogue, valueType: ButtonValueType, obj: Focus_Schedule) {
        guard let objEx = obj.extend_info else { return }
        switch dialogueType {
        case .schedule_reminded_without_blocklist_alert:
            if !objEx.is_extend_long {
                objEx.is_extend_long = true
            } else if !objEx.is_extend_mid {
                objEx.is_extend_mid = true
            } else if !objEx.is_extend_short {
                objEx.is_extend_short = true
            } else if !objEx.is_extend_very_short {
                objEx.is_extend_very_short = true
            }
        default: break
        }
    }

    func redirectToMainMenu() {
        if let controller = WindowsManager.getVC(withIdentifier: "sidMenuController", ofType: MenuController.self) {
            let presentCtrl = WindowsManager.getPresentingController()

            if presentCtrl is CustomSettingController {
                presentCtrl?.dismiss(nil)
                return
            }

            if presentCtrl is MenuController {
                return
            }

            controller.focusStart = { [weak self] isStarted in
                if isStarted {
                    // self?.setupCountDown() Set there the Observer to start Countdown
                }
            }
            presentCtrl?.presentAsModalWindow(controller)
        }
    }

    func updateReminder(obj: Focus_Schedule?) {
        guard let objF = obj, let uuid = objF.id, let id = objF.id?.uuidString, let startTime = objF.start_time else { return }
        var dateComponents = startTime.toDateComponent()
        dateComponents.minute = (Date().currentDateComponent().minute ?? 0) + Int(obj?.extend_min_time ?? 15)
        print("DateComponents : === \(dateComponents)")

        var arrDays = objF.days?.components(separatedBy: ",") ?? []
        arrDays = arrDays.filter({ $0 != "" }).compactMap({ $0 })
        if !arrDays.isEmpty {
            print("Days : === \(arrDays)")
            let identifiers = arrDays.map({ (id + "_" + $0) })
            print("identifiers : === \(identifiers)")

            NotificationManager.shared.removePendingNotificationRequests(identifiers: identifiers)
            for i in arrDays {
                let identifier = id + "_" + i
                dateComponents.weekday = Int(i) ?? 0
                NotificationManager.shared.setLocalNotification(info: LocalNotificationInfo(title: "Focus Reminder", body: "You asked to be reminded to focus at this time.", dateComponents: dateComponents, identifier: identifier, uuid: uuid, repeats: true))
            }
        }
    }
}
