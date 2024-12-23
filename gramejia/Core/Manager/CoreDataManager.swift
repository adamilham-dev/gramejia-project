//
//  CoreDataManager.swift
//  gramejia
//
//  Created by Adam on 29/11/24.
//

import Foundation
import CoreData
import Combine

class CoreDataManager {
    static let shared = CoreDataManager()
    var context: NSManagedObjectContext? {
        return persistentContainer?.viewContext
    }
    
    lazy var persistentContainer: NSPersistentContainer? = {
        let container = NSPersistentContainer(name: "gramejia")
        do {
            try loadPersistentStores(for: container)
            return container
        } catch {
            return nil
        }
    }()

    private func loadPersistentStores(for container: NSPersistentContainer) throws {
        var loadError: Error?
        container.loadPersistentStores { _, error in
            if let error = error {
                loadError = error
            }
        }
        if let loadError = loadError {
            throw loadError
        }
    }
    
    func saveContext() -> AnyPublisher<Bool, Error> {
        return Future<Bool, Error> { promise in
            guard let context = self.context else {
                promise(.failure(DatabaseError.invalidDatabase))
                return
            }
            if context.hasChanges {
                do {
                    try context.save()
                    promise(.success(true))
                } catch {
                    context.rollback()
                    promise(.failure(error))
                }
            } else {
                promise(.success(false))
            }
        }
        .eraseToAnyPublisher()
    }
    
    func fetch<T: NSManagedObject>(_ entity: T.Type, predicate: NSPredicate? = nil, sortDescriptor: [NSSortDescriptor]? = nil) -> AnyPublisher<[T], Error> {
        return Future<[T], Error> { [weak self] promise in
            guard let self = self, let context = self.context else {
                promise(.failure(DatabaseError.invalidDatabase))
                return
            }
            
            let fetchRequest = NSFetchRequest<T>(entityName: String(describing: T.self))
            fetchRequest.predicate = predicate
            fetchRequest.sortDescriptors = sortDescriptor
            
            do {
                let results = try context.fetch(fetchRequest)
                promise(.success(results))
                
            } catch let error {
                promise(.failure(error))
            }
        }
        .eraseToAnyPublisher()
    }
    
    func fetchSingle<T: NSManagedObject>(_ entity: T.Type, predicate: NSPredicate? = nil) -> AnyPublisher<T?, Error> {
        return Future<T?, Error> { [weak self] promise in
            guard let self = self, let context = self.context else {
                promise(.failure(DatabaseError.invalidDatabase))
                return
            }
            
            let fetchRequest = NSFetchRequest<T>(entityName: String(describing: T.self))
            
            fetchRequest.predicate = predicate
            
            do {
                let results = try context.fetch(fetchRequest)
                promise(.success(results.first))
            } catch let error {
                promise(.failure(error))
            }
        }
        .eraseToAnyPublisher()
    }
    
    func updateEntity<T: NSManagedObject>( predicate: NSPredicate,
                                           updateHandler: @escaping (T) -> Void
    ) -> AnyPublisher<Bool, Error> {
        
        return Future<Bool, Error> { [weak self] promise in
            guard let self = self, let context = self.context else {
                promise(.failure(DatabaseError.invalidDatabase))
                return
            }
            
            let fetchRequest = NSFetchRequest<T>(entityName: String(describing: T.self))
            fetchRequest.predicate = predicate
            
            do {
                let results = try context.fetch(fetchRequest)
                
                if let existingEntity = results.first {
                    updateHandler(existingEntity)
                    
                    try context.save()
                    promise(.success(true))
                } else {
                    promise(.success(false))
                }
            } catch {
                context.rollback()
                promise(.failure(error))
            }
        }
        .eraseToAnyPublisher()
    }
    
    
    func addOrUpdateEntity<T: NSManagedObject>( predicate: NSPredicate,
                                                updateHandler: @escaping (T) -> Void
    ) ->  AnyPublisher<Bool, Error> {
        
        return Future<Bool, Error> { [weak self] promise in
            guard let self = self, let context = self.context else {
                promise(.failure(DatabaseError.invalidDatabase))
                return
            }
            
            let fetchRequest = NSFetchRequest<T>(entityName: String(describing: T.self))
            fetchRequest.predicate = predicate
            
            do {
                let results = try context.fetch(fetchRequest)
                
                if let existingEntity = results.first {
                    updateHandler(existingEntity)
                } else {
                    let newEntity = T(context: context)
                    updateHandler(newEntity)
                }
                
                try context.save()
                promise(.success(true))
                
            } catch {
                context.rollback()
                promise(.failure(error))
            }
        }
        .eraseToAnyPublisher()
    }
    
