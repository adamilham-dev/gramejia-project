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
    
    func getCartBookItem(username: String, idBook: String) -> AnyPublisher<CartItemModel?, Error>
}

class DetailBookUseCase: DetailBookUseCaseProtocol {    
    func addBookToCart(username: String, idBook: String, quantity: Int64) -> AnyPublisher<Bool, Error> {
        return cartRepository.addBookToCart(username: username, idBook: idBook, quantity: quantity)
    }
    
    func getCartBookItem(username: String, idBook: String) -> AnyPublisher<CartItemModel?, Error> {
        return cartRepository.getCartBookItem(username: username, idBook: idBook)
    }
    
    private let cartRepository: CartRepositoryProtocol
    
    required init(cartRepository: CartRepositoryProtocol) {
        self.cartRepository = cartRepository
    }
}
