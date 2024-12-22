//
//  CartModel.swift
//  gramejia
//
//  Created by Adam on 22/12/24.
//

import Foundation

struct CartModel {
    var id: String
    var updateDate: String
    var owner: UserProfileModel?
    var items: [CartItemModel]
}
