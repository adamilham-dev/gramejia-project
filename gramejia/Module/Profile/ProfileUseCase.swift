//
//  ProfileUseCase.swift
//  gramejia
//
//  Created by Adam on 21/12/24.
//

import Foundation
import Combine

protocol ProfileUseCaseProtocol {
    func updateCustomer(username: String, name: String, password: String, profileImage: String?) -> AnyPublisher<Bool, Error>
    func updateAdmin(username: String, name: String, password: String, profileImage: String?) -> AnyPublisher<Bool, Error>
    func getCustomer(username: String) -> AnyPublisher<CustomerModel?, Error>
    func getAdmin(username: String) -> AnyPublisher<AdminModel?, Error>
    func deleteCustomer(username: String) -> AnyPublisher<Bool, Error>
}

class ProfileUseCase: ProfileUseCaseProtocol {
    
    private let authenticationRepository: AuthenticationRepositoryProtocol
    
    required init(authenticationRepository: AuthenticationRepositoryProtocol) {
        self.authenticationRepository = authenticationRepository
    }
    
    func updateCustomer(username: String, name: String, password: String, profileImage: String?) -> AnyPublisher<Bool, Error> {
        return authenticationRepository.updateCustomer(username: username, name: name, password: password, profileImage: profileImage)
    }
    
    func updateAdmin(username: String, name: String, password: String, profileImage: String?) -> AnyPublisher<Bool, Error> {
        return authenticationRepository.updateAdmin(username: username, name: name, password: password, profileImage: profileImage)
    }
    
    func getCustomer(username: String) -> AnyPublisher<CustomerModel?, Error> {
        return authenticationRepository.getCustomer(username: username)
    }
    
    func getAdmin(username: String) -> AnyPublisher<AdminModel?, Error> {
        return authenticationRepository.getAdmin(username: username)
    }
    
    func deleteCustomer(username: String) -> AnyPublisher<Bool, Error> {
        return authenticationRepository.deleteCustomer(username: username)
    }
}
