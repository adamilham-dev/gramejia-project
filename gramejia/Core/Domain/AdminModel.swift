//
//  File.swift
//  gramejia
//
//  Created by Adam on 04/12/24.
//

import Foundation

struct AdminModel: Identifiable {
    var id: String = UUID().uuidString
    var name: String
    var username: String
    var password: String
    var level: String
}
