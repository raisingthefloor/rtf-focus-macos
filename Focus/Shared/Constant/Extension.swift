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
import Foundation

extension NSView {
    var bgColor: NSColor? {
        get {
            if let colorRef = layer?.backgroundColor {
                return NSColor(cgColor: colorRef)
            } else {
                return nil
            }
        }

        set {
            wantsLayer = true
            layer?.backgroundColor = newValue?.cgColor
        }
    }
}

extension NSTextField {
    func addUnderline() {
        let attributes: [NSAttributedString.Key: Any] = [.foregroundColor: Color.blue_color, .underlineStyle: NSUnderlineStyle.single.rawValue]
        attributedStringValue = NSAttributedString(string: stringValue, attributes: attributes)
    }
}

extension String {
    static func randomString(length: Int64 = 36) -> String {
        let letters = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqstuvwxyz0123456789"
        return String((0 ..< length).map { _ in letters.randomElement()! })
    }

//    var isValidUrl: Bool {
//        let urlRegEx = "((?:www\\.)?[\\w\\d\\-_]+\\.\\w{2,3}(\\.\\w{2})?(/(?<=/)(?:[\\w\\d\\-./_]+)?)?"
//        return NSPredicate(format: "SELF MATCHES %@", urlRegEx).evaluate(with: self)
//    }

    var isValidUrl: Bool {
        let urlRegEx = "((\\w|-)+)(([.]|[/])((\\w|-)+))+"
        let urlTest = NSPredicate(format: "SELF MATCHES %@", urlRegEx)
        let result = urlTest.evaluate(with: self)
        return result
    }

    func toDateComponent() -> DateComponents {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "hh a"
        let date = dateFormatter.date(from: self) ?? Date()
        let calendar = Calendar.current
        return calendar.dateComponents([.hour, .minute, .second, .weekday], from: date)
    }

    func toDateTime() -> Date? {
        let timeformatter = DateFormatter()
        timeformatter.dateFormat = "h a"
        let time = timeformatter.date(from: self)
        return time
    }

    func getTimeSlots(endTime: String, interval: Int = 60) -> [String] {
        var slots: [String] = []

        let formatter = DateFormatter()
        formatter.dateFormat = "h a"

        let formatter2 = DateFormatter()
        formatter2.dateFormat = "h a"

        let startDate = self
        slots.append(self)
        let endDate = endTime

        let date1 = formatter.date(from: startDate)
        let date2 = formatter.date(from: endDate)

        var i = 1
        while true {
            let date = date1?.addingTimeInterval(TimeInterval(i * interval * 60))
            let string = formatter2.string(from: date!)

            if date! >= date2! {
                break
            }

            i += 1
            slots.append(string)
        }
        slots.append(endTime)
        return slots
    }
}

extension Bundle {
    static func bundleIDFor(appNamed appName: String) -> String? {
        if let appPath = NSWorkspace.shared.fullPath(forApplication: appName) {
            if let itsBundle = Bundle(path: appPath) {
                if let itsID = itsBundle.bundleIdentifier {
                    return itsID
                }
            } else {
                if let ownID = Bundle.main.bundleIdentifier {
                    return ownID
                }
            }
        }
        return nil
    }
}

public extension NSView {
    var border_color: NSColor? {
        get {
            guard let color = layer?.borderColor else { return nil }
            return NSColor(cgColor: color)
        }
        set {
            wantsLayer = true
            layer?.borderColor = newValue?.cgColor
        }
    }

    var border_width: CGFloat {
        get {
            return layer?.borderWidth ?? 0
        }
        set {
            wantsLayer = true
            layer?.borderWidth = newValue
        }
    }

    var corner_radius: CGFloat {
        get {
            return layer?.cornerRadius ?? 0
        }
        set {
            wantsLayer = true
            layer?.masksToBounds = true
            layer?.cornerRadius = newValue.magnitude
        }
    }

    var height: CGFloat {
        get {
            return frame.size.height
        }
        set {
            frame.size.height = newValue
        }
    }

