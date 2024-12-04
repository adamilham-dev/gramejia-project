//
//  PopupViewDelegate.swift
//  gramejia
//
//  Created by Adam on 03/12/24.
//

import Foundation


protocol PopupViewDelegate: AnyObject {
    func didTappedFirstButton()
    func didTappedSecondButton()
    func onDismissed()
}
