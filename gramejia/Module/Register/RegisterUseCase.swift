//
//  RegisterUseCase.swift
//  gramejia
//
//  Created by Adam on 02/12/24.
//

import Foundation
import Combine

protocol RegisterUseCaseProtocol {
    func registerCustomer(customer: CustomerModel) -> AnyPublisher<Bool, Error>
    func getCustomerList() -> AnyPublisher<[CustomerModel], Error>
}

class RegisterUseCase: RegisterUseCaseProtocol {
    private let authenticationRepository: AuthenticationRepositoryProtocol
    
    required init(authenticationRepository: AuthenticationRepositoryProtocol) {
        self.authenticationRepository = authenticationRepository
    }
    
    func registerCustomer(customer: CustomerModel) -> AnyPublisher<Bool, any Error> {
        return authenticationRepository.registerCustomer(customer: customer)
    }
    
    func getCustomerList() -> AnyPublisher<[CustomerModel], any Error> {
        return authenticationRepository.getCustomerList()
    }
}
