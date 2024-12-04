//
//  RegisterViewModel.swift
//  gramejia
//
//  Created by Adam on 02/12/24.
//

import Foundation
import Combine

class RegisterViewModel: BaseViewModel {
    private var registerUseCase: RegisterUseCaseProtocol = Injection().provideRegisterUseCase()

    let isActionSuccess = CurrentValueSubject<Bool, Never>(false)
    
    func registerUser(customer: CustomerModel) {
        isLoading.send(true)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            self.registerUseCase.registerCustomer(customer: customer)
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
                    self?.error.send(nil)
                    self?.isActionSuccess.send(isSuccess)
                })
                .store(in: &self.cancellables)
        }
    }
}
