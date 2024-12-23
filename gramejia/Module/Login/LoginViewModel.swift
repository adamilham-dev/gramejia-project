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
    
    func preloadData() {
        let isFirstTime: Bool? = UserDefaultsManager.shared.get(forKey: .isFirstTime)
        if(isFirstTime == false) {
            
        } else {
            
            loginUseCase.registerAdmin(admin: AdminModel(name: "Root", username: "root", password: "rootgramejia"))
                .sink { _ in } receiveValue: { _ in }
                .store(in: &cancellables)

            
            guard let url = Bundle.main.url(forResource: "preload", withExtension: "json") else { return }
            do {
                let data = try Data(contentsOf: url)
                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase // Adjust for snake_case keys if necessary
                let books = try decoder.decode([BookModel].self, from: data)
                
                CoreDataManager.shared.addMultiple(entity: BookEntity.self) { context in
                    for book in books {
                        let newEntity = BookEntity(context: context)
                        BookMapper.bookDomainToEntity(book, entity: newEntity)
                    }
                }.receive(on: RunLoop.main)
                    .sink { _ in } receiveValue: { _ in }.store(in: &cancellables)
            } catch {}
            UserDefaultsManager.shared.set(value: false, forKey: .isFirstTime)
        }
    }
    
    func loginUser(username: String, password: String) {
        isLoading.send(true)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            
            self.loginUseCase.authenticateAdmin(username: username, password: password)
                .combineLatest(self.loginUseCase.authenticateCustomer(username: username, password: password))
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
                        UserDefaultsManager.shared.set(value: true, forKey: .isSignedIn)
                        UserDefaultsManager.shared.set(value: admin.username, forKey: .currentUsername)
                        UserDefaultsManager.shared.set(value: admin.name, forKey: .currentUserFullname)
                        UserDefaultsManager.shared.set(value: "admin", forKey: .userLevel)
                        
                    } else if let customer = customer {
                        self?.userFullname.send(customer.name)
                        self?.userUsername.send(customer.username)
                        self?.isUserLoggedIn.send(true)
                        UserDefaultsManager.shared.set(value: true, forKey: .isSignedIn)
                        UserDefaultsManager.shared.set(value: customer.username, forKey: .currentUsername)
                        UserDefaultsManager.shared.set(value: customer.name, forKey: .currentUserFullname)
                        UserDefaultsManager.shared.set(value: "customer", forKey: .userLevel)
                    } else {
                        self?.error.send(DatabaseError.dataNotFound)
                    }
                })
                .store(in: &self.cancellables)
        }
    }
}
