//
//  UserDefault.swift
//  Plenar
//
//  Created by Hardik Shah on 31/05/19.
//  Copyright © 2019 Plenar. All rights reserved.
//

import Foundation

final class UserDefaultsRepository<T> {
    // MARK: - Properties

    private let userDefaults: UserDefaults

    // MARK: - Initialization

    init(userDefaults: UserDefaults) {
        self.userDefaults = userDefaults
    }

    // MARK: - Public API

    func save(_ object: T, forKey key: String) {
        userDefaults.set(object, forKey: key)
        userDefaults.synchronize()
    }

    func get(forKey key: String) -> T? {
        guard let data = userDefaults.object(forKey: key) as? T else {
            return nil
        }
        return data
    }

    func delete(forKey key: String) {
        userDefaults.set(nil, forKey: key)
        userDefaults.synchronize()
    }
}
