//
//  BookRepository.swift
//  gramejia
//
//  Created by Rivaldo Fernandes on 30/11/24.
//

import Foundation
import Combine

protocol BookRepositoryProtocol {
    func getBookList() -> AnyPublisher<[BookModel], Error>
    func addBook(book: BookModel) -> AnyPublisher<Bool, Error>
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
    func getBookList() -> AnyPublisher<[BookModel], any Error> {
        return self.coreDataManager.fetch(BookEntity.self)
            .map { $0.map { BookMapper.bookEntityToDomain($0) } }
            .eraseToAnyPublisher()
    }
    
    func addBook(book: BookModel) -> AnyPublisher<Bool, any Error> {
        let predicate = NSPredicate(format: "id == %@", book.id)
        return self.coreDataManager.addOrUpdateEntity(predicate: predicate) { (entity: BookEntity) in
            BookMapper.bookDomainToEntity(book, entity: entity)
        }
        .eraseToAnyPublisher()
    }
    
}

