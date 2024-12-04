//
//  LoginViewModel.swift
//  gramejia
//
//  Created by Adam on 01/12/24.
//

import Foundation
import Combine

class LoginViewModel: BaseViewModel {
    private var loginUseCase: LoginUseCaseProtocol = Injection().provideLoginUseCase()
    
    let isUserLoggedIn = CurrentValueSubject<Bool, Never>(false)
    let userFullname = CurrentValueSubject<String?, Never>(nil)
    let userUsername = CurrentValueSubject<String?, Never>(nil)
    
    func loginUser(username: String, password: String) {
        isLoading.send(true)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            
            self.loginUseCase.getAdmin(username: username, password: password)
                .combineLatest(self.loginUseCase.getCustomer(username: username, password: password))
                .sink(receiveCompletion: { [weak self] completion in
                    self?.isLoading.send(false)
                    switch(completion) {
                    case .finished:
                        break
                    case .failure(let error):
                        self?.error.send(error)
                    }
                }, receiveValue: { [weak self] admin, customer in
                    if let admin = admin {
                        self?.userFullname.send(admin.name)
                        self?.userUsername.send(admin.username)
                        self?.isUserLoggedIn.send(true)
                    } else if let customer = customer {
                        self?.userFullname.send(customer.name)
                        self?.userUsername.send(customer.username)
                        self?.isUserLoggedIn.send(true)
                    } else {
                        self?.isUserLoggedIn.send(false)
                    }
                })
                .store(in: &self.cancellables)
        }
    }
}