    func addUnique<T: NSManagedObject>(
        predicate: NSPredicate,
        updateHandler: @escaping (T) -> Void
    ) ->  AnyPublisher<Bool, Error> {
        
        return Future<Bool, Error> { [weak self] promise in
            guard let self = self, let context = self.context else {
                promise(.failure(DatabaseError.invalidDatabase))
                return
            }
            
            let fetchRequest = NSFetchRequest<T>(entityName: String(describing: T.self))
            fetchRequest.predicate = predicate
            
            do {
                let results = try context.fetch(fetchRequest)
                
                if let existingEntity = results.first {
                    promise(.failure(DatabaseError.dataAlreadyExist))
                } else {
                    let newEntity = T(context: context)
                    updateHandler(newEntity)
                    
                    try context.save()
                    promise(.success(true))
                }
            } catch {
                context.rollback()
                promise(.failure(error))
            }
        }
        .eraseToAnyPublisher()
    }
    
    
    func add<T: NSManagedObject>(entity: T.Type, configure: @escaping (T) -> Void) -> AnyPublisher<Bool, Error> {
        return Future<Bool, Error> { [weak self] promise in
            guard let self = self, let context = self.context else {
                promise(.failure(DatabaseError.invalidDatabase))
                return
            }
            
            let newObject = T(context: context)
            configure(newObject)
            
            do {
                try context.save()
                promise(.success(true))
            } catch let error {
                context.rollback()
                promise(.failure(error))
            }
        }
        .eraseToAnyPublisher()
    }

    func addMultiple<T: NSManagedObject>(entity: T.Type, configure: @escaping (NSManagedObjectContext) -> Void) -> AnyPublisher<Bool, Error> {
        return Future<Bool, Error> { [weak self] promise in
            guard let self = self, let context = self.context else {
                promise(.failure(DatabaseError.invalidDatabase))
                return
            }
            
            configure(context)
            
            do {
                try context.save()
                promise(.success(true))
            } catch let error {
                context.rollback()
                promise(.failure(error))
            }
        }
        .eraseToAnyPublisher()
    }
    
    func addWithLimit<T: NSManagedObject>(entity: T.Type, limit: Int, sortDescriptor: [NSSortDescriptor]? = nil, configure: @escaping (T) -> Void) -> AnyPublisher<Bool, Error> {
        return Future<Bool, Error> { [weak self] promise in
            guard let self = self, let context = self.context else {
                promise(.failure(DatabaseError.invalidDatabase))
                return
            }
            
            let newObject = T(context: context)
            configure(newObject)
            context.insert(newObject)
            do {
                
                let fetchRequest = NSFetchRequest<T>(entityName: String(describing: T.self))
                let count = try context.count(for: fetchRequest)
                
                if(count > limit) {
                    fetchRequest.sortDescriptors = sortDescriptor
                    fetchRequest.fetchLimit = count - limit
                    
                    let sortedRecord = try context.fetch(fetchRequest)
                    for record in sortedRecord {
                        context.delete(record)
                    }
                }
                
                try context.save()
                promise(.success(true))
            } catch let error {
                context.rollback()
                promise(.failure(error))
            }
        }
        .eraseToAnyPublisher()
    }
    
    func delete<T: NSManagedObject>(object: T) -> AnyPublisher<Bool, Error> {
        return Future<Bool, Error> { [weak self] promise in
            guard let self = self, let context = self.context else {
                promise(.failure(DatabaseError.invalidDatabase))
                return
            }
            
            context.delete(object)
            
            do {
                try context.save()
                promise(.success(true))
            } catch let error {
                context.rollback()
                promise(.failure(error))
            }
        }
        .eraseToAnyPublisher()
    }
    
