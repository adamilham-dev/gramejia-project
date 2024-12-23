//
//  TopupUseCase.swift
//  gramejia
//
//  Created by Adam on 21/12/24.
//

import Foundation
import Combine

protocol TopupUseCaseProtocol {
    func updateBalance(username: String, balance: Double) -> AnyPublisher<Bool, Error>
}

class TopupUseCase: TopupUseCaseProtocol {

    private let authenticationRepository: AuthenticationRepositoryProtocol
    
    required init(authenticationRepository: AuthenticationRepositoryProtocol) {
        self.authenticationRepository = authenticationRepository
    }
    
    func updateBalance(username: String, balance: Double) -> AnyPublisher<Bool, Error> {
        return authenticationRepository.updateBalance(username: username, balance: balance)
    }
}
