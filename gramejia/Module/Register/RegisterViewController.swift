//
//  RegisterViewController.swift
//  gramejia
//
//  Created by Adam on 02/12/24.
//

import UIKit

class RegisterViewController: UIViewController {
    
    @IBOutlet weak var backButton: ImageActionButton!
    @IBOutlet weak var nameField: GeneralTextFieldView!
    @IBOutlet weak var usernameField: GeneralTextFieldView!
    @IBOutlet weak var passwordField: PasswordTextFieldView!
    @IBOutlet weak var confirmationField: PasswordTextFieldView!
    
    @IBOutlet weak var loginButton: MainActionButton!
    
    var nameValidity = false
    var usernameValidity = false
    var passwordValidity = false
    var confirmationValidity = false
    
    @IBOutlet weak var mainScrollView: UIScrollView!
    
    var activeTextField: UITextField?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
    }
    
    private func setupView() {
        backButton.image = UIImage(systemName: "chevron.backward")
        backButton.normalBackgroundColor = .black
        backButton.imagePadding = .init(top: 8, left: 8, bottom: 8, right: 8)
        
        mainScrollView.showsVerticalScrollIndicator = false
        
        setupFields()
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        loginButton.isEnabled = false
    }
    
    private func setupFields() {
        nameField.setTextFieldProperty(leftSystemImage: "person.fill", placeholder: "Input your name")
        usernameField.setTextFieldProperty(leftSystemImage: "mail.fill", placeholder: "Input your username")
        passwordField.setTextFieldProperty(leftSystemImage: "lock.fill", placeholder: "Input your password")
        confirmationField.setTextFieldProperty(leftSystemImage: "key.fill", placeholder: "Input your confirmation password")
        
        nameField.mainTextField.textContentType = .name
        usernameField.mainTextField.textContentType = .username
        passwordField.mainTextField.textContentType = .password
        confirmationField.mainTextField.textContentType = .password
        
        nameField.mainTextField.delegate = self
        usernameField.mainTextField.delegate = self
        passwordField.mainTextField.delegate = self
        confirmationField.mainTextField.delegate = self
    }
    
    @objc func keyboardWillShow(notification: Notification) {
        guard let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else { return }
        let keyboardHeight = keyboardFrame.height
        
        mainScrollView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardHeight, right: 0)
        mainScrollView.scrollIndicatorInsets = mainScrollView.contentInset
        
        if let activeField = activeTextField {
            let fieldFrame = activeField.convert(activeField.bounds, to: mainScrollView)
            mainScrollView.scrollRectToVisible(fieldFrame, animated: true)
        }
    }
    
    @objc func keyboardWillHide(notification: Notification) {
        mainScrollView.contentInset = .zero
        mainScrollView.scrollIndicatorInsets = .zero
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    @IBAction func backButtonAction(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    private func validateName(textField: GeneralTextFieldView, inputText: String) -> Bool {
        let nameRegex = "^(?=.*[A-Za-z])[A-Za-z ]{4,}$"
        let predicate = NSPredicate(format: "SELF MATCHES %@", nameRegex)
        let result = predicate.evaluate(with: inputText)
        
        if(!result) {
            textField.setError(description: "Invalid name, minimum 4 characters of alphabet")
            return false
        }
        textField.removeError()
        return result
        
        
    }
    
    private func validateUsername(textField: GeneralTextFieldView, inputText: String) -> Bool {
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
    
    private func validatePassword(textField: GeneralTextFieldView, inputText: String) -> Bool {
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
    
    private func validateConfirmationPassword(mainTextField: GeneralTextFieldView, secondTextField: GeneralTextFieldView, inputText: String) -> Bool {
        
        guard let currentPassword = secondTextField.mainTextField.text else { return false }
        
        let result = currentPassword == inputText
        
        if(!result) {
            mainTextField.setError(description: "Password not match")
            return false
        }
        mainTextField.removeError()
        return result
    }
    
    private func setStateMainButton(){
        loginButton.isEnabled = (nameValidity && usernameValidity && passwordValidity && confirmationValidity)
    }
}


extension RegisterViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        let currentText = textField.text ?? ""
        let updatedText = (currentText as NSString).replacingCharacters(in: range, with: string)
        if(textField == nameField.mainTextField) {
            nameValidity = validateName(textField: nameField, inputText: updatedText)
        } else if(textField == usernameField.mainTextField) {
            usernameValidity = validateUsername(textField: usernameField, inputText: updatedText)
        } else if(textField == passwordField.mainTextField) {
            passwordValidity = validatePassword(textField: passwordField, inputText: updatedText)
        } else {
            confirmationValidity = validateConfirmationPassword(mainTextField: confirmationField, secondTextField: passwordField, inputText: updatedText)
        }
        setStateMainButton()
        return true
    }
}
