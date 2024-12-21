//
//  CustomerModel.swift
//  gramejia
//
//  Created by Adam on 02/12/24.
//

import Foundation

struct CustomerModel: Identifiable {
    var id: String = UUID().uuidString
    var name: String
    var username: String
    var password: String
    var balance: Double
    var isActive: Bool
    var profileImage: String?
}