    var shadowColor: NSColor? {
        get {
            guard let color = layer?.shadowColor else { return nil }
            return NSColor(cgColor: color)
        }
        set {
            wantsLayer = true
            layer?.shadowColor = newValue?.cgColor
        }
    }

    var shadowOffset: CGSize {
        get {
            return layer?.shadowOffset ?? CGSize.zero
        }
        set {
            wantsLayer = true
            layer?.shadowOffset = newValue
        }
    }

    var shadowOpacity: Float {
        get {
            return layer?.shadowOpacity ?? 0
        }
        set {
            wantsLayer = true
            layer?.shadowOpacity = newValue
        }
    }

    var shadowRadius: CGFloat {
        get {
            return layer?.shadowRadius ?? 0
        }
        set {
            wantsLayer = true
            layer?.shadowRadius = newValue
        }
    }

    var background_color: NSColor? {
        get {
            if let colorRef = layer?.backgroundColor {
                return NSColor(cgColor: colorRef)
            } else {
                return nil
            }
        }
        set {
            wantsLayer = true
            layer?.backgroundColor = newValue?.cgColor
        }
    }

    var size: CGSize {
        get {
            return frame.size
        }
        set {
            width = newValue.width
            height = newValue.height
        }
    }

    var width: CGFloat {
        get {
            return frame.size.width
        }
        set {
            frame.size.width = newValue
        }
    }
}

// MARK: - Methods

public extension NSView {
    func addSubviews(_ subviews: [NSView]) {
        subviews.forEach { addSubview($0) }
    }

    func removeSubviews() {
        subviews.forEach { $0.removeFromSuperview() }
    }
}

extension NSColor {
    class var random: NSColor { return colors[Int(arc4random_uniform(UInt32(colors.count)))] }
}

extension NSTableView {
    func reloadDataKeepingSelection() {
        let selectedRowIndexes = self.selectedRowIndexes
        reloadData()
        selectRowIndexes(selectedRowIndexes, byExtendingSelection: false)
    }
}

extension Date {
    static func getDayName() -> String {
        let date = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEE"
        let dayInWeek = dateFormatter.string(from: date)
        return dayInWeek
    }

    func adding(hour: Int, min: Int, sec: Int) -> Date {
        var comps = DateComponents()
        comps.hour = hour
        comps.minute = min
        comps.second = sec
        let cal = NSCalendar.current
        return cal.date(byAdding: comps, to: self) ?? Date()
    }

    func convertToTime() -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        formatter.dateStyle = .none
        return formatter.string(from: self)
    }

    func dayOfWeek() -> String? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE"
        return dateFormatter.string(from: self).capitalized
    }

    func currentTime() -> String? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "h:mm a"
        return dateFormatter.string(from: self).capitalized
    }

    func dayNumberOfWeek() -> Int {
        let weekday: Int = Calendar.current.component(.weekday, from: self) - Calendar.current.firstWeekday
        return weekday
    }

    func currentDateComponent() -> DateComponents {
        return Calendar.current.dateComponents([.hour, .minute, .second, .weekday], from: self)
    }
}

extension Int {
    func secondsToTime() -> (timeInHours: Int, timeInMinutes: Int, timeInSeconds: Int) {
        let hours = Int(Double((self / 60) / 60).rounded(.towardZero))
        var min = self / 60
        var sec = self % 60
        if hours > 0 {
            min = hours / 60
            sec = hours % 60
        }
        return (timeInHours: hours, timeInMinutes: min, timeInSeconds: sec)
    }
}

extension Array where Element: Hashable {
    func difference(from other: [Element]) -> [Element] {
        let thisSet = Set(self)
        let otherSet = Set(other)
        return Array(thisSet.subtracting(otherSet))
    }
}

extension Sequence where Iterator.Element: Hashable {
    func unique() -> [Iterator.Element] {
        var seen: [Iterator.Element: Bool] = [:]
        return filter { seen.updateValue(true, forKey: $0) == nil }
    }
}
