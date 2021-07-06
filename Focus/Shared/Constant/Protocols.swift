//
//  Protocols.swift
//  Plenar
//
//  Created by Hardik-Mac on 4/22/19.
//  Copyright © 2019 Plenar. All rights reserved.
//
import CoreData
import Foundation
import RxCocoa
import RxSwift
import Cocoa

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
