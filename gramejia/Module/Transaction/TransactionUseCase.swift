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
}

class TransactionUseCase: TransactionUseCaseProtocol {

    private let transactionRepository: TransactionRepositoryProtocol
    
    required init(transactionRepository: TransactionRepositoryProtocol) {
        self.transactionRepository = transactionRepository
    }
    
    func addTransaction(username: String, transaction: TransactionModel) -> AnyPublisher<Bool, Error> {
        return transactionRepository.addTransaction(username: username, transaction: transaction)
    }
    
    func getTransactionList(username: String) -> AnyPublisher<[TransactionModel], any Error> {
        return transactionRepository.getTransactionList(username: username)
    }
}
