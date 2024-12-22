//
//  TransactionMapper.swift
//  gramejia
//
//  Created by Adam on 18/12/24.
//

import Foundation

final class TransactionMapper {
    
    static func transactionItemEntityToDomain(_ entity: TransactionItemEntity) -> TransactionItemModel {
        return TransactionItemModel(
            id: entity.id ?? "",
            idBook: entity.idBook ?? "",
            author: entity.author ?? "",
            coverImage: entity.coverImage ?? "",
            price: entity.price,
            publishedDate: entity.publishedDate ?? "",
            publisher: entity.publisher ?? "",
            quantity: entity.quantity,
            synopsis: entity.synopsis ?? "",
            title: entity.title ?? "")
    }
    
    static func transactionItemDomainToEntity(_ domain: TransactionItemModel, entity: TransactionItemEntity) {
        entity.id = domain.id
        entity.idBook = domain.idBook
        entity.author = domain.author
        entity.coverImage = domain.coverImage
        entity.price = domain.price
        entity.publishedDate = domain.publishedDate
        entity.publisher = domain.publisher
        entity.quantity = domain.quantity
        entity.synopsis = domain.synopsis
        entity.title = domain.title
    }
    
    static func transactionEntityToDomain(_ entity: TransactionEntity) -> TransactionModel {
        let transactionItems = entity.items as? Set<TransactionItemEntity> ?? []
        return TransactionModel(
            id: entity.id ?? "",
            transactionDate: entity.transactionDate ?? "",
            items: transactionItems.map { transactionItemEntityToDomain($0) },
            owner: UserProfileModel(name: entity.owner?.name ?? "", username: entity.owner?.username ?? "", password: entity.owner?.password ?? "")
        )
    }
}
