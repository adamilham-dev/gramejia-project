//
//  AdminMapper.swift
//  gramejia
//
//  Created by Adam on 04/12/24.
//

import Foundation

final class AdminMapper {
    static func adminEntityToDomain(_ entity: AdminEntity) -> AdminModel {
        return AdminModel(
            id: entity.id ?? "",
            name: entity.name ?? "",
            username: entity.username ?? "",
            password: entity.password ?? "",
            level: entity.level ?? ""
        )
    }
    
    static func adminDomainToEntity(_ domain: AdminModel, entity: AdminEntity) {
        entity.id = domain.id
        entity.name = domain.name
        entity.username = domain.username
        entity.password = domain.password
        entity.level = domain.level
    }
}
