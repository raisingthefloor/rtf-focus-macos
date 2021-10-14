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

protocol ScheduleViewModelIntput {
    func getSessionList() -> [ScheduleSession]
    func setReminder(obj: Focus_Schedule?)
    func removeReminder(obj: Focus_Schedule?)
}

protocol ScheduleViewModelOutput {
}

protocol ScheduleViewModelType {
    var input: ScheduleViewModelIntput { get }
    var output: ScheduleViewModelOutput { get }
    var arrFocusSchedule: [Focus_Schedule] { get set }
    var arrTimes: [String] { get set }
    var objGCategory: Block_Category? { get set }
}

class ScheduleViewModel: ScheduleViewModelIntput, ScheduleViewModelOutput, ScheduleViewModelType {
    var input: ScheduleViewModelIntput { return self }
    var output: ScheduleViewModelOutput { return self }

    var arrTimes: [String] = ["12 AM", "1 AM", "2 AM", "3 AM", "4 AM", "5 AM", "6 AM", "7 AM", "8 AM", "9 AM", "10 AM", "11 AM", "12 PM", "1 PM", "2 PM", "3 PM", "4 PM", "5 PM", "6 PM", "7 PM", "8 PM", "9 PM", "10 PM", "11 PM"]

    var arrFocusSchedule: [Focus_Schedule] = []
    var objGCategory: Block_Category?

    init() {
        arrFocusSchedule = DBManager.shared.getFocusSchedule()
        objGCategory = DBManager.shared.getGeneralCategoryData().gCat
    }

