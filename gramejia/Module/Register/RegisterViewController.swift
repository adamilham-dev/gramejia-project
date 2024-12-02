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
        setupFields()
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    private func setupFields() {
        nameField.setTextFieldProperty(leftSystemImage: "person.fill", placeholder: "Input your name")
        usernameField.setTextFieldProperty(leftSystemImage: "mail.fill", placeholder: "Input your username")
        passwordField.setTextFieldProperty(leftSystemImage: "lock.fill", placeholder: "Input your password")
        confirmationField.setTextFieldProperty(leftSystemImage: "key.fill", placeholder: "Input your confirmation password")
        
        nameField.mainTextField.textContentType = .name
        usernameField.mainTextField.textContentType = .username
        passwordField.mainTextField.textContentType = .newPassword
        confirmationField.mainTextField.textContentType = .newPassword
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
    
}
