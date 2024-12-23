//
//  TransactionItemModel.swift
//  gramejia
//
//  Created by Adam on 17/12/24.
//

import Foundation

struct TransactionItemModel: Identifiable {
    let id: String
    let idBook: String
    let author: String
    let coverImage: String?
    let price: Double
    let publishedDate: String
    let publisher: String
    let quantity: Int64
    let synopsis: String
    let title: String
}
