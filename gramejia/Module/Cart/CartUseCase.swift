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
    func deleteCartUser(username: String) -> AnyPublisher<Bool, Error>
    
    func updateBalance(username: String, balance: Double) -> AnyPublisher<Bool, Error>
    func updateBookStock(username: String, cartItems: [CartItemModel]) -> AnyPublisher<Bool, Error>
}

class CartUseCase: CartUseCaseProtocol {
    private let cartRepository: CartRepositoryProtocol
    private let authenticationRepository: AuthenticationRepositoryProtocol
    private let bookRepository: BookRepositoryProtocol
    
    required init(cartRepository: CartRepositoryProtocol, authenticationRepository: AuthenticationRepositoryProtocol, bookRepository: BookRepositoryProtocol) {
        self.cartRepository = cartRepository
        self.authenticationRepository = authenticationRepository
        self.bookRepository = bookRepository
    }
    
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
    
    func updateBalance(username: String, balance: Double) -> AnyPublisher<Bool, Error> {
        return authenticationRepository.updateBalance(username: username, balance: balance)
    }
    
    func deleteCartUser(username: String) -> AnyPublisher<Bool, Error> {
        return cartRepository.deleteCartUser(username: username)
    }
    
    func updateBookStock(username: String, cartItems: [CartItemModel]) -> AnyPublisher<Bool, Error> {
        return cartRepository.updateBookStock(username: username, cartItems: cartItems)
    }
    
}

