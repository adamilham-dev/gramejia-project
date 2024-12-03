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
    func getCustomer(id: String) -> AnyPublisher<CustomerModel?, Error>
    func getCustomerList() -> AnyPublisher<[CustomerModel], Error>
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
    func getCustomerList() -> AnyPublisher<[CustomerModel], Error> {
        return self.coreDataManager.fetch(CustomerEntity.self).map { entities in
            return entities.map { entity in
                CustomerMapper.customerEntityToDomain(entity)
            }
        }.eraseToAnyPublisher()
    }
    
    func getCustomer(id: String) -> AnyPublisher<CustomerModel?, Error> {
        let predicate = NSPredicate(format: "id == %@", id)
        
        return self.coreDataManager.fetchSingle(CustomerEntity.self)
            .map { (entity) -> CustomerModel?  in
                guard let entity: CustomerEntity = entity else { return nil }
                return CustomerMapper.customerEntityToDomain(entity)
            }.eraseToAnyPublisher()
    }
    
    func registerCustomer(customer: CustomerModel) -> AnyPublisher<Bool, Error> {
        let predicate = NSPredicate(format: "id == %@", customer.id)
        
        return self.coreDataManager.addUnique(predicate: predicate) { (entity: CustomerEntity) in
            CustomerMapper.customeDomainToEntity(customer, entity: entity)
        }.eraseToAnyPublisher()
    }
    
}
