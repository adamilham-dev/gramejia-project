//
//  DetailBookUseCase.swift
//  gramejia
//
//  Created by Adam on 16/12/24.
//

import Foundation
import Combine

protocol DetailBookUseCaseProtocol {
    func addBookToCart(username: String, idBook: String, quantity: Int64) -> AnyPublisher<Bool, Error>
}

class DetailBookUseCase: DetailBookUseCaseProtocol {
    func addBookToCart(username: String, idBook: String, quantity: Int64) -> AnyPublisher<Bool, Error> {
        return cartRepository.addBookToCart(username: username, idBook: idBook, quantity: quantity)
    }
    
    private let cartRepository: CartRepositoryProtocol
    
    required init(cartRepository: CartRepositoryProtocol) {
        self.cartRepository = cartRepository
    }
}
