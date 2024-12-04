//
//  BaseViewModel.swift
//  gramejia
//
//  Created by Adam on 03/12/24.
//

import UIKit
import Combine

class BaseViewModel {
    var cancellables = Set<AnyCancellable>()
    
    let error = CurrentValueSubject<Error?, Never>(nil)
    let isLoading = CurrentValueSubject<Bool, Never>(false)
}
