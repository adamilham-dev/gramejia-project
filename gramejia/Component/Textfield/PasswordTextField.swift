//
//  PaswordTextField.swift
//  gramejia
//
//  Created by Adam on 02/12/24.
//

import UIKit

class PasswordTextFieldView: GeneralTextFieldView {
    private var isSecurePassword: Bool = true
    
    override func setupView() {
        super.setupView()
    }
    
    override func stylingView() {
        super.stylingView()
        
        self.rightImageView.isHidden = false
        self.leftImageView.isHidden = false
        self.leftImageView.image = UIImage(systemName: "key.fill")
        updateStateTextField()
        
        mainTextField.keyboardType = .default
        mainTextField.textContentType = .password
    }
    
    override func rightImageTapped() {
        isSecurePassword.toggle()
        updateStateTextField()
    }
    
    private func updateStateTextField() {
        mainTextField.isSecureTextEntry = isSecurePassword
        rightImageView.image = UIImage(systemName: isSecurePassword ? "eye.fill" : "eye.slash.fill")
    }
}
