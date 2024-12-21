//
//  HomeViewModel.swift
//  gramejia
//
//  Created by Adam on 08/12/24.
//

import Foundation
import Combine

class HomeViewModel: BaseViewModel {
    private var homeUseCase: HomeUseCaseProtocol = Injection().provideHomeUseCase()
    
    let bookList = CurrentValueSubject<[BookModel], Never>([])
    let userLevel: String = UserDefaultsManager.shared.get(forKey: .userLevel) ?? "customer"
    
    func getBookList(){
        isLoading.send(true)
        
        homeUseCase.getBookList()
            .receive(on: RunLoop.main)
            .sink(receiveCompletion: { [weak self] completion in
                self?.isLoading.send(false)
                switch(completion) {
                case .finished:
                    break
                case .failure(let error):
                    self?.error.send(error)
                }
            }, receiveValue: { [weak self] books in
                self?.bookList.send(books)
            })
            .store(in: &cancellables)
    }
}
