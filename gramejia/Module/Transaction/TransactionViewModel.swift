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
    
    func getTransactionList(){
        guard let username: String = UserDefaultsManager.shared.get(forKey: .currentUsername) else { return }
        isLoading.send(true)
        
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
    }
}
