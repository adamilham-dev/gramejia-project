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
    let isSuccessDeleteBook = CurrentValueSubject<Bool, Never>(false)
    
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
    
    func deleteBook(idBook: String) {
        isLoading.send(true)
        
        addBookUseCase.deleteBook(idBook: idBook)
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
                self?.isSuccessDeleteBook.send(isSuccess)
            })
            .store(in: &cancellables)
    }
    
    
}
