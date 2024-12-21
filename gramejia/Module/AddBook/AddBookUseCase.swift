//
//  AddBookUseCase.swift
//  gramejia
//
//  Created by Adam on 30/11/24.
//

import Foundation
import Combine

protocol AddBookUseCaseProtocol {
    func getBookList() -> AnyPublisher<[BookModel], Error>
    func addBook(book: BookModel) -> AnyPublisher<Bool, Error>
    func deleteBook(idBook: String) -> AnyPublisher<Bool, any Error>
}

class AddBookUseCase: AddBookUseCaseProtocol {
    private let bookRepository: BookRepositoryProtocol
    
    required init(bookRepository: BookRepositoryProtocol) {
        self.bookRepository = bookRepository
    }
    
    func getBookList() -> AnyPublisher<[BookModel], any Error> {
        return bookRepository.getBookList().eraseToAnyPublisher()
    }
    
    func addBook(book: BookModel) -> AnyPublisher<Bool, any Error> {
        return bookRepository.addBook(book: book).eraseToAnyPublisher()
    }
    
    func deleteBook(idBook: String) -> AnyPublisher<Bool, any Error> {
        return bookRepository.deleteBook(idBook: idBook).eraseToAnyPublisher()
    }
}
