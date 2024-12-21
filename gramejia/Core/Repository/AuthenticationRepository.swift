//
//  AuthenticationRepository.swift
//  gramejia
//
//  Created by Adam on 02/12/24.
//

import Foundation
import Combine

protocol AuthenticationRepositoryProtocol {
    func registerCustomer(customer: CustomerModel) -> AnyPublisher<Bool, Error>
    func authenticateCustomer(username: String, password: String) -> AnyPublisher<CustomerModel?, Error>
    func getCustomerList() -> AnyPublisher<[CustomerModel], Error>
    func getCustomer(username: String) -> AnyPublisher<CustomerModel?, Error>
    
    func registerAdmin(admin: AdminModel) -> AnyPublisher<Bool, Error>
    func authenticateAdmin(username: String, password: String) -> AnyPublisher<AdminModel?, Error>
    func getAdmin(username: String) -> AnyPublisher<AdminModel?, Error>
    func getAdminList() -> AnyPublisher<[AdminModel]?, Error>
    
    func updateAdmin(username: String, name: String, password: String, profileImage: String?) -> AnyPublisher<Bool, Error>
    func updateCustomer(username: String, name: String, password: String, profileImage: String?) -> AnyPublisher<Bool, Error>
    func updateBalance(username: String, balance: Double) -> AnyPublisher<Bool, Error>
}

final class AuthenticationRepository: NSObject {
    typealias AuthenticationRepositoryInstance = (CoreDataManager) -> AuthenticationRepository
    
    fileprivate let coreDataManager: CoreDataManager
    
    private init(coreDataManager: CoreDataManager) {
        self.coreDataManager = coreDataManager
    }
    
    static let sharedInstance: AuthenticationRepositoryInstance = { coreDataManager in
        return AuthenticationRepository(coreDataManager: coreDataManager)
    }
}

extension AuthenticationRepository: AuthenticationRepositoryProtocol {
    func getAdminList() -> AnyPublisher<[AdminModel]?, Error> {
        return self.coreDataManager.fetch(AdminEntity.self).map { entities in
            return entities.map { entity in
                AdminMapper.adminEntityToDomain(entity)
            }
        }.eraseToAnyPublisher()
    }
    
    func authenticateAdmin(username: String, password: String) -> AnyPublisher<AdminModel?, Error> {
        let predicate = NSPredicate(format: "username == %@ AND password == %@", username, password)
        
        return self.coreDataManager.fetchSingle(AdminEntity.self, predicate: predicate)
            .map { (entity) -> AdminModel?  in
                guard let entity: AdminEntity = entity else { return nil }
                return AdminMapper.adminEntityToDomain(entity)
            }.eraseToAnyPublisher()
    }
    
    func getAdmin(username: String) -> AnyPublisher<AdminModel?, Error> {
        let predicate = NSPredicate(format: "username == %@", username)
        
        return self.coreDataManager.fetchSingle(AdminEntity.self, predicate: predicate)
            .map { (entity) -> AdminModel?  in
                guard let entity: AdminEntity = entity else { return nil }
                return AdminMapper.adminEntityToDomain(entity)
            }.eraseToAnyPublisher()
    }
    
    func getCustomerList() -> AnyPublisher<[CustomerModel], Error> {
        return self.coreDataManager.fetch(CustomerEntity.self).map { entities in
            return entities.map { entity in
                CustomerMapper.customerEntityToDomain(entity)
            }
        }.eraseToAnyPublisher()
    }
    
    func authenticateCustomer(username: String, password: String) -> AnyPublisher<CustomerModel?, Error> {
        let predicate = NSPredicate(format: "username == %@ AND password == %@", username, password)
        
        return self.coreDataManager.fetchSingle(CustomerEntity.self, predicate: predicate)
            .map { (entity) -> CustomerModel?  in
                guard let entity: CustomerEntity = entity else { return nil }
                return CustomerMapper.customerEntityToDomain(entity)
            }.eraseToAnyPublisher()
    }
    
    func getCustomer(username: String) -> AnyPublisher<CustomerModel?, Error> {
        let predicate = NSPredicate(format: "username == %@", username)
        
        return self.coreDataManager.fetchSingle(CustomerEntity.self, predicate: predicate)
            .map { (entity) -> CustomerModel?  in
                guard let entity: CustomerEntity = entity else { return nil }
                return CustomerMapper.customerEntityToDomain(entity)
            }.eraseToAnyPublisher()
    }
    
    func registerAdmin(admin: AdminModel) -> AnyPublisher<Bool, Error> {
        let predicate = NSPredicate(format: "username == %@", admin.username)
        
        return self.coreDataManager.addUnique(predicate: predicate) { (entity: AdminEntity) in
            AdminMapper.adminDomainToEntity(admin, entity: entity)
        }.eraseToAnyPublisher()
    }
    
    func registerCustomer(customer: CustomerModel) -> AnyPublisher<Bool, Error> {
        let predicate = NSPredicate(format: "username == %@", customer.username)
        
        return self.coreDataManager.addUnique(predicate: predicate) { (entity: CustomerEntity) in
            CustomerMapper.customeDomainToEntity(customer, entity: entity)
        }.eraseToAnyPublisher()
    }
    
    func updateAdmin(username: String, name: String, password: String, profileImage: String?) -> AnyPublisher<Bool, Error> {
        let predicate = NSPredicate(format: "username == %@", username)
        
        return self.coreDataManager.updateEntity(predicate: predicate) { (entity: AdminEntity) in
            entity.password = password
            entity.profileImage = profileImage
            entity.name = name
        }.eraseToAnyPublisher()
    }
    
    func updateCustomer(username: String, name: String, password: String, profileImage: String?) -> AnyPublisher<Bool, Error> {
        let predicate = NSPredicate(format: "username == %@", username)
        
        return self.coreDataManager.updateEntity(predicate: predicate) { (entity: CustomerEntity) in
            entity.password = password
            entity.profileImage = profileImage
            entity.name = name
        }.eraseToAnyPublisher()
    }
    
    func updateBalance(username: String, balance: Double) -> AnyPublisher<Bool, Error> {
        let predicate = NSPredicate(format: "username == %@", username)
        
        return self.coreDataManager.updateEntity(predicate: predicate) { (entity: CustomerEntity) in
            let newBalance = entity.balance + balance
            entity.balance = newBalance
        }.eraseToAnyPublisher()
    }
}
