//
//  CustomerMapper.swift
//  gramejia
//
//  Created by Adam on 02/12/24.
//

import Foundation

final class CustomerMapper {
    static func customerEntityToDomain(_ entity: CustomerEntity) -> CustomerModel {
        return CustomerModel(
            id: entity.id ?? "",
            name: entity.name ?? "",
            username: entity.username ?? "",
            password: entity.password ?? "",
            balance: entity.balance,
            isActive: entity.isActive
        )
    }
    
    static func customeDomainToEntity(_ domain: CustomerModel, entity: CustomerEntity) {
        entity.id = domain.id
        entity.name = domain.name
        entity.username = domain.username
        entity.password = domain.password
        entity.balance = domain.balance
        entity.isActive = domain.isActive
    }
}
