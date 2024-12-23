//
//  BookRepository.swift
//  gramejia
//
//  Created by Adam on 30/11/24.
//

import Foundation
import Combine

protocol BookRepositoryProtocol {
    func getBookList() -> AnyPublisher<[BookModel], Error>
    func addBook(book: BookModel) -> AnyPublisher<Bool, Error>
    func deleteBook(idBook: String) -> AnyPublisher<Bool, Error>
    func updateBook(book: BookModel) -> AnyPublisher<Bool, Error>
    func updateBookStock(idBook: String, stock: Int64) -> AnyPublisher<Bool, Error>
}

final class BookRepository: NSObject {
    typealias BookRepositoryInstance = (CoreDataManager) -> BookRepository
    
    fileprivate let coreDataManager: CoreDataManager
    
    private init(coreDataManager: CoreDataManager) {
        self.coreDataManager = coreDataManager
    }
    
    static let sharedInstance: BookRepositoryInstance = { coreDataManager in
        return BookRepository(coreDataManager: coreDataManager)
    }
}

extension BookRepository: BookRepositoryProtocol {
    func updateBook(book: BookModel) -> AnyPublisher<Bool, Error> {
        let predicate = NSPredicate(format: "id == %@", book.id)
        
        return self.coreDataManager.updateEntity(predicate: predicate) { (entity: BookEntity) in
            BookMapper.bookDomainToEntity(book, entity: entity)
        }
        .eraseToAnyPublisher()
    }
    
    func updateBookStock(idBook: String, stock: Int64) -> AnyPublisher<Bool, Error>  {
        let predicate = NSPredicate(format: "id == %@", idBook)
        
        return self.coreDataManager.updateEntity(predicate: predicate) { (entity: BookEntity) in
            let newStock = entity.stock - stock
            entity.stock = newStock
        }
        .eraseToAnyPublisher()
    }
    
    func getBookList() -> AnyPublisher<[BookModel], any Error> {
        return self.coreDataManager.fetch(BookEntity.self)
            .map { $0.map { BookMapper.bookEntityToDomain($0) } }
            .eraseToAnyPublisher()
    }
    
    func addBook(book: BookModel) -> AnyPublisher<Bool, any Error> {
        let predicate = NSPredicate(format: "id == %@", book.id)
        
        return self.coreDataManager.addUnique(predicate: predicate) { (entity: BookEntity) in
            BookMapper.bookDomainToEntity(book, entity: entity)
        }
        .eraseToAnyPublisher()
    }
    
    func deleteBook(idBook: String) -> AnyPublisher<Bool, any Error> {
        let predicate = NSPredicate(format: "id == %@", idBook)
        
        return self.coreDataManager.deleteBy(BookEntity.self, predicate: predicate)
            .eraseToAnyPublisher()
    }
}

