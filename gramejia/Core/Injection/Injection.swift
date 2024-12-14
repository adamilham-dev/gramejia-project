//
//  Injection.swift
//  gramejia
//
//  Created by Adam on 30/11/24.
//

import Foundation

final class Injection: NSObject {
    private func provideBookRepository() -> BookRepositoryProtocol {
        let coreDataManager = CoreDataManager.shared
        
        return BookRepository.sharedInstance(coreDataManager)
    }
    
    private func provideAuthenticationRepository() -> AuthenticationRepositoryProtocol {
        let coreDataManager = CoreDataManager.shared
        
        return AuthenticationRepository.sharedInstance(coreDataManager)
    }
    
    func provideAddBookUseCase() -> AddBookUseCaseProtocol {
        let bookRepository = provideBookRepository()
        return AddBookUseCase(bookRepository: bookRepository)
    }
    
    func provideRegisterUseCase() -> RegisterUseCaseProtocol {
        let authenticationRepository = provideAuthenticationRepository()
        return RegisterUseCase(authenticationRepository: authenticationRepository)
    }
    
    func provideLoginUseCase() -> LoginUseCaseProtocol {
        let authenticationRepository = provideAuthenticationRepository()
        return LoginUseCase(authenticationRepository: authenticationRepository)
    }
    
    func provideHomeUseCase() -> HomeUseCaseProtocol {
        let bookRepository = provideBookRepository()
        return HomeUseCase(bookRepository: bookRepository)
    }
}
