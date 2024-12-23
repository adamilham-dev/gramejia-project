//
//  CartViewModel.swift
//  gramejia
//
//  Created by Adam on 15/12/24.
//

import UIKit
import Combine

class CartViewModel: BaseViewModel {
    private var cartUseCase: CartUseCaseProtocol = Injection().provideCartUseCase()
    private var transactionUseCase: TransactionUseCaseProtocol = Injection().provideTransactionUseCase()
    
    let cartItemList = CurrentValueSubject<[CartItemModel], Never>([])
    let cartUserList = CurrentValueSubject<[CartModel], Never>([])
    
    let customerBalance = CurrentValueSubject<Double, Never>(0)
    let isTransactionAdded = CurrentValueSubject<Bool, Never>(false)
    let isCartItemDeleted = CurrentValueSubject<Bool, Never>(false)
    let isCartUserDeleted = CurrentValueSubject<Bool, Never>(false)
    let isSuccessUpdateBalance = CurrentValueSubject<Bool, Never>(false)
    let isSuccessUpdateStockBook = CurrentValueSubject<Bool, Never>(false)
    let username: String = UserDefaultsManager.shared.get(forKey: .currentUsername) ?? ""
    let userLevel: String = UserDefaultsManager.shared.get(forKey: .userLevel) ?? "customer"
    
    func getCarts(){
        isLoading.send(true)
        
        if(userLevel == "customer") {
            cartUseCase.getCartList(username: username)
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
                    self?.cartItemList.send(books)
                })
                .store(in: &cancellables)
        } else {
            cartUseCase.getAllUserCart()
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
                    self?.cartUserList.send(books.filter({ !$0.items.isEmpty }))
                })
                .store(in: &cancellables)
        }
    }
    
    func getCustomer() {
        guard let username: String = UserDefaultsManager.shared.get(forKey: .currentUsername) else { return }
        isLoading.send(true)
        cartUseCase.getCustomer(username: username)
            .receive(on: RunLoop.main)
            .sink(receiveCompletion: { [weak self] completion in
                self?.isLoading.send(false)
                switch(completion) {
                case .finished:
                    break
                case .failure(let error):
                    self?.error.send(error)
                }
            }, receiveValue: { [weak self] customer in
                self?.customerBalance.send(customer?.balance ?? 0)
            })
            .store(in: &cancellables)
    }
    
    func checkoutTransaction() {
        guard let username: String = UserDefaultsManager.shared.get(forKey: .currentUsername) else { return }
        isLoading.send(true)
        
        let transactionItems = cartItemList.value.map { cartItem in
            return TransactionItemModel(id: UUID().uuidString, idBook: cartItem.book?.id ?? "", author: cartItem.book?.author ?? "", coverImage: cartItem.book?.coverImage, price: cartItem.book?.price ?? 0, publishedDate: cartItem.book?.publishedDate ?? "", publisher: cartItem.book?.publisher ?? "", quantity: cartItem.quantity, synopsis: cartItem.book?.synopsis ?? "", title: cartItem.book?.title ?? "")
        }
        let transaction = TransactionModel(id: UUID().uuidString, transactionDate: Date().ISO8601Format(), items: transactionItems, owner: nil)
        
        transactionUseCase.addTransaction(username: username, transaction: transaction)
            .receive(on: RunLoop.main)
            .sink(receiveCompletion: { [weak self] completion in
                self?.isLoading.send(false)
                switch(completion) {
                case .finished:
                    break
                case .failure(let error):
                    self?.error.send(error)
                }
            }, receiveValue: { [weak self] isSuccesAddTransaction in
                self?.isTransactionAdded.send(isSuccesAddTransaction)
            })
            .store(in: &cancellables)
    }
    
    func deleteCartItem(idBook: String, username: String = UserDefaultsManager.shared.get(forKey: .currentUsername) ?? "") {
        isLoading.send(true)
        
        self.cartUseCase.deleteCartBookItem(username: username, idBook: idBook)
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
                self?.isCartItemDeleted.send(isSuccess)
            })
            .store(in: &self.cancellables)
    }
    
    func updateBalance(balance: Double){
        isLoading.send(true)
        
        self.cartUseCase.updateBalance(username: username, balance: balance)
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
    
    func updateStockBook(){
        isLoading.send(true)
        
        self.cartUseCase.updateBookStock(username: username, cartItems: cartItemList.value)
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
                self?.isSuccessUpdateStockBook.send(isSuccess)
            })
            .store(in: &cancellables)
    }
}
