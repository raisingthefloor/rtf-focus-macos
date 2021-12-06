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

class CSVParser {
    static var shared = CSVParser()

    private func readDataFromCSV(fileName: String, fileType: String) -> [String] {
        guard let filepath = Bundle.main.path(forResource: fileName, ofType: fileType) else { return [] }
        var contents = ""
        do {
            contents = try String(contentsOfFile: filepath)
        } catch {
            print("File Read Error for file \(filepath)")
            return []
        }
        // now split that string into an array of "rows" of data.  Each row is a string.
        let rows = contents.components(separatedBy: "\n")

        // if you have a header row, remove it here
//        rows.removeFirst()
        return rows
    }

    private func prepareDictData(rows: [String]) -> [[String: Any?]] {
        var arrData: [[String: Any?]] = []
        // now loop around each row, and split it into each of its columns
        for row in rows {
            let columns = row.components(separatedBy: ",")
            // check that we have enough columns
            if columns.count == 3 {
                let url = columns[0]
                let name = columns[1]
                let block_type = Int(columns[2].replacingOccurrences(of: "\r", with: "")) ?? 1
                let c_date = Date()

                let bType = BlockType(rawValue: block_type)
                if bType == .web {
                    let web_data: [String: Any?] = ["name": name, "url": url, "created_at": c_date, "block_type": BlockType.web.rawValue]
                    arrData.append(web_data)
                } else {
                    if let bundleName = Bundle.bundleIDFor(appNamed: name) {
                        if let path = NSWorkspace.shared.absolutePathForApplication(withBundleIdentifier: bundleName) {
                            let app_data: [String: Any?] = ["name": name, "app_identifier": bundleName, "app_icon_path": path, "created_at": Date(), "block_type": BlockType.application.rawValue, "url": path]
                            arrData.append(app_data)
                        }
                    } else {
                        let app_data: [String: Any?] = ["name": name, "app_identifier": name, "app_icon_path": "", "created_at": Date(), "block_type": BlockType.application.rawValue, "url": ""]
                        arrData.append(app_data)
                    }
                }
            }
        }
        return arrData
    }

    func getDataInDictionary(fileName: String, fileType: String) -> [[String: Any?]] {
        let arrRows = readDataFromCSV(fileName: fileName, fileType: fileType)
        let finalData = prepareDictData(rows: arrRows)
        return finalData
    }
}
