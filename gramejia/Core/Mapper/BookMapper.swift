//
//  BookMapper.swift
//  gramejia
//
//  Created by Adam on 30/11/24.
//

import Foundation
import CoreData

final class BookMapper {
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
