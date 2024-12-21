//
//  LoginUseCase.swift
//  gramejia
//
//  Created by Adam on 01/12/24.
//

import Foundation
import Combine

protocol LoginUseCaseProtocol {
    func authenticateCustomer(username: String, password: String) -> AnyPublisher<CustomerModel?, Error>
    func authenticateAdmin(username: String, password: String) -> AnyPublisher<AdminModel?, Error>
    func registerAdmin(admin: AdminModel) -> AnyPublisher<Bool, Error>
}

class LoginUseCase: LoginUseCaseProtocol {
    private let authenticationRepository: AuthenticationRepositoryProtocol
    
    required init(authenticationRepository: AuthenticationRepositoryProtocol) {
        self.authenticationRepository = authenticationRepository
    }
    
    func authenticateCustomer(username: String, password: String) -> AnyPublisher<CustomerModel?, Error> {
        return authenticationRepository.authenticateCustomer(username: username, password: password)
    }
    
    func authenticateAdmin(username: String, password: String) -> AnyPublisher<AdminModel?, Error> {
        return authenticationRepository.authenticateAdmin(username: username, password: password)
    }
    
    func registerAdmin(admin: AdminModel) -> AnyPublisher<Bool, Error> {
        return authenticationRepository.registerAdmin(admin: admin)
    }
}
