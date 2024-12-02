//
//  LoginViewController.swift
//  gramejia
//
//  Created by Adam on 01/12/24.
//

import UIKit

class LoginViewController: UIViewController {
    @IBOutlet weak var mainButton: UIButton!
    
    @IBOutlet weak var hookRegisterLabel: UILabel!
    @IBOutlet weak var mainScrollView: UIScrollView!
    var activeTextField: UITextField?
    
    @IBOutlet weak var usernameTextField: GeneralTextFieldView!
    @IBOutlet weak var passwordTextField: PasswordTextFieldView!
    
    open var toolbar = UIToolbar()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //        mainButton.showsTouchWhenHighlighted = true
        // Do any additional setup after loading the view.
        
        
        hookRegisterLabel.isUserInteractionEnabled = true
        let rootTappedGesture = UITapGestureRecognizer(target: self, action: #selector(rootTapped))
        hookRegisterLabel.addGestureRecognizer(rootTappedGesture)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
//        
//        usernameTextField.mainTextField.delegate = self
//        passwordTextField.mainTextField.delegate = self
    }
    
    @objc func rootTapped() {
        performSegue(withIdentifier: "goToRegister", sender: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    @objc func keyboardWillShow(notification: Notification) {
        guard let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else { return }
        let keyboardHeight = keyboardFrame.height

        // Adjust the scroll view's content inset
        mainScrollView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardHeight, right: 0)
        mainScrollView.scrollIndicatorInsets = mainScrollView.contentInset

        // Scroll to the active text field
        if let activeField = activeTextField {
            let fieldFrame = activeField.convert(activeField.bounds, to: mainScrollView)
            mainScrollView.scrollRectToVisible(fieldFrame, animated: true)
        }
    }
    
    @objc func keyboardWillHide(notification: Notification) {
        mainScrollView.contentInset = .zero
        mainScrollView.scrollIndicatorInsets = .zero
    }
    
    private func addToolbarView() {
        toolbar.sizeToFit()
        let done = UIBarButtonItem(barButtonSystemItem: .done, target: nil, action: #selector(dismissKeyboard))
        let spaceCalendar = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        toolbar.setItems([spaceCalendar, done], animated: false)
    }
    
    @objc open dynamic func onDonePressed() {
        view.endEditing(true)
    }
    
    @objc open dynamic func dismissKeyboard() {
        view.endEditing(true)
    }
}

extension LoginViewController: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        activeTextField = textField
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        activeTextField = nil
    }
}

