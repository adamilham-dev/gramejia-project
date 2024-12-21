//
//  TransactionEntity.swift
//  gramejia
//
//  Created by Adam on 18/12/24.
//

import Foundation

struct TransactionModel: Identifiable {
    let id: String
    let transactionDate: String
    let items: [TransactionItemModel]
}
