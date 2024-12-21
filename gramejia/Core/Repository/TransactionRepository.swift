//
//  TransactionRepository.swift
//  gramejia
//
//  Created by Adam on 18/12/24.
//

import Foundation
import Combine

protocol TransactionRepositoryProtocol {
    func addTransaction(username: String, transaction: TransactionModel) -> AnyPublisher<Bool, Error>
    
    func getTransactionList(username: String) -> AnyPublisher<[TransactionModel], Error>
}

final class TransactionRepository: NSObject {
    typealias TransationRepositoryInstance  = (CoreDataManager) -> TransactionRepository
    
    fileprivate let coreDataManager: CoreDataManager
    
    private init(coreDataManager: CoreDataManager) {
        self.coreDataManager = coreDataManager
    }
    
    static let sharedInstance: TransationRepositoryInstance = { coreDataManager in
        return TransactionRepository(coreDataManager: coreDataManager)
    }
}

extension TransactionRepository: TransactionRepositoryProtocol {
    func getTransactionList(username: String) -> AnyPublisher<[TransactionModel], any Error> {
        return self.coreDataManager.fetch(TransactionEntity.self)
            .map { $0.map { TransactionMapper.transactionEntityToDomain($0) } }
            .eraseToAnyPublisher()
    }
    
    func addTransaction(username: String, transaction: TransactionModel) -> AnyPublisher<Bool, Error> {
        self.coreDataManager.addTransaction(username: username) { context, customer in
            let transactionEntity = TransactionEntity(context: context)
            transactionEntity.owner = customer
            transactionEntity.id = UUID().uuidString
            transactionEntity.transactionDate = Date().ISO8601Format()
            
            for itemTransaction in transaction.items {
                let itemEntity = TransactionItemEntity(context: context)
                TransactionMapper.transactionItemDomainToEntity(itemTransaction, entity: itemEntity)
                itemEntity.transaction = transactionEntity
            }
        }
    }
}
