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
    let username: String = UserDefaultsManager.shared.get(forKey: .currentUsername) ?? ""
    let currentCartItem = CurrentValueSubject<CartItemModel?, Never>(nil)
    
    func addBookToCart(idBook: String, quantity: Int64) {
        isLoading.send(true)
        
        self.detailBookUseCase.addBookToCart(username: username, idBook: idBook, quantity: quantity, updatedDate: Date().ISO8601Format())
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
    
    func getCartBookItem(idBook: String) {
        isLoading.send(true)
        
        self.detailBookUseCase.getCartBookItem(username: username, idBook: idBook)
            .receive(on: RunLoop.main)
            .sink(receiveCompletion: { _ in
            }, receiveValue: { [weak self] cartItem in
                self?.currentCartItem.send(cartItem)
            })
            .store(in: &self.cancellables)
    }
}
