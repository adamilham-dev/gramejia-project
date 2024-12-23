//
//  UserProfileModel.swift
//  gramejia
//
//  Created by Adam on 21/12/24.
//

import Foundation

struct UserProfileModel: Identifiable {
    var id: String = UUID().uuidString
    var name: String
    var username: String
    var password: String
    var balance: Double?
    var profileImage: String?
}
