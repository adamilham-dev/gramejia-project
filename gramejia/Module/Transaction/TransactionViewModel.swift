//
//  TransactionVIewModel.swift
//  gramejia
//
//  Created by Adam on 18/12/24.
//

import UIKit
import Combine

class TransactionViewModel: BaseViewModel {
    private var transactionUseCase: TransactionUseCaseProtocol = Injection().provideTransactionUseCase()
    
    let transactionlist = CurrentValueSubject<[TransactionModel], Never>([])
    let isTransactionDeleted = CurrentValueSubject<Bool, Never>(false)
    let userLevel: String = UserDefaultsManager.shared.get(forKey: .userLevel) ?? "customer"
    
    func getTransactionList(){
        guard let username: String = UserDefaultsManager.shared.get(forKey: .currentUsername) else { return }
        isLoading.send(true)
        
        if(userLevel == "customer") {
            transactionUseCase.getTransactionList(username: username)
                .receive(on: RunLoop.main)
                .sink(receiveCompletion: { [weak self] completion in
                    self?.isLoading.send(false)
                    switch(completion) {
                    case .finished:
                        break
                    case .failure(let error):
                        self?.error.send(error)
                    }
                }, receiveValue: { [weak self] transactions in
                    self?.transactionlist.send(transactions)
                })
                .store(in: &cancellables)
        } else {
            transactionUseCase.getTransactionList()
                .receive(on: RunLoop.main)
                .sink(receiveCompletion: { [weak self] completion in
                    self?.isLoading.send(false)
                    switch(completion) {
                    case .finished:
                        break
                    case .failure(let error):
                        self?.error.send(error)
                    }
                }, receiveValue: { [weak self] transactions in
                    self?.transactionlist.send(transactions)
                })
                .store(in: &cancellables)
        }
        
        
    }
    
    func deleteTransaction(idTransaction: String){
        isLoading.send(true)
        
        transactionUseCase.deleteTransaction(idTransaction: idTransaction)
            .receive(on: RunLoop.main)
            .sink(receiveCompletion: { [weak self] completion in
                self?.isLoading.send(false)
                switch(completion) {
                case .finished:
                    break
                case .failure(let error):
                    self?.error.send(error)
                }
            }, receiveValue: { [weak self] isSuccess in
                self?.isTransactionDeleted.send(isSuccess)
            })
            .store(in: &cancellables)
    }
}
