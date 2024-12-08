//
//  AddBookViewModel.swift
//  gramejia
//
//  Created by Adam on 30/11/24.
//

import Foundation
import Combine


class AddBookViewModel: BaseViewModel {
    private var addBookUseCase: AddBookUseCaseProtocol = Injection().provideAddBookUseCase()
    
    let isSuccessAddBook = CurrentValueSubject<Bool, Never>(false)
    
    //    func registerUser(customer: CustomerModel) {
    //        isLoading.send(true)
    //
    //        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
    //            self.registerUseCase.registerCustomer(customer: customer)
    //                .receive(on: RunLoop.main)
    //                .sink(receiveCompletion: { [weak self] completion in
    //                    self?.isLoading.send(false)
    //                    switch(completion) {
    //                    case .finished:
    //                        break
    //                    case .failure(let error):
    //                        self?.error.send(error)
    //                    }
    //                }, receiveValue: { [weak self] isSuccess in
    //                    self?.error.send(nil)
    //                    self?.isActionSuccess.send(isSuccess)
    //                })
    //                .store(in: &self.cancellables)
    //        }
    //    }
    
    func addBook(book: BookModel){
        isLoading.send(true)
        
        addBookUseCase.addBook(book: book)
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
                self?.isSuccessAddBook.send(isSuccess)
            })
            .store(in: &cancellables)
    }
}
