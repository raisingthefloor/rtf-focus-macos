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
import CoreData
import Foundation
import RxCocoa
import RxSwift

protocol BasicEnumType {
    var title: String { get }
    var image: NSImage? { get }
}

protocol BasicSetupType {
    func setUpText()
    func setUpViews()
    func themeSetUp()
    func bindData()
}

extension BasicSetupType {
    func bindData() {}
    func themeSetUp() {}
}

extension BasicEnumType {
    var image: NSImage? {
        return nil
    }
}

protocol ActivityIndicatorProtocol {
    var is_animating: BehaviorRelay<Bool> { get set }
}

protocol ActivityIndicatorUpdateProtocol {
    var is_animating_Update: BehaviorRelay<Bool> { get set }
}

protocol ActivityIndicatorRemoveProtocol {
    var is_animating_delete: BehaviorRelay<Bool> { get set }
}

protocol ActivityIndicatorFetchProtocol {
    var is_animating_fetch: BehaviorRelay<Bool> { get set }
}

protocol RequestType {
    func toRequest() -> [String: Any?]
}

protocol ErrorHandlerProtocol {
    func onValidationError(_ error: ValidaterError)
}

extension ErrorHandlerProtocol {
    func onValidationError(_ error: ValidaterError) {}
}

protocol CleanObjectsData {
    static func clear(data: Any, context: NSManagedObjectContext)
}
