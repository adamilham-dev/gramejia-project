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
    
    func getCartItemList() -> AnyPublisher<[CartItemModel], Error>
    
    func addBookToCart(username: String, idBook: String, quantity: Int64, updatedDate: String) -> AnyPublisher<Bool, Error>
    
    func getCartBookItem(username: String, idBook: String) -> AnyPublisher<CartItemModel?, Error>
    
    func deleteCartBookItem(username: String, idBook: String) -> AnyPublisher<Bool, Error>
    
    func deleteCartUser(username: String) -> AnyPublisher<Bool, Error>
    
    func getAllUserCart() -> AnyPublisher<[CartModel], Error>
    
    func updateBookStock(username: String, cartItems: [CartItemModel]) -> AnyPublisher<Bool, Error>
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
    func deleteCartUser(username: String) -> AnyPublisher<Bool, Error> {
        return self.coreDataManager.deleteCartUser(username: username)
    }
    
    func deleteCartBookItem(username: String, idBook: String) -> AnyPublisher<Bool, Error> {
        return self.coreDataManager.deleteCartBookItem(username: username, idBook: idBook)
    }
    
    func getCartBookItem(username: String, idBook: String) -> AnyPublisher<CartItemModel?, Error> {
        return self.coreDataManager.getCartBookItem(username: username, idBook: idBook)
            .map({
                let item: CartItemModel? = nil
                guard let entity = $0 else { return item }
                return CartMapper.cartItemEntityToDomain(entity)
            }).eraseToAnyPublisher()
    }
    
    func addBookToCart(username: String, idBook: String, quantity: Int64, updatedDate: String) -> AnyPublisher<Bool, Error> {
        return self.coreDataManager.addBookToCart(username: username, idBook: idBook, quantity: quantity, updatedDate: updatedDate)
            .eraseToAnyPublisher()
    }
    
    func getCartItemList(username: String) -> AnyPublisher<[CartItemModel], Error> {
        return self.coreDataManager.fetchCartItems(username: username)
            .map { $0.map { CartMapper.cartItemEntityToDomain($0) } }
            .eraseToAnyPublisher()
    }
    
    func getCartItemList() -> AnyPublisher<[CartItemModel], Error> {
        let sortDescriptor = [NSSortDescriptor(key: "updateDate", ascending: false)]
        return self.coreDataManager.fetch(CartItemEntity.self, sortDescriptor: sortDescriptor)
            .map { $0.map { CartMapper.cartItemEntityToDomain($0) } }
            .eraseToAnyPublisher()
    }
    
    func getAllUserCart() -> AnyPublisher<[CartModel], Error> {
        let sortDescriptor = [NSSortDescriptor(key: "updateDate", ascending: false)]
        return self.coreDataManager.fetch(CartEntity.self, sortDescriptor: sortDescriptor)
            .map({ $0.map { CartMapper.cartEntityToDomain($0) } })
            .eraseToAnyPublisher()
    }
    
    func updateBookStock(username: String, cartItems: [CartItemModel]) -> AnyPublisher<Bool, Error> {
        return self.coreDataManager.updateStockBook(username: username) { context, customer, cartEntity, cartItemEntities in
            for item in cartItems {
                if let entity = cartItemEntities.first(where: { $0.book?.id == item.book?.id }) {
                    let newStock = (entity.book?.stock ?? 0) - item.quantity
                    entity.book?.stock = newStock
                }
            }
            context.delete(cartEntity)
            customer.cart = nil
        }
    }
}
