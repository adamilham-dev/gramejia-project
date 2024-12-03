//
//  CustomerModel.swift
//  gramejia
//
//  Created by Adam on 02/12/24.
//

import Foundation

struct CustomerModel: Identifiable {
    let id: String
    let name: String
    let username: String
    let password: String
    let balance: Double
    let isActive: Bool
}
