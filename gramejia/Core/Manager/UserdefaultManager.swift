//
//  UserdefaultManager.swift
//  gramejia
//
//  Created by Adam on 15/12/24.
//

import Foundation

enum UserDefaultsKey: String {
    case isSignedIn
    case isFirstTime
    case currentUsername
    case currentUserFullname
    case userLevel
}

class UserDefaultsManager {
    
    static let shared = UserDefaultsManager()
    private let defaults = UserDefaults.standard
    
    // Generic method to save a value
    func set<T>(value: T, forKey key: UserDefaultsKey) {
        defaults.set(value, forKey: key.rawValue)
    }
    
    // Generic method to retrieve a value
    func get<T>(forKey key: UserDefaultsKey) -> T? {
        return defaults.object(forKey: key.rawValue) as? T
    }
    
    // Method to remove a value
    func remove(forKey key: UserDefaultsKey) {
        defaults.removeObject(forKey: key.rawValue)
    }
    
    // Method to check if a key exists
    func contains(key: UserDefaultsKey) -> Bool {
        return defaults.object(forKey: key.rawValue) != nil
    }
}
