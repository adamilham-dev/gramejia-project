//
//  TransactionUseCase.swift
//  gramejia
//
//  Created by Adam on 18/12/24.
//

import Foundation
import Combine

protocol TransactionUseCaseProtocol {
    func addTransaction(username: String, transaction: TransactionModel) -> AnyPublisher<Bool, Error>
    
    func getTransactionList(username: String) -> AnyPublisher<[TransactionModel], Error>
    func getTransactionList() -> AnyPublisher<[TransactionModel], Error>
    
    func deleteTransaction(idTransaction: String) -> AnyPublisher<Bool, Error>
}

class TransactionUseCase: TransactionUseCaseProtocol {
    func deleteTransaction(idTransaction: String) -> AnyPublisher<Bool, Error> {
        return self.transactionRepository.deleteTransaction(idTransaction: idTransaction)
    }
    

    private let transactionRepository: TransactionRepositoryProtocol
    
    required init(transactionRepository: TransactionRepositoryProtocol) {
        self.transactionRepository = transactionRepository
    }
    
    func addTransaction(username: String, transaction: TransactionModel) -> AnyPublisher<Bool, Error> {
        return transactionRepository.addTransaction(username: username, transaction: transaction)
    }
    
    func getTransactionList(username: String) -> AnyPublisher<[TransactionModel], Error> {
        return transactionRepository.getTransactionList(username: username)
    }
    
    func getTransactionList() -> AnyPublisher<[TransactionModel], Error> {
        return transactionRepository.getTransactionList()
    }
}