    func deleteAll<T: NSManagedObject>(_ entity: T.Type) -> AnyPublisher<Bool, Error> {
        return Future<Bool, Error> { [weak self] promise in
            guard let self = self, let context = self.context else {
                promise(.failure(DatabaseError.invalidDatabase))
                return
            }
            
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: String(describing: T.self))
            let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
            
            do {
                try context.execute(batchDeleteRequest)
                try context.save()
                promise(.success(true))
            } catch let error {
                context.rollback()
                promise(.failure(error))
            }
        }
        .eraseToAnyPublisher()
    }
    
    func deleteBy<T: NSManagedObject>(_ entity: T.Type, predicate: NSPredicate) ->  AnyPublisher<Bool, Error> {
        
        return Future<Bool, Error> { [weak self] promise in
            guard let self = self, let context = self.context else {
                promise(.failure(DatabaseError.invalidDatabase))
                return
            }
            
            let fetchRequest = NSFetchRequest<T>(entityName: String(describing: T.self))
            fetchRequest.predicate = predicate
            
            do {
                let results = try context.fetch(fetchRequest)
                
                if let existingEntity = results.first {
                    context.delete(existingEntity)
                    try context.save()
                    promise(.success(true))
                } else {
                    promise(.success(false))
                }
            } catch {
                context.rollback()
                promise(.failure(error))
            }
        }
        .eraseToAnyPublisher()
    }
    
    private func getSingle<T: NSManagedObject>(_ entity: T.Type, predicate: NSPredicate?) -> T? {
        guard let context = self.context else {
            return nil
        }
        
        let fetchRequest = NSFetchRequest<T>(entityName: String(describing: T.self))
        fetchRequest.predicate = predicate
        
        do {
            let results = try context.fetch(fetchRequest)
            return results.first
        } catch let error {
            return nil
        }
    }
    
    func fetchCartItems(username: String) -> AnyPublisher<[CartItemEntity], Error> {
        return Future<[CartItemEntity], Error> { [weak self] promise in
            guard let self = self, let context = self.context else {
                promise(.failure(DatabaseError.invalidDatabase))
                return
            }
            
            if let user = getSingle(CustomerEntity.self, predicate: NSPredicate(format: "username == %@", username)){
                var cart = user.cart
                if cart == nil {
                    let newCart = CartEntity(context: context)
                    newCart.owner = user
                    cart = newCart
                }
                
                if let cart = cart {
                    if var cartItems = cart.items as? Set<CartItemEntity> {
                        promise(.success(Array(cartItems)))
                    } else {
                        promise(.failure(DatabaseError.dataNotFound))
                    }
                } else {
                    promise(.failure(DatabaseError.dataNotFound))
                }

            } else {
                promise(.failure(DatabaseError.dataNotFound))
            }
        }
        .eraseToAnyPublisher()
    }
    
    func updateStockBook(username: String, handler: @escaping (NSManagedObjectContext, CustomerEntity, CartEntity, Set<CartItemEntity>) -> Void) -> AnyPublisher<Bool, Error> {
        return Future<Bool, Error> { [weak self] promise in
            guard let self = self, let context = self.context else {
                promise(.failure(DatabaseError.invalidDatabase))
                return
            }
            
            if let user = getSingle(CustomerEntity.self, predicate: NSPredicate(format: "username == %@", username)){
                var cart = user.cart
                if cart == nil {
                    let newCart = CartEntity(context: context)
                    newCart.owner = user
                    cart = newCart
                }
                
                if let cart = cart {
                    if let cartItems = cart.items as? Set<CartItemEntity> {
                        handler(context, user, cart, cartItems)
                        do {
                            try context.save()
                            promise(.success(true))
                        } catch {
                            context.rollback()
                            promise(.failure(error))
                        }
                    } else {
                        promise(.failure(DatabaseError.dataNotFound))
                    }
                } else {
                    promise(.failure(DatabaseError.dataNotFound))
                }

            } else {
                promise(.failure(DatabaseError.dataNotFound))
            }
        }
        .eraseToAnyPublisher()
    }
    
    func addTransaction(username: String, handler: @escaping (NSManagedObjectContext, CustomerEntity) -> Void) -> AnyPublisher<Bool, Error> {
        return Future<Bool, Error> { [weak self] promise in
            guard let self = self, let context = self.context else {
                promise(.failure(DatabaseError.invalidDatabase))
                return
            }
            
            guard let user = getSingle(CustomerEntity.self, predicate: NSPredicate(format: "username == %@", username)) else { return }
            
            handler(context, user)
            
            do {
                try context.save()
                promise(.success(true))
            } catch {
                context.rollback()
                promise(.failure(error))
            }
        }.eraseToAnyPublisher()
    }
    
    func deleteCartUser(username: String) -> AnyPublisher<Bool, Error> {
        return Future<Bool, Error> { [weak self] promise in
            guard let self = self, let context = self.context else {
                promise(.failure(DatabaseError.invalidDatabase))
                return
            }
            if let user = getSingle(CustomerEntity.self, predicate: NSPredicate(format: "username == %@", username)){
                if let cart = user.cart {
                    context.delete(cart)
                    do {
                        try context.save()
                        promise(.success(true))
                    } catch let error {
                        context.rollback()
                        promise(.failure(error))
                    }
                } else {
                    promise(.failure(DatabaseError.dataNotFound))
                }
            } else {
                promise(.failure(DatabaseError.dataNotFound))
            }
        }
        .eraseToAnyPublisher()
    }
    
    func deleteCartBookItem(username: String, idBook: String) -> AnyPublisher<Bool, Error> {
        return Future<Bool, Error> { [weak self] promise in
            guard let self = self, let context = self.context else {
                promise(.failure(DatabaseError.invalidDatabase))
                return
            }
            
            if let user = getSingle(CustomerEntity.self, predicate: NSPredicate(format: "username == %@", username)){
                var cart = user.cart
                if cart == nil {
                    let newCart = CartEntity(context: context)
                    newCart.owner = user
                    cart = newCart
                }
                
                guard let book = getSingle(BookEntity.self, predicate: NSPredicate(format: "id == %@", idBook)) else {
                    promise(.failure(DatabaseError.dataNotFound))
                    return
                }
                
                if let cart = cart {
                    if let cartItems = cart.items as? Set<CartItemEntity> {
                        if(cartItems.count == 1) {
                            context.delete(cart)
                        }
                        if let existingCartItem = cartItems.first(where: { $0.book == book }) {
                            context.delete(existingCartItem)
                            do {
                                try context.save()
                                promise(.success(true))
                            } catch let error {
                                context.rollback()
                                promise(.failure(error))
                            }
                        } else {
                            promise(.failure(DatabaseError.dataNotFound))
                        }
                    } else {
                        promise(.failure(DatabaseError.dataNotFound))
                    }
                } else {
                    promise(.failure(DatabaseError.dataNotFound))
                }
            } else {
                promise(.failure(DatabaseError.dataNotFound))
            }
        }
        .eraseToAnyPublisher()
    }
    
    
    func getCartBookItem(username: String, idBook: String) -> AnyPublisher<CartItemEntity?, Error> {
        return Future<CartItemEntity?, Error> { [weak self] promise in
            guard let self = self, let context = self.context else {
                promise(.failure(DatabaseError.invalidDatabase))
                return
            }
            
            if let user = getSingle(CustomerEntity.self, predicate: NSPredicate(format: "username == %@", username)){
                var cart = user.cart
                if cart == nil {
                    let newCart = CartEntity(context: context)
                    newCart.owner = user
                    cart = newCart
                }
                
                guard let book = getSingle(BookEntity.self, predicate: NSPredicate(format: "id == %@", idBook)) else {
                    promise(.failure(DatabaseError.dataNotFound))
                    return
                }
                
                if let cart = cart {
                    if let cartItems = cart.items as? Set<CartItemEntity> {
                        if let existingCartItem = cartItems.first(where: { $0.book == book }) {
                            promise(.success(existingCartItem))
                        } else {
                            promise(.success(nil))
                        }
                    } else {
                        promise(.failure(DatabaseError.dataNotFound))
                    }
                } else {
                    promise(.failure(DatabaseError.dataNotFound))
                }
            } else {
                promise(.failure(DatabaseError.dataNotFound))
            }
        }
        .eraseToAnyPublisher()
    }
    
    func addBookToCart(username: String, idBook: String, quantity: Int64, updatedDate: String) -> AnyPublisher<Bool, Error> {
        return Future<Bool, Error> { [weak self] promise in
            guard let self = self, let context = self.context else {
                promise(.failure(DatabaseError.invalidDatabase))
                return
            }
            
            if let user = getSingle(CustomerEntity.self, predicate: NSPredicate(format: "username == %@", username)){
                var cart = user.cart
                if cart == nil {
                    let newCart = CartEntity(context: context)
                    newCart.updateDate = updatedDate
                    newCart.owner = user
                    cart = newCart
                }
                
                guard let book = getSingle(BookEntity.self, predicate: NSPredicate(format: "id == %@", idBook)) else {
                    promise(.failure(DatabaseError.dataNotFound))
                    return
                }
                
                if let cart = cart {
                    if var cartItems = cart.items as? Set<CartItemEntity> {
                        if let existingCartItem = cartItems.first(where: { $0.book == book }) {
                            existingCartItem.quantity = quantity
                        } else {
                            let cartItem = CartItemEntity(context: context)
                            cartItem.book = book
                            cartItem.updateDate = updatedDate
                            cartItem.cart = cart
                            cartItem.quantity = quantity
                            cartItems.insert(cartItem)
                        }
                    } else {
                        promise(.failure(DatabaseError.dataNotFound))
                    }
                    do {
                        try context.save()
                        promise(.success(true))
                    } catch {
                        context.rollback()
                        promise(.failure(error))
                    }
                } else {
                    promise(.failure(DatabaseError.dataNotFound))
                }

            } else {
                promise(.failure(DatabaseError.dataNotFound))
            }
        }
        .eraseToAnyPublisher()
    }
    
}
