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
//    var arrTimes: [String] { get set }
    var objGCategory: Block_Category? { get set }
}

class ScheduleViewModel: ScheduleViewModelIntput, ScheduleViewModelOutput, ScheduleViewModelType {
    var input: ScheduleViewModelIntput { return self }
    var output: ScheduleViewModelOutput { return self }

    static var arrTimes: [String] = ["12 AM", "1 AM", "2 AM", "3 AM", "4 AM", "5 AM", "6 AM", "7 AM", "8 AM", "9 AM", "10 AM", "11 AM", "12 PM", "1 PM", "2 PM", "3 PM", "4 PM", "5 PM", "6 PM", "7 PM", "8 PM", "9 PM", "10 PM", "11 PM"]

    var arrFocusSchedule: [Focus_Schedule] = []
    var objGCategory: Block_Category?

    init() {
        arrFocusSchedule = DBManager.shared.getFocusSchedule()
        objGCategory = DBManager.shared.getGeneralCategoryData().gCat
    }

    static func isRunning(objFS: Focus_Schedule?) -> Bool {
        guard let objF = DBManager.shared.getCurrentSession(), let focuslist = objF.focuses?.allObjects as? [Focus_List], let id = objFS?.block_list_id, let focus_schedule_id = objFS?.id else { return false }
        let isSame = focuslist.compactMap({ $0.block_list_id == id && $0.focus_schedule_id == focus_schedule_id }).filter({ $0 }).first ?? false
        return isSame
    }
}

// Methods for Displaying the data on Calendar view.
extension ScheduleViewModel {
    func getSessionList(day: Int?) -> [Focus_Schedule] {
        return DBManager.shared.getScheduleFocus(time: "", day: day)
    }

    func generateCalendarSession(day: Int?) -> [ScheduleSession] {
        var arrScheduleS: [ScheduleSession] = []
        let arrTimes = ScheduleViewModel.arrTimes

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
                if let days = obj.days_?.allObjects as? [Focus_Schedule_Days], !days.isEmpty, let fs_id = obj.id {
                    let color = NSColor(obj.session_color ?? "#DCEFE6") ?? .red
                    let color_type: ColorType = ColorType(rawValue: Int(obj.color_type)) ?? .solid

                    guard let start_time = obj.start_time,!start_time.isEmpty, let end_time = obj.end_time, !end_time.isEmpty else { continue }
                    let arrTSlot: [String] = start_time.getTimeSlots(endTime: end_time)
//                    print("****** Time Slots ****** \(arrTSlot)")

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
                                print("ids ::::: \(sDay.ids)  ===== fs_id \(fs_id)")
                                if !(sDay.ids.compactMap({ $0 == fs_id }).last ?? false) {
                                    print("********************** Session Two ********************** :::: Time \(time)  Day :::\(day_e.identifier)")
                                    if sDay.noOfsession == 1 {
                                        print(" Session one convert to Two")
                                        sDay.colors.append(color)
                                        sDay.color_type.append(color_type)
                                        sDay.ids.append(fs_id)
                                    } else {
                                        sDay.colors[0] = color
                                        sDay.color_type[0] = color_type
//                                    sDay.ids[0] = fs_id
                                        for indexJ in 0 ..< sDay.ids.count where sDay.ids[indexJ] == fs_id {
                                            if sDay.colors.count <= 2 {
                                                sDay.colors.insert(color, at: indexJ)
                                                sDay.color_type.insert(color_type, at: indexJ)
//                                            scheduleDay.color_type.removeLast()
//                                            scheduleDay.colors.removeLast()
                                            }
                                        }
                                    }
                                    sDay.noOfsession = 2
                                    sDay.time = time

                                    if let index = s_days.firstIndex(where: { $0.day == day_e && $0.time == time }) {
                                        s_days[index] = sDay
                                    }
                                    objMutableSS.days = s_days
                                }
                            } else {
                                print("********************** Session One ********************** :::: Time \(time) Day :::\(day_e.identifier)")
                                var scheduleDay = ScheduleDay(isActive: true, noOfsession: no_session, colors: [color], day: day_e, color_type: [color_type], time: time, ids: [fs_id])

                                let arrIds = arrScheduleS.compactMap({ $0.days.filter({ $0.noOfsession == 2 }).compactMap({ $0.ids.map({ $0 }) }).unique().first }).unique()

                                let arrUDIDs = arrIds.flatMap({ $0 }).unique()

                                for indexJ in 0 ..< arrUDIDs.count where arrUDIDs[indexJ] == fs_id {
                                    print("********************** Has SessionTwo ********************** :::: Time \(time) Day :::\(day_e.identifier)")
                                    scheduleDay.noOfsession = 2
                                    scheduleDay.colors = [.clear, color]
                                    scheduleDay.color_type = [color_type, color_type]

                                    for ids in arrIds {
//                                        print("********************** Hase SessionTwo ********************** :::: arrIds \(arrIds)")

                                        for indexJ in 0 ..< ids.count where ids[indexJ] == fs_id {
                                            if scheduleDay.colors.count <= 2 && scheduleDay.ids.count == 2 {
                                                print("********************** Has SessionTwo ********************** :::: Time \(time) Count: \(scheduleDay.colors.count) :::::: index : \(indexJ) Day :::\(day_e.identifier)")
                                                scheduleDay.noOfsession = 2
                                                scheduleDay.colors.insert(color, at: indexJ)
                                                scheduleDay.color_type.insert(color_type, at: indexJ)
                                                scheduleDay.color_type.removeLast()
                                                scheduleDay.colors.removeLast()
                                            }
                                        }
                                    }
                                }

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
    var ids: [UUID]
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
