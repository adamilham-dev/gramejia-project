//
//  CartUseCase.swift
//  gramejia
//
//  Created by Adam on 15/12/24.
//

import Foundation
import Combine

protocol CartUseCaseProtocol {
    func getCartList(username: String) -> AnyPublisher<[CartItemModel], Error>
    func getCustomer(username: String) -> AnyPublisher<CustomerModel?, Error>
    func addBookToCart(username: String, idBook: String, quantity: Int64) -> AnyPublisher<Bool, Error>
    func deleteCartBookItem(username: String, idBook: String) -> AnyPublisher<Bool, Error>
}

class CartUseCase: CartUseCaseProtocol {
    func deleteCartBookItem(username: String, idBook: String) -> AnyPublisher<Bool, Error> {
        self.cartRepository.deleteCartBookItem(username: username, idBook: idBook)
    }
    
    func addBookToCart(username: String, idBook: String, quantity: Int64) -> AnyPublisher<Bool, Error> {
        self.cartRepository.addBookToCart(username: username, idBook: idBook, quantity: quantity).eraseToAnyPublisher()
    }
    
    func getCustomer(username: String) -> AnyPublisher<CustomerModel?, Error> {
        self.authenticationRepository.getCustomer(username: username).eraseToAnyPublisher()
    }
    
    func getCartList(username: String) -> AnyPublisher<[CartItemModel], Error> {
        self.cartRepository.getCartItemList(username: username).eraseToAnyPublisher()
    }
    
    private let cartRepository: CartRepositoryProtocol
    private let authenticationRepository: AuthenticationRepositoryProtocol
    
    required init(cartRepository: CartRepositoryProtocol, authenticationRepository: AuthenticationRepositoryProtocol) {
        self.cartRepository = cartRepository
        self.authenticationRepository = authenticationRepository
    }
    
}

