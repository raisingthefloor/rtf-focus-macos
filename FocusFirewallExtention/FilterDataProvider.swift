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

import NetworkExtension
import os.log

class FilterDataProvider: NEFilterDataProvider {
    static let filteredApps: Set = ["firefox"]
    var block_sites: [String] = []

    override func startFilter(completionHandler: @escaping (Error?) -> Void) {
        // block_sites = IPCConnection.getBlockURLs()

        IPCConnection.shared.getBlockURLs { urls in
            os_log("urls BHAVI %{public}@", urls)

            self.block_sites = urls
            os_log("block_sites BHAVI %{public}@", self.block_sites)

            let filterRules = self.block_sites.map { address -> NEFilterRule in
                let remoteNetwork = NWHostEndpoint(hostname: address, port: "0")
                let networkRule = NENetworkRule(destinationHost: remoteNetwork, protocol: .any)
                return NEFilterRule(networkRule: networkRule, action: .filterData)
            }

            let filterSettings = NEFilterSettings(rules: filterRules, defaultAction: .allow)

            self.apply(filterSettings) { error in
                if let applyError = error {
                    os_log("Failed to apply filter settings: %@", applyError.localizedDescription)
                }
                completionHandler(error)
            }
        }
    }

    override func stopFilter(with reason: NEProviderStopReason, completionHandler: @escaping () -> Void) {
        // Add code to clean up filter resources.
        completionHandler()
    }

    override func handleNewFlow(_ flow: NEFilterFlow) -> NEFilterNewFlowVerdict {
        // Add code to determine if the flow should be dropped or not, downloading new rules if required.
        guard isFiltered(description: flow.description) else {
            return .allow()
        }
        return .drop()
    }
}

extension FilterDataProvider {
    func isFiltered(description: String) -> Bool {
        guard let sourceAppIdentifier = description.matches(for: #"(?<=sourceAppIdentifier = ).+?(?=\s)"#).first, let data = sourceAppIdentifier.components(separatedBy: ".").last else {
            os_log("sourceAppIdentifier false: %{public}@", description)
            return false
        }
        os_log("BHAVI sourceAppIdentifier true: %{public}@", sourceAppIdentifier)

        os_log("BHAVI sourceAppIdentifier true: %{public}@", data)

        os_log("BHAVI sourceAppIdentifier isFiltered: %{public}d", FilterDataProvider.filteredApps.contains(data))

        return FilterDataProvider.filteredApps.contains(data)
    }
}

extension String {
    func matches(for regex: String) -> [String] {
        do {
            let regex = try NSRegularExpression(pattern: regex)
            let results = regex.matches(in: self, range: NSRange(startIndex..., in: self))
            return results.map {
                String(self[Range($0.range, in: self)!])
            }
        } catch {
            return []
        }
    }
}
