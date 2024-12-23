//
//  HomeUseCase.swift
//  gramejia
//
//  Created by Adam on 08/12/24.
//

import Foundation
import Combine

protocol HomeUseCaseProtocol {
    func getBookList() -> AnyPublisher<[BookModel], Error>
}

class HomeUseCase: HomeUseCaseProtocol {
    private let bookRepository: BookRepositoryProtocol
    
    required init(bookRepository: BookRepositoryProtocol) {
        self.bookRepository = bookRepository
    }
    
    func getBookList() -> AnyPublisher<[BookModel], any Error> {
        return bookRepository.getBookList().eraseToAnyPublisher()
    }
}
