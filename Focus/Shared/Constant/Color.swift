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

struct Color {
    static let light_blue_color = NSColor("#D8E2F3") ?? .systemBlue
    static let green_color = NSColor("#095930") ?? .systemGreen
    static let red_color = NSColor("#C00500") ?? .systemRed
    static let navy_blue_color = NSColor("#002957") ?? .clear
    static let info_blue_color = NSColor("#3566D8") ?? .systemBlue
    static let light_green_color = NSColor("#DCEFE6") ?? .systemGreen.withAlphaComponent(0.5)
    static let very_light_grey = NSColor("#F0F2F5") ?? .lightGray.withAlphaComponent(0.5)
    static let dark_grey_border = NSColor("#4c4c4c") ?? .darkGray.withAlphaComponent(0.8)
    static let blue_color = NSColor("#3566D8") ?? .blue
    static let black_color = NSColor("#333333") ?? .black
    static let txt_grey_color = NSColor("#555555") ?? .lightGray.withAlphaComponent(0.5)
    static let txt_green_color = NSColor("#095930") ?? .systemGreen
    static let selected_row_color = NSColor("#3a7a59") ?? .systemGreen
    static let list_bg_color = NSColor("#F1F1F1") ?? .systemGreen.withAlphaComponent(0.3)
    static let top_title_green_color = NSColor("#008145") ?? .systemGreen.withAlphaComponent(0.3)
    static let edit_bg_color = NSColor("#F4F8FF") ?? .blue.withAlphaComponent(0.3)
    static let note_color = NSColor("#8C191B") ?? .brown
    static let tbl_header_color = NSColor("#EBF2FF") ?? .blue.withAlphaComponent(0.2)

    static let schedule_one_color = NSColor("#662261") ?? .magenta.withAlphaComponent(0.2)
    static let schedule_two_color = NSColor("#0080A8") ?? .systemYellow.withAlphaComponent(0.2)
    static let schedule_three_color = NSColor("#002957") ?? .black.withAlphaComponent(0.2)
    static let schedule_four_color = NSColor("#3566D8") ?? .magenta.withAlphaComponent(0.2)
    static let schedule_five_color = NSColor("#008145") ?? .systemGreen.withAlphaComponent(0.2)
    static let main_bg_color = NSColor("#FCFDFF") ?? .blue.withAlphaComponent(0.3)
    static let dialogue_bg_color = NSColor("#FAFCFF") ?? .blue.withAlphaComponent(0.1)
    static let day_selected_color = NSColor("#3566D8") ?? .blue
    static let day_deselected_color = NSColor("#666666") ?? .darkGray
    static let deselected_row_schedule = NSColor("#FAFCFF") ?? .lightGray.withAlphaComponent(0.3)
    static let selected_row_schedule = NSColor("#fafcff") ?? .lightGray.withAlphaComponent(0.3)
    static let time_slot_color = NSColor("#F5F9FF") ?? .blue.withAlphaComponent(0.1)
}

extension NSColor {
    typealias Hex = String

    convenience init?(_ hex: Hex, alpha: CGFloat? = nil) {
        guard let hexType = Type(from: hex), let components = hexType.components() else {
            return nil
        }

        #if os(watchOS)
            self.init(red: components.red, green: components.green, blue: components.blue, alpha: alpha ?? components.alpha)
        #else
            self.init(calibratedRed: components.red, green: components.green, blue: components.blue, alpha: alpha ?? components.alpha)
        #endif
    }

    /// The string hex value representation of the current color
    var hex: Hex {
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0, rgb: Int
        getRed(&r, green: &g, blue: &b, alpha: &a)

        if a == 1 { // no alpha value set, we are returning the short version
            rgb = (Int)(r * 255) << 16 | (Int)(g * 255) << 8 | (Int)(b * 255) << 0
            return String(format: "#%06x", rgb)
        } else {
            rgb = (Int)(r * 255) << 24 | (Int)(g * 255) << 16 | (Int)(b * 255) << 8 | (Int)(a * 255) << 0
            return String(format: "#%08x", rgb)
        }
    }

    private enum `Type` {
        case RGBshort(rgb: Hex)
        case RGBshortAlpha(rgba: Hex)
        case RGB(rgb: Hex)
        case RGBA(rgba: Hex)

        init?(from hex: Hex) {
            var hexString = hex
            hexString.removeHashIfNecessary()

            guard let t = Type.transform(hex: hexString) else {
                return nil
            }

            self = t
        }

        static func transform(hex string: Hex) -> Type? {
            switch string.count {
            case 3:
                return .RGBshort(rgb: string)
            case 4:
                return .RGBshortAlpha(rgba: string)
            case 6:
                return .RGB(rgb: string)
            case 8:
                return .RGBA(rgba: string)
            default:
                return nil
            }
        }

        var value: Hex {
            switch self {
            case let .RGBshort(rgb):
                return rgb
            case let .RGBshortAlpha(rgba):
                return rgba
            case let .RGB(rgb):
                return rgb
            case let .RGBA(rgba):
                return rgba
            }
        }

        typealias rgbComponents = (red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat)
        func components() -> rgbComponents? {
            var hexValue: UInt32 = 0
            guard Scanner(string: value).scanHexInt32(&hexValue) else {
                return nil
            }

            let r, g, b, a, divisor: CGFloat

            switch self {
            case .RGBshort:
                divisor = 15
                r = CGFloat((hexValue & 0xF00) >> 8) / divisor
                g = CGFloat((hexValue & 0x0F0) >> 4) / divisor
                b = CGFloat(hexValue & 0x00F) / divisor
                a = 1
            case .RGBshortAlpha:
                divisor = 15
                r = CGFloat((hexValue & 0xF000) >> 12) / divisor
                g = CGFloat((hexValue & 0x0F00) >> 8) / divisor
                b = CGFloat((hexValue & 0x00F0) >> 4) / divisor
                a = CGFloat(hexValue & 0x000F) / divisor
            case .RGB:
                divisor = 255
                r = CGFloat((hexValue & 0xFF0000) >> 16) / divisor
                g = CGFloat((hexValue & 0x00FF00) >> 8) / divisor
                b = CGFloat(hexValue & 0x0000FF) / divisor
                a = 1
            case .RGBA:
                divisor = 255
                r = CGFloat((hexValue & 0xFF000000) >> 24) / divisor
                g = CGFloat((hexValue & 0x00FF0000) >> 16) / divisor
                b = CGFloat((hexValue & 0x0000FF00) >> 8) / divisor
                a = CGFloat(hexValue & 0x000000FF) / divisor
            }

            return (red: r, green: g, blue: b, alpha: a)
        }
    }
}

private extension String {
    mutating func removeHashIfNecessary() {
        if hasPrefix("#") {
            self = replacingOccurrences(of: "#", with: "")
        }
    }
}
