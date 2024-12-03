//
//  PopupModel.swift
//  gramejia
//
//  Created by Adam on 03/12/24.
//

import Foundation

struct PopupModel {
    var title: String?
    var description: String?
    var firstButtonTitle: String?
    var secondButtonTitle: String?
    
    init(title: String? = nil, description: String? = nil, firstButtonTitle: String? = nil, secondButtonTitle: String? = nil) {
        self.title = title
        self.description = description
        self.firstButtonTitle = firstButtonTitle
        self.secondButtonTitle = secondButtonTitle
    }
}