    func setReminder(obj: Focus_Schedule?) {
        guard let objF = obj, let uuid = objF.id, let id = objF.id?.uuidString, let startTime = objF.start_time else { return }

        var arrDays: [String] = objF.days?.components(separatedBy: ",") ?? []
        arrDays = arrDays.filter({ $0 != "" }).compactMap({ $0 })
        if !arrDays.isEmpty {
            print("Set Reminder")
            var dateComponents = startTime.toDateComponent()
            dateComponents.minute = (Date().currentDateComponent().minute ?? 0) + 2
            print("DateComponents : === \(dateComponents)")

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

    func removeReminder(obj: Focus_Schedule?) {
        guard let objF = obj, let id = objF.id?.uuidString else { return }
        let arrDays = objF.days?.components(separatedBy: ",") ?? []
        let identifiers = arrDays.map({ (id + "_" + $0) })
        print("Remove identifiers \(identifiers)")
        NotificationManager.shared.removePendingNotificationRequests(identifiers: identifiers)
    }

    func getSessionList() -> [ScheduleSession] {
        var scheduleS: [ScheduleSession] = []

//        for day in WeekDays.days {
//            switch day {
//            case .mon:
//                let seven = ScheduleSession(id: day.rawValue, time: "7 AM", sun: true, mon: true, tue: true, wed: true, thu: true, fri: true, sat: true, session: 1)
//                scheduleS.append(seven)
//                let twel = ScheduleSession(id: day.rawValue, time: "9 PM", sun: true, mon: true, tue: true, wed: true, thu: true, fri: true, sat: true, session: 1)
//                scheduleS.append(twel)
//            case .tue:
//
//            case .wed:
//                <#code#>
//            case .thu:
//                <#code#>
//            case .fri:
//                <#code#>
//            case .sat:
//                <#code#>
//            case .sun:
//                <#code#>
//            }
//        }

        for i in 0 ..< arrTimes.count {
            switch arrTimes[i] {
            case "5 AM":
                let twel = ScheduleSession(id: i, time: "5 AM", sun: false, mon: false, tue: false, wed: false, thu: false, fri: false, sat: false, session: 0)
                scheduleS.append(twel)
            case "6 AM":
                let twel = ScheduleSession(id: i, time: "6 AM", sun: false, mon: false, tue: false, wed: false, thu: false, fri: false, sat: false, session: 0)
                scheduleS.append(twel)
            case "7 AM":
                let seven = ScheduleSession(id: i, time: "7 AM", sun: true, mon: true, tue: true, wed: true, thu: true, fri: true, sat: true, session: 1)
                scheduleS.append(seven)
            case "8 AM":
                let twel = ScheduleSession(id: i, time: "8 AM", sun: false, mon: false, tue: false, wed: false, thu: false, fri: false, sat: false, session: 0)
                scheduleS.append(twel)
            case "9 AM":
                let twel = ScheduleSession(id: i, time: "9 AM", sun: false, mon: false, tue: false, wed: false, thu: false, fri: false, sat: false, session: 0)
                scheduleS.append(twel)
            case "10 AM":
                let twel = ScheduleSession(id: i, time: "10 AM", sun: false, mon: false, tue: false, wed: false, thu: false, fri: false, sat: false, session: 0)
                scheduleS.append(twel)
            case "11 AM":
                let twel = ScheduleSession(id: i, time: "11 AM", sun: false, mon: false, tue: false, wed: false, thu: false, fri: false, sat: false, session: 0)
                scheduleS.append(twel)
            case "12 PM":
                let twel = ScheduleSession(id: i, time: "12 PM", sun: true, mon: false, tue: false, wed: false, thu: false, fri: true, sat: true, session: 1)
                scheduleS.append(twel)
            case "1 PM":
                let twel = ScheduleSession(id: i, time: "1 PM", sun: true, mon: false, tue: true, wed: true, thu: false, fri: true, sat: true, session: 1)
                scheduleS.append(twel)
            case "2 PM":
                let twel = ScheduleSession(id: i, time: "2 PM", sun: true, mon: false, tue: true, wed: true, thu: false, fri: true, sat: true, session: 1)
                scheduleS.append(twel)
            case "3 PM":
                let twel = ScheduleSession(id: i, time: "3 PM", sun: true, mon: false, tue: true, wed: true, thu: false, fri: true, sat: true, session: 2)
                scheduleS.append(twel)
            case "4 PM":
                let twel = ScheduleSession(id: i, time: "4 PM", sun: true, mon: false, tue: true, wed: true, thu: false, fri: true, sat: true, session: 2)
                scheduleS.append(twel)
            case "5 PM":
                let twel = ScheduleSession(id: i, time: "5 PM", sun: true, mon: false, tue: true, wed: true, thu: false, fri: true, sat: true, session: 2)
                scheduleS.append(twel)
            case "6 PM":
                let twel = ScheduleSession(id: i, time: "6 PM", sun: true, mon: false, tue: false, wed: false, thu: false, fri: true, sat: true, session: 1)
                scheduleS.append(twel)
            case "7 PM":
                let twel = ScheduleSession(id: i, time: "7 PM", sun: false, mon: false, tue: false, wed: false, thu: false, fri: false, sat: false, session: 0)
                scheduleS.append(twel)
            case "8 PM":
                let twel = ScheduleSession(id: i, time: "8 PM", sun: false, mon: false, tue: false, wed: false, thu: false, fri: false, sat: false, session: 0)
                scheduleS.append(twel)
            case "9 PM":
                let twel = ScheduleSession(id: i, time: "9 PM", sun: true, mon: true, tue: true, wed: true, thu: true, fri: true, sat: true, session: 1)
                scheduleS.append(twel)
            case "10 PM":
                let twel = ScheduleSession(id: i, time: "10 PM", sun: false, mon: false, tue: false, wed: false, thu: false, fri: false, sat: false, session: 0)
                scheduleS.append(twel)
            case "11 PM":
                let twel = ScheduleSession(id: i, time: "11 PM", sun: false, mon: false, tue: false, wed: false, thu: false, fri: false, sat: false, session: 0)
                scheduleS.append(twel)
            case "12 AM":
                let twel = ScheduleSession(id: i, time: "12 AM", sun: false, mon: false, tue: false, wed: false, thu: false, fri: false, sat: false, session: 0)
                scheduleS.append(twel)
            case "1 AM":
                let twel = ScheduleSession(id: i, time: "1 AM", sun: false, mon: false, tue: false, wed: false, thu: false, fri: false, sat: false, session: 0)
                scheduleS.append(twel)
            case "2 AM":
                let twel = ScheduleSession(id: i, time: "2 AM", sun: false, mon: false, tue: false, wed: false, thu: false, fri: false, sat: false, session: 0)
                scheduleS.append(twel)
            case "3 AM":
                let twel = ScheduleSession(id: i, time: "3 AM", sun: false, mon: false, tue: false, wed: false, thu: false, fri: false, sat: false, session: 0)
                scheduleS.append(twel)
            case "4 AM":
                let twel = ScheduleSession(id: i, time: "4 AM", sun: false, mon: false, tue: false, wed: false, thu: false, fri: false, sat: false, session: 0)
                scheduleS.append(twel)
            default:
                break
            }
        }
        return scheduleS
    }
}

struct ScheduleSession {
    var id: Int?
    var time: String?
    var sun: Bool
    var mon: Bool
    var tue: Bool
    var wed: Bool
    var thu: Bool
    var fri: Bool
    var sat: Bool
    var session: Int
}

enum ScheduleType: Int {
    case none
    case reminder
    case schedule_focus
}
