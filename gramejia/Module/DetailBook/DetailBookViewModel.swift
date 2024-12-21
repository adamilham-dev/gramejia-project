//
//  DetailBookViewModel.swift
//  gramejia
//
//  Created by Adam on 14/12/24.
//

import Foundation
import Combine

class DetailBookViewModel: BaseViewModel {

    private var detailBookUseCase: DetailBookUseCaseProtocol = Injection().provideDetailBookUseCase()
    
    let isBookToCartSuccess = CurrentValueSubject<Bool, Never>(false)
    
    func addBookToCart(idBook: String, quantity: Int64) {
        isLoading.send(true)
        
            guard let username: String = UserDefaultsManager.shared.get(forKey: .currentUsername) else { return }
            
            self.detailBookUseCase.addBookToCart(username: username, idBook: idBook, quantity: quantity)
                .receive(on: RunLoop.main)
                .sink(receiveCompletion: { [weak self] completion in
                    switch(completion) {
                    case .finished:
                        break
                    case .failure(let error):
                        self?.error.send(error)
                    }
                }, receiveValue: { [weak self] isSuccess in
                    self?.error.send(nil)
                    self?.isBookToCartSuccess.send(isSuccess)
                })
                .store(in: &self.cancellables)
        }
}
