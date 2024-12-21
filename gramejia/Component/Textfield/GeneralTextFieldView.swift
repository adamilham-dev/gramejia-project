//
//  GeneralTextFieldView.swift
//  gramejia
//
//  Created by Adam on 01/12/24.
//

import UIKit

@objc protocol GeneralTextFieldViewDelegate: AnyObject {
    @objc optional func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool
    
    @objc optional func textFieldRightImageTapped(_ textField: UITextField)
    @objc optional func textFieldRootTapped(_ textField: UITextField)
}


class GeneralTextFieldView: UIView {
    
    @IBOutlet var rootView: UIView!
    @IBOutlet weak var mainStackView: UIStackView!
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var leftImageView: UIImageView!
    @IBOutlet weak var rightImageView: UIImageView!
    @IBOutlet weak var mainTextField: UITextField!
    @IBOutlet weak var fieldStackView: UIStackView!
    @IBOutlet weak var leftImageWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var rightImageWidthConstraint: NSLayoutConstraint!
    
    weak var delegate: GeneralTextFieldViewDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupView()
        
    }
    
    open func setupView() {
        guard let view = loadViewFromNib(nibName: String(describing: GeneralTextFieldView.self)) else { return }
        view.frame = bounds
        addSubview(view)
        
        mainTextField.delegate = self
        stylingView()
        setActions()
    }
    
    open func stylingView() {
        mainTextField.borderStyle = .none
        rootView.backgroundColor = .clear
        self.backgroundColor = .clear
        
        fieldStackView.layoutMargins = .init(top: 16, left: 16, bottom: 16, right: 16)
        fieldStackView.isLayoutMarginsRelativeArrangement = true
        fieldStackView.spacing = 8
        
        fieldStackView.addBorder(borderWidth: 2, borderColor: .mainBorderColor)
        fieldStackView.setCorner(cornerRadius: 16)
        mainStackView.spacing = 4
        mainTextField.isSecureTextEntry = false
        mainTextField.textContentType = .none
        mainTextField.keyboardType = .asciiCapable
    }
    
    open func setImageSize(_ size: CGFloat) {
        leftImageWidthConstraint.constant = size
        rightImageWidthConstraint.constant = size
    }
    
    private func loadViewFromNib(nibName: String) -> UIView? {
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: nibName, bundle: bundle)
        return nib.instantiate(withOwner: self, options: nil).first as? UIView
    }
    
    open func setActions() {
        self.isUserInteractionEnabled = true
        let rootTappedGesture = UITapGestureRecognizer(target: self, action: #selector(rootTapped))
        self.addGestureRecognizer(rootTappedGesture)
        
        rightImageView.isUserInteractionEnabled = true
        let rightImageTappedGesture = UITapGestureRecognizer(target: self, action: #selector(rightImageTapped))
        rightImageView.addGestureRecognizer(rightImageTappedGesture);
    }
    
    @objc open func rightImageTapped() {
        delegate?.textFieldRightImageTapped?(mainTextField)
    }
    
    @objc open func rootTapped() {
        mainTextField.becomeFirstResponder()
        delegate?.textFieldRootTapped?(mainTextField)
    }
    
    open func setTextFieldProperty(leftSystemImage: String? = nil, rightSystemImage: String? = nil, placeholder: String) {
        if let leftImage = leftSystemImage {
            self.leftImageView.image = UIImage(systemName: leftImage)
            self.leftImageView.isHidden = false
        }
        
        if let rightImage = rightSystemImage {
            self.rightImageView.image = UIImage(systemName: rightImage)
            self.rightImageView.isHidden = false
        }
        
        mainTextField.placeholder = placeholder
    }
    
    open func setError(description: String) {
        self.errorLabel.text = description
        self.errorLabel.isHidden = false
    }
    
    open func removeError(){
        self.errorLabel.isHidden = true
        self.errorLabel.text = nil
    }
}


extension GeneralTextFieldView: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        UIView.animate(withDuration: 0.1) { [weak self] in
            self?.fieldStackView.layer.borderColor = UIColor.black.cgColor
        }
        delegate?.textFieldRootTapped?(textField)
        
    }
    func textFieldDidEndEditing(_ textField: UITextField) {
        UIView.animate(withDuration: 0.1) { [weak self] in
            self?.fieldStackView.layer.borderColor = UIColor.mainBorderColor.cgColor
        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        return delegate?.textField?(textField, shouldChangeCharactersIn: range, replacementString: string) ?? true
    }
}

