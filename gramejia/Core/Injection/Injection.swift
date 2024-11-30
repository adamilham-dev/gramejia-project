//
//  Injection.swift
//  gramejia
//
//  Created by Rivaldo Fernandes on 30/11/24.
//

import Foundation

final class Injection: NSObject {
    private func provideBookRepository() -> BookRepositoryProtocol {
        let coreDataManager = CoreDataManager.shared
        
        return BookRepository.sharedInstance(coreDataManager)
    }
}
