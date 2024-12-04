//
//  LoginUseCase.swift
//  gramejia
//
//  Created by Adam on 01/12/24.
//

import Foundation
import Combine

protocol LoginUseCaseProtocol {
    func getCustomer(username: String, password: String) -> AnyPublisher<CustomerModel?, Error>
    func getAdmin(username: String, password: String) -> AnyPublisher<AdminModel?, Error>
}

class LoginUseCase: LoginUseCaseProtocol {
    private let authenticationRepository: AuthenticationRepositoryProtocol
    
    required init(authenticationRepository: AuthenticationRepositoryProtocol) {
        self.authenticationRepository = authenticationRepository
    }
    
    func getCustomer(username: String, password: String) -> AnyPublisher<CustomerModel?, Error> {
        return authenticationRepository.getCustomer(username: username, password: password)
    }
    
    func getAdmin(username: String, password: String) -> AnyPublisher<AdminModel?, Error> {
        return authenticationRepository.getAdmin(username: username, password: password)
    }
}