extension GeneralTextFieldView {
    func validateName(inputText: String) -> Bool {
        let textField = self
        let nameRegex = #"^[a-zA-Z\s\-’]+$"#
        let predicate = NSPredicate(format: "SELF MATCHES %@", nameRegex)
        let result = predicate.evaluate(with: inputText)
        
        if(!result) {
            textField.setError(description: "Invalid name, name cannot be empty or contains illegal characters")
            return false
        }
        textField.removeError()
        return result
    }
    
    func validateUsername(inputText: String) -> Bool {
        let textField = self
        let usernameRegex = "^[A-Za-z0-9]{4,}$"
        let predicate = NSPredicate(format: "SELF MATCHES %@", usernameRegex)
        let result = predicate.evaluate(with: inputText)
        
        if(!result) {
            textField.setError(description: "Invalid username, minimum 4 characters and not contain spaces")
            return false
        }
        textField.removeError()
        return result
    }
    
    func validatePassword(inputText: String) -> Bool {
        let textField = self
        let passwordRegex = "^.{8,}$"
        let predicate = NSPredicate(format: "SELF MATCHES %@", passwordRegex)
        let result = predicate.evaluate(with: inputText)
        
        if(!result) {
            textField.setError(description: "Invalid password, minimum 8 characters")
            return false
        }
        textField.removeError()
        return result
    }
    
    func validateConfirmationPassword(secondTextField: GeneralTextFieldView, inputText: String) -> Bool {
        let textField = self
        guard let currentPassword = secondTextField.mainTextField.text else { return false }
        
        let result = currentPassword == inputText
        
        print("LOGDEBUG: \(result)")
        
        if(!result) {
            textField.setError(description: "Password not match")
            return false
        }
        textField.removeError()
        return result
    }
    
    func validateConfirmationPassword(passwordText: String, inputText: String) -> Bool {
        let textField = self
        
        let result = passwordText == inputText

        if(!result) {
            textField.setError(description: "Password not match")
            return false
        }
        textField.removeError()
        return result
    }
    
    func validateDigits(inputText: String, minDigits: Int, maxDigits: Int) -> Bool {
        let textField = self
        let digitsRegex = #"^\d{13}$"#
        let predicate = NSPredicate(format: "SELF MATCHES %@", digitsRegex)
        let result = predicate.evaluate(with: inputText)
        
        if(!result) {
            textField.setError(description: "Invalid number, minimum \(minDigits) and maximum \(maxDigits) and not contain spaces")
            return false
        }
        textField.removeError()
        return result
    }
    
    func validateTitle(inputText: String) -> Bool {
        let textField = self
        let titleRegex = #"^[\w\s\p{P}’“”\-]+$"#
        let predicate = NSPredicate(format: "SELF MATCHES %@", titleRegex)
        let result = predicate.evaluate(with: inputText)
        
        if(!result) {
            textField.setError(description: "Invalid title, title should not empty or contains illegal characters")
            return false
        }
        textField.removeError()
        return result
    }
    
    func validateStock(inputText: String) -> Bool {
        let textField = self
        let stockRegex = #"^\d+$"#
        let predicate = NSPredicate(format: "SELF MATCHES %@", stockRegex)
        let result = predicate.evaluate(with: inputText)
        
        if(!result) {
            textField.setError(description: "Invalid stock, stock should not empty or negative")
            return false
        }
        textField.removeError()
        return result
    }
    
    func validatePrice(inputText: String) -> Bool {
        let textField = self
        let priceRegex = #"^\d+(\.\d{1,2})?$"#
        let predicate = NSPredicate(format: "SELF MATCHES %@", priceRegex)
        let result = predicate.evaluate(with: inputText)
        
        if(!result) {
            textField.setError(description: "Invalid price, price should not empty or negative")
            return false
        }
        textField.removeError()
        return result
    }
}
