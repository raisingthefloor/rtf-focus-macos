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
    func getSessionList(day: Int?) -> [Focus_Schedule]
    func generateCalendarSession(day: Int?) -> [ScheduleSession]
//    func generateCalendarSession() -> [ScheduleSession]
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
    func getSessionList(day: Int?) -> [Focus_Schedule] {
        return DBManager.shared.getScheduleFocus(time: "", day: day)
    }

    func generateCalendarSession(day: Int?) -> [ScheduleSession] {
        var arrScheduleS: [ScheduleSession] = []

        for i in 0 ..< arrTimes.count {
            let arrInnerFS = DBManager.shared.getScheduleFocus(time: arrTimes[i], day: day)

            if arrInnerFS.isEmpty {
                let isExist = arrScheduleS.compactMap({ $0.time == arrTimes[i] }).filter({ $0 }).first ?? false
                if !isExist {
                    let objNewSS = ScheduleSession(time: arrTimes[i], days: [])
                    arrScheduleS.append(objNewSS)
                }
                continue
            }
            for obj in arrInnerFS {
                if let days = obj.days_?.allObjects as? [Focus_Schedule_Days], !days.isEmpty {
                    let color = NSColor(obj.session_color ?? "#DCEFE6") ?? .red
                    let color_type: ColorType = ColorType(rawValue: Int(obj.color_type)) ?? .solid

                    guard let start_time = obj.start_time,!start_time.isEmpty, let end_time = obj.end_time, !end_time.isEmpty else { continue }
                    let arrTSlot: [String] = start_time.getTimeSlots(endTime: end_time)
                    print("****** Time Slots ****** \(arrTSlot)")

                    for time in arrTSlot {
                        let isExist = arrScheduleS.compactMap({ $0.time == time }).filter({ $0 }).first ?? false
                        let objNewSS = ScheduleSession(time: time, days: [])
                        let objSS = arrScheduleS.filter({ $0.time == time }).compactMap({ $0 }).first ?? objNewSS
                        var objMutableSS = isExist ? objSS : objNewSS
                        var arrScheduleDays: [ScheduleDay] = []

                        for objDay in days {
                            let day = objDay.day
                            let day_e = Days(rawValue: Int(day)) ?? .sun
                            var s_days = objMutableSS.days
                            let no_session = 1

                            if var sDay = s_days.filter({ $0.day == day_e && $0.time == time }).compactMap({ $0 }).last {
//                                print("IF Condition  Schedule Day ::   \(sDay)")

                                if sDay.noOfsession == 1 {
                                    sDay.colors.append(color)
                                    sDay.color_type.append(color_type)
                                    sDay.ids.append(obj.id)
                                }
                                sDay.noOfsession = 2
                                sDay.time = time
                                if let index = s_days.firstIndex(where: { $0.day == day_e && $0.time == time }) {
                                    s_days[index] = sDay
                                }
                                objMutableSS.days = s_days
                            } else {
                                let scheduleDay = ScheduleDay(isActive: true, noOfsession: no_session, colors: [color], day: day_e, color_type: [color_type], time: time, ids: [obj.id])

//                                print("ELSE Condition NEW Data :::::::::::: \(scheduleDay)  ::::::::: \(objMutableSS.time) ::::::: \(day_e)")
                                arrScheduleDays.append(scheduleDay)
                            }
                        }

                        objMutableSS.days = arrScheduleDays + objMutableSS.days

                        if !isExist {
                            arrScheduleS.append(objMutableSS)
                        } else {
                            if let index = arrScheduleS.firstIndex(where: { $0.time == objMutableSS.time }) {
                                arrScheduleS[index] = objMutableSS
                            }
                        }
                    }
                }
            }
        }
        return arrScheduleS
    }
}

struct ScheduleSession {
    var time: String
    var days: [ScheduleDay]
}

struct ScheduleDay {
    var isActive: Bool
    var noOfsession: Int
    var colors: [NSColor]
    var day: Days
    var color_type: [ColorType]
    var time: String
    var ids: [UUID?]
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

    var identifier: TableIdentifier {
        switch self {
        case .sun:
            return .sunIdentifier
        case .mon:
            return .monIdentifier
        case .tue:
            return .tueIdentifier
        case .wed:
            return .wedIdentifier
        case .thu:
            return .thuIdentifier
        case .fri:
            return .friIdentifier
        case .sat:
            return .satIdentifier
        }
    }

    static let allDays: [Days] = [.sun, .mon, .tue, .wed, .thu, .fri, .sat]
}

enum TableIdentifier: String {
    case sunIdentifier
    case monIdentifier
    case tueIdentifier
    case wedIdentifier
    case thuIdentifier
    case friIdentifier
    case satIdentifier
    case dayIdentifier

    var color: NSColor {
        switch self {
        case .sunIdentifier, .tueIdentifier, .thuIdentifier, .satIdentifier, .dayIdentifier:
            return Color.tbl_header_color
        default:
            return Color.time_slot_color
        }
    }
}
