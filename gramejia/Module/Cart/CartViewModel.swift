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
    let totalCost = CurrentValueSubject<Double, Never>(0)
    let customerBalance = CurrentValueSubject<Double, Never>(0)
    let isTransactionAdded = CurrentValueSubject<Bool, Never>(false)
    
    func getCarts(){
        isLoading.send(true)
        
        cartUseCase.getCartList(username: "aaaa")
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
                self?.totalCost.send(books.reduce(0, {  $0 + (Double($1.quantity) * ($1.book?.price ?? 0)) }))
                
            })
            .store(in: &cancellables)
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
        let transaction = TransactionModel(id: UUID().uuidString, transactionDate: Date().ISO8601Format(), items: transactionItems)
        
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
}