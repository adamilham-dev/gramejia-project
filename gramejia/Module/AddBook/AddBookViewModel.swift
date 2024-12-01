//
//  AddBookViewModel.swift
//  gramejia
//
//  Created by Adam on 30/11/24.
//

import Foundation
import Combine


class AddBookViewModel {
    private var cancellables = Set<AnyCancellable>()
    private var addBookUseCase: AddBookUseCaseProtocol = Injection().provideAddBookUseCase()
    
    var errorState = PassthroughSubject<Error, Never>()
    @Published var isSuccessAddedBook: Bool = false
    
    func addBook(book: BookModel){
        addBookUseCase.addBook(book: book)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                switch(completion) {
                case .finished:
                    break
                case .failure(let error):
                    self?.errorState.send(error)
                }
            }, receiveValue: { [weak self] isSuccess in
                self?.isSuccessAddedBook = isSuccess
            })
            .store(in: &cancellables)
    }
    
    func getBookList() {
        addBookUseCase.getBookList()
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                
            }, receiveValue: { bookList in
                print("LOGDEBUG: get booklist \(bookList)")
            })
            .store(in: &cancellables)
    }
}
