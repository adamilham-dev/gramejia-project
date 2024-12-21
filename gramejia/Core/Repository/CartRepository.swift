//
//  CartRepository.swift
//  gramejia
//
//  Created by Adam on 16/12/24.
//

import Foundation
import Combine

protocol CartRepositoryProtocol {
    func getCartItemList(username: String) -> AnyPublisher<[CartItemModel], Error>
    
    func addBookToCart(username: String, idBook: String, quantity: Int64) -> AnyPublisher<Bool, Error>
    
    func getCartBookItem(username: String, idBook: String) -> AnyPublisher<CartItemModel?, Error>
}

final class CartRepository: NSObject {
    typealias CartRepositoryInstance = (CoreDataManager) -> CartRepository
    
    fileprivate let coreDataManager: CoreDataManager
    
    private init(coreDataManager: CoreDataManager) {
        self.coreDataManager = coreDataManager
    }
    
    static let sharedInstance: CartRepositoryInstance = { coreDataManager in
        return CartRepository(coreDataManager: coreDataManager)
    }
}

extension CartRepository: CartRepositoryProtocol {
    func getCartBookItem(username: String, idBook: String) -> AnyPublisher<CartItemModel?, Error> {
        self.coreDataManager.getCartBookItem(username: username, idBook: idBook)
            .map({
                let item: CartItemModel? = nil
                guard let entity = $0 else { return item }
                return CartMapper.cartItemEntityToDomain(entity)
            }).eraseToAnyPublisher()
    }
    
    func addBookToCart(username: String, idBook: String, quantity: Int64) -> AnyPublisher<Bool, Error> {
        self.coreDataManager.addBookToCart(username: username, idBook: idBook, quantity: quantity)
            .eraseToAnyPublisher()
    }
    
    func getCartItemList(username: String) -> AnyPublisher<[CartItemModel], Error> {
        self.coreDataManager.fetchCartItems(username: username)
            .map { $0.map { CartMapper.cartItemEntityToDomain($0) } }
            .eraseToAnyPublisher()
    }
}
