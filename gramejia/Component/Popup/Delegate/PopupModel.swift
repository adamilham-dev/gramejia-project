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
    var category: CategoryPopup
    var firstAction: ActionPopup
    var secondAction: ActionPopup
    
    init( category: CategoryPopup = .general, title: String? = nil, description: String? = nil, firstButtonTitle: String? = nil, secondButtonTitle: String? = nil, firstAction: ActionPopup = .dismiss, secondAction: ActionPopup = .dismiss) {
        self.category = category
        self.title = title
        self.description = description
        self.firstButtonTitle = firstButtonTitle
        self.secondButtonTitle = secondButtonTitle
        self.firstAction = firstAction
        self.secondAction = secondAction
    }
}

enum CategoryPopup {
    case general
}

enum ActionPopup {
    case dismiss
}
