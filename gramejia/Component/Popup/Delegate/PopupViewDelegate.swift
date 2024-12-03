//
//  PopupViewDelegate.swift
//  gramejia
//
//  Created by Adam on 03/12/24.
//

import Foundation


@objc protocol PopupViewDelegate: AnyObject {
    @objc optional func didTappedFirstButton()
    @objc optional func didTappedSecondButton()
    @objc optional func onDismissed()
}
