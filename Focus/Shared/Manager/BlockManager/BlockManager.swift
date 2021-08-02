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

var authentication_rule = "com.raisingthefloor.hosts"
var host_file_location = "/private/etc/hosts"
var authorise_file = "sys.openfile.readwrite./private/etc/hosts"
var authorization_comment = "edit_rule"
var block_header = "## Focus Header ##"
var block_footer = "## Focus Footer ##"
var ip_address = "0.0.0.0"
var default_host_file_content = "##\n # Host Database\n #\n # localhost is used to configure the loopback interface\n # when the system is booting.  Do not change this entry.\n ##\n 127.0.0.1    localhost\n 255.255.255.255    broadcasthost\n ::1             localhost\n fe80::1%lo0    localhost\n\n"

struct hostData {
    var host: String
}

class BlockManager {
    static var shared = BlockManager()

    var hostfileData: [String] {
        return BlockManager.shared.readHostFile()
    }

    func loadHostFile(stringData: String) {
        AuthorizationManager.setup()

        let processInfo: ProcessInfo = ProcessInfo()
        processInfo.disableSuddenTermination()

        let stdIn: Pipe = Pipe()
        let hostsWriter = Process()
        hostsWriter.launchPath = "/usr/libexec/authopen"
        hostsWriter.arguments = ["-w", host_file_location]
        hostsWriter.standardInput = stdIn

        let writeStr = stringData // ["0.0.0.0 instagram.com", "0.0.0.0 www.instagram.com"].joined(separator: "\n")
        let writeData = Data(writeStr.utf8)
        let stdInHandle: FileHandle = stdIn.fileHandleForWriting
        stdInHandle.write(writeData)
        stdInHandle.closeFile()
        hostsWriter.launch()
        hostsWriter.waitUntilExit()
        processInfo.enableSuddenTermination()
    }

    func readHostFile() -> [String] {
        AuthorizationManager.setup()
        var fileData: [String] = []
        if let input = FileHandle(forReadingAtPath: host_file_location) {
            let scanner = DataScanner(source: input, delimiters: CharacterSet(charactersIn: ":\n"))

            print("User Database:")

            while let line: String = scanner.read() {
                // skip any comments
                fileData.append(line)
                print("------------------------------")
                print("line: \t\(line)")
//                if !line.hasPrefix("#") {
//                    if let valid: String = scanner.read() {
//                        print("------------------------------")
//                        print("line: \t\(line)")
//                        print("line: \t\(valid)")
//                    }
//                } else {
//                    print("Skiped Data: \t\(line)")
//                }
            }
            return fileData
        }
        return fileData
    }

    func resetHostFile() {
        let updatedData = hostfileData.filter({ !$0.hasPrefix(ip_address) }).map({ $0 })
        loadHostFile(stringData: updatedData.joined(separator: "\n"))
    }

    func removeBlockData(removeDomain: String) {
        let domain = ip_address + " " + removeDomain
        let updatedData = hostfileData.filter({ $0 != domain }).map({ $0 })
        loadHostFile(stringData: updatedData.joined(separator: "\n"))
    }

    func addDomainData(domain: String) {
        var updatedData = hostfileData
        if domain.hasPrefix("www") {
            let withPrefix = ip_address + " " + domain
            updatedData.append(withPrefix)
            let withoutPrefix = ip_address + " " + domain.replacingOccurrences(of: "www.", with: "")
            updatedData.append(withoutPrefix)
        } else {
            let withPrefix = ip_address + " " + "www." + domain
            updatedData.append(withPrefix)
            let withoutPrefix = ip_address + " " + domain
            updatedData.append(withoutPrefix)
        }

        loadHostFile(stringData: updatedData.joined(separator: "\n"))
    }
}
