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
    }
    
    override func setActions() {
        super.setActions()
        
        rightImageView.isUserInteractionEnabled = true
        let rightImageTappedGesture = UITapGestureRecognizer(target: self, action: #selector(rightImageTapped))
        rightImageView.addGestureRecognizer(rightImageTappedGesture)
    }
    
    @objc private func rightImageTapped() {
        isSecurePassword.toggle()
        updateStateTextField()
    }
    
    private func updateStateTextField() {
        mainTextField.isSecureTextEntry = isSecurePassword
        rightImageView.image = UIImage(systemName: isSecurePassword ? "eye.fill" : "eye.slash.fill")
    }
}
