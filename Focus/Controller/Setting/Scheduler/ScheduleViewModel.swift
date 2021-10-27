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
    func getSessionList(day: Int?) -> ([ScheduleSession], [Focus_Schedule])
//    func setReminder(obj: Focus_Schedule?)
//    func removeReminder(obj: Focus_Schedule?)
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
}

// Methods for Displaying the data on Calendar view.
extension ScheduleViewModel {
    func getSessionList(day: Int?) -> ([ScheduleSession], [Focus_Schedule]) {
        var scheduleS: [ScheduleSession] = []
        let arrFS: [Focus_Schedule] = DBManager.shared.getScheduleFocus(time: "", day: day)
        for i in 0 ..< arrTimes.count {
            let arrInnerFS = DBManager.shared.getScheduleFocus(time: arrTimes[i], day: day)

            print("Session data session_color: \(arrInnerFS.compactMap({ $0.session_color }))")
            print("Session data Count: \(arrInnerFS.count)")

            var twel = ScheduleSession(id: i, time: arrTimes[i], sun: (false, 0, [.clear, .clear]), mon: (false, 0, [.clear, .clear]),
                                       tue: (false, 0, [.clear, .clear]), wed: (false, 0, [.clear, .clear]), thu: (false, 0, [.clear, .clear]),
                                       fri: (false, 0, [.clear, .clear]), sat: (false, 0, [.clear, .clear]), session: arrInnerFS.count,
                                       color: [.clear, .clear], color_type: [.solid, .solid])
            if arrInnerFS.isEmpty {
                scheduleS.append(twel)
                continue
            }

            let arrDay_ = arrInnerFS.compactMap({ $0.days_?.allObjects as? [Focus_Schedule_Days] }).reduce([],+).compactMap({ Int($0.day) })
            print("days :\(arrDay_)")

            let intersectData = Array(Set(arrDay_.filter({ (i: Int) in arrDay_.filter({ $0 == i }).count > 1 })))
            print("intersectData :\(intersectData)")
            let differentVals = Array(Set(intersectData).symmetricDifference(Set(arrDay_)))
            print("differentVals :\(differentVals)")

            var colors = arrInnerFS.compactMap({ NSColor($0.session_color ?? "#DCEFE6") })
            twel.color_type = arrInnerFS.compactMap({ ColorType(rawValue: Int($0.color_type)) })

            if !intersectData.isEmpty {
                print("intersectData colors  :: \(colors)")
                for day in intersectData {
                    let d = Int(day)
                    let day_e = Days(rawValue: d)
                    switch day_e {
                    case .sun:
                        twel.sun = (true, 2, colors)
                    case .mon:
                        twel.mon = (true, 2, colors)
                    case .tue:
                        twel.tue = (true, 2, colors)
                    case .wed:
                        twel.wed = (true, 2, colors)
                    case .thu:
                        twel.thu = (true, 2, colors)
                    case .fri:
                        twel.fri = (true, 2, colors)
                    case .sat:
                        twel.sat = (true, 2, colors)
                    case .none:
                        break
                    }
                }
            }

            if !differentVals.isEmpty {
                print("Differently colors  :: \(colors)")
                for day in differentVals {
                    let d = Int(day)
                    let day_e = Days(rawValue: d)
                    switch day_e {
                    case .sun:
                        twel.sun = (true, 1, colors)
                    case .mon:
                        twel.mon = (true, 1, colors)
                    case .tue:
                        twel.tue = (true, 1, colors)
                    case .wed:
                        twel.wed = (true, 1, colors)
                    case .thu:
                        twel.thu = (true, 1, colors)
                    case .fri:
                        twel.fri = (true, 1, colors)
                    case .sat:
                        twel.sat = (true, 1, colors)
                    case .none:
                        break
                    }
                }
            }

            scheduleS.append(twel)
        }
        return (scheduleS, arrFS)
    }
}

// Not Used the For Now as its Localnotification Methods to perform the reminder
// extension ScheduleViewModel {
//    func setReminder(obj: Focus_Schedule?) {
//        guard let objF = obj, let uuid = objF.id, let id = objF.id?.uuidString, let startTime = objF.start_time else { return }
//
//        var arrDays: [String] = objF.days?.components(separatedBy: ",") ?? []
//        arrDays = arrDays.filter({ $0 != "" }).compactMap({ $0 })
//        if !arrDays.isEmpty {
//            print("Set Reminder")
//            var dateComponents = startTime.toDateComponent()
//            dateComponents.minute = (Date().currentDateComponent().minute ?? 0) + 2
//            print("DateComponents : === \(dateComponents)")
//
//            print("Days : === \(arrDays)")
//
//            let identifiers = arrDays.map({ (id + "_" + $0) })
//            print("identifiers : === \(identifiers)")
//
//            NotificationManager.shared.removePendingNotificationRequests(identifiers: identifiers)
//            for i in arrDays {
//                let identifier = id + "_" + i
//                dateComponents.weekday = Int(i) ?? 0
//                NotificationManager.shared.setLocalNotification(info: LocalNotificationInfo(title: "Focus Reminder", body: "You asked to be reminded to focus at this time.", dateComponents: dateComponents, identifier: identifier, uuid: uuid, repeats: true))
//            }
//        }
//    }
//
//    func removeReminder(obj: Focus_Schedule?) {
//        guard let objF = obj, let id = objF.id?.uuidString else { return }
//        let arrDays = objF.days?.components(separatedBy: ",") ?? []
//        let identifiers = arrDays.map({ (id + "_" + $0) })
//        print("Remove identifiers \(identifiers)")
//        NotificationManager.shared.removePendingNotificationRequests(identifiers: identifiers)
//    }
// }

struct ScheduleSession {
    var id: Int?
    var time: String?
    var sun: (Bool, Int, colors: [NSColor])
    var mon: (Bool, Int, colors: [NSColor])
    var tue: (Bool, Int, colors: [NSColor])
    var wed: (Bool, Int, colors: [NSColor])
    var thu: (Bool, Int, colors: [NSColor])
    var fri: (Bool, Int, colors: [NSColor])
    var sat: (Bool, Int, colors: [NSColor])
    var session: Int
    var color: [NSColor]
    var color_type: [ColorType]
}

enum ScheduleType: Int {
    case none
    case reminder
    case schedule_focus
}

enum Days: Int {
    case sun = 1
    case mon
    case tue
    case wed
    case thu
    case fri
    case sat
}
