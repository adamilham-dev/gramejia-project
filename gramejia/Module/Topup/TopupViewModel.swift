//
//  TopupViewModel.swift
//  gramejia
//
//  Created by Adam on 21/12/24.
//

import Foundation
import Combine

class TopupViewModel: BaseViewModel {
    private var topupUseCase: TopupUseCaseProtocol = Injection().provideTopupUseCase()
    let username: String = UserDefaultsManager.shared.get(forKey: .currentUsername) ?? ""
    
    let denomList: [Double] = [
        50000,
        100000,
        150000,
        200000,
        250000,
        300000,
        350000,
        400000,
        450000,
        500000,
        550000,
        600000,
        650000,
        700000,
        750000,
        800000
    ]
    
    let isSuccessUpdateBalance = CurrentValueSubject<Bool, Never>(false)
    
    func updateBalance(balance: Double){
        isLoading.send(true)
        
        topupUseCase.updateBalance(username: username, balance: balance)
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
                self?.isSuccessUpdateBalance.send(isSuccess)
            })
            .store(in: &cancellables)
    }
    
}
