//
//  CartMapper.swift
//  gramejia
//
//  Created by Adam on 16/12/24.
//

import Foundation

final class CartMapper {
    static func cartItemEntityToDomain(_ entity: CartItemEntity) -> CartItemModel {
        var bookModel: BookModel? = nil
        if let bookEntity: BookEntity = entity.book {
            bookModel = BookMapper.bookEntityToDomain(bookEntity)
        }
        return CartItemModel(
            book: bookModel, quantity: entity.quantity, updatedDate: entity.updateDate ?? Date().ISO8601Format()
        )
    }
    
    static func cartEntityToDomain(_ entity: CartEntity) -> CartModel {
        let items = entity.items as? Set<CartItemEntity> ?? []
        
        return CartModel(
            id: entity.id ?? "",
            updateDate: entity.updateDate ?? "",
            owner: UserProfileModel(
                name: entity.owner?.name ?? "",
                username: entity.owner?.username ?? "",
                password: entity.owner?.password ?? ""),
            items: items.map({ cartItemEntityToDomain($0) }).sorted(by: { $0.updatedDate < $1.updatedDate })
        )
    }
    
    static func bookEntityToDomain(_ entity: BookEntity) -> BookModel {
        return BookModel(
            id: entity.id ?? "",
            author: entity.author ?? "",
            coverImage: entity.coverImage,
            price: entity.price,
            publishedDate: entity.publishedDate ?? "",
            publisher: entity.publisher ?? "",
            stock: entity.stock,
            synopsis: entity.synopsis ?? "",
            title: entity.title ?? "",
            updatedDate: entity.updatedDate ?? ""
        )
    }
    
    static func bookDomainToEntity(_ domain: BookModel, entity: BookEntity) {
        entity.id = domain.id
        entity.author = domain.author
        entity.coverImage = domain.coverImage
        entity.price = domain.price
        entity.publishedDate = domain.publishedDate
        entity.publisher = domain.publisher
        entity.stock = domain.stock
        entity.synopsis = domain.synopsis
        entity.title = domain.title
        entity.updatedDate = domain.updatedDate
    }
}
