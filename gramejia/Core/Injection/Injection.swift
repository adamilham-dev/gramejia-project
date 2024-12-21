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
    
    private func provideCartRepository() -> CartRepositoryProtocol {
        let coreDataManager = CoreDataManager.shared
        
        return CartRepository.sharedInstance(coreDataManager)
    }
    
    private func provideTransactionRepository() -> TransactionRepositoryProtocol {
        let coreDataManager = CoreDataManager.shared
        
        return TransactionRepository.sharedInstance(coreDataManager)
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
    
    func provideCartUseCase() -> CartUseCaseProtocol {
        let cartRepository = provideCartRepository()
        let authenticationRepository = provideAuthenticationRepository()
        let bookRepository = provideBookRepository()
        return CartUseCase(cartRepository: cartRepository, authenticationRepository: authenticationRepository, bookRepository: bookRepository )
    }
    
    func provideDetailBookUseCase() -> DetailBookUseCaseProtocol {
        let cartRepository = provideCartRepository()
        
        return DetailBookUseCase(cartRepository: cartRepository)
    }
    
    func provideTransactionUseCase() -> TransactionUseCaseProtocol {
        let transactionRepository = provideTransactionRepository()
        
        return TransactionUseCase(transactionRepository: transactionRepository)
    }
    
    func provideProfileUseCase() -> ProfileUseCase {
        let authenticationRepository = provideAuthenticationRepository()
        return ProfileUseCase(authenticationRepository: authenticationRepository)
    }
    
    func provideTopupUseCase() -> TopupUseCase {
        let authenticationRepository = provideAuthenticationRepository()
        return TopupUseCase(authenticationRepository: authenticationRepository)
    }
}
