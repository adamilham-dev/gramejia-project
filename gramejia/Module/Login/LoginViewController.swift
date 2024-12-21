//
//  LoginViewController.swift
//  gramejia
//
//  Created by Adam on 01/12/24.
//

import UIKit
import Lottie
import Combine

class LoginViewController: BaseViewController<LoginViewModel> {
    @IBOutlet weak var mainButton: UIButton!
    
    @IBOutlet weak var hookRegisterLabel: UILabel!
    @IBOutlet weak var mainScrollView: UIScrollView!
    
    @IBOutlet weak var loginButton: MainActionButton!
    
    @IBOutlet weak var usernameField: GeneralTextFieldView!
    @IBOutlet weak var passwordField: PasswordTextFieldView!
    @IBOutlet weak var animationContainer: UIView!
    
    var usernameValidity = false
    var passwordValidity = false
    var activeTextField: UITextField?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.viewModel = LoginViewModel()
        
        setupView()
        setupAction()
        bindDataViewModel()
        viewModel.loadBooks()
    }
    
    private func setupView() {
        setupAnimation()
        mainScrollView.showsVerticalScrollIndicator = false
        setupFields()
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        loginButton.isEnabled = false
    }
    
    private func bindDataViewModel() {
        viewModel?.isUserLoggedIn
            .receive(on: DispatchQueue.main)
            .sink { [weak self] response in
                if response {
                    self?.resetForm()
                    self?.showSnackbar(message: "Successfully Logged In")
                    self?.performSegue(withIdentifier: "gotoDashboard", sender: self)
                }
            }
            .store(in: &cancellables)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "gotoDashboard" {
                guard let navigationController = self.navigationController else { return }
                navigationController.viewControllers.removeAll(where: { $0 != segue.destination })
        }
    }
    
    private func resetForm() {
        usernameField.mainTextField.text = ""
        passwordField.mainTextField.text = ""
        usernameValidity = false
        passwordValidity = false
        setStateMainButton()
    }
    
    private func setupAction() {
        hookRegisterLabel.isUserInteractionEnabled = true
        let hookRegisterLabelGesture = UITapGestureRecognizer(target: self, action: #selector(hookRegisterLabelTapped))
        hookRegisterLabel.addGestureRecognizer(hookRegisterLabelGesture)
        
    }
    
    private func setupFields() {
        usernameField.setTextFieldProperty(leftSystemImage: "mail.fill", placeholder: "Input your username")
        passwordField.setTextFieldProperty(leftSystemImage: "lock.fill", placeholder: "Input your password")
        
        usernameField.mainTextField.textContentType = .username
        passwordField.mainTextField.textContentType = .password
        
        usernameField.delegate = self
        passwordField.delegate = self
    }
    
    private func setupAnimation() {
        let loginAnimationView = LottieAnimationView(name: "login")
        animationContainer.addSubview(loginAnimationView)
        loginAnimationView.frame = animationContainer.bounds
        
        loginAnimationView.contentMode = .scaleAspectFit
        loginAnimationView.animationSpeed = 1.0
        loginAnimationView.loopMode = .loop
        loginAnimationView.play()
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
    
    private func setStateMainButton(){
        loginButton.isEnabled = (usernameValidity && passwordValidity)
    }
    
    @objc func keyboardWillHide(notification: Notification) {
        mainScrollView.contentInset = .zero
        mainScrollView.scrollIndicatorInsets = .zero
    }
    
    @objc func hookRegisterLabelTapped() {
        performSegue(withIdentifier: "goToRegister", sender: nil)
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    @IBAction func loginButtonTapped(_ sender: Any) {
        guard let username = usernameField.mainTextField.text,
              let password = passwordField.mainTextField.text else { return }
        viewModel.loginUser(username: username, password: password)
    }
}

extension LoginViewController: GeneralTextFieldViewDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        let currentText = textField.text ?? ""
        let updatedText = (currentText as NSString).replacingCharacters(in: range, with: string)
        if(textField == usernameField.mainTextField) {
            usernameValidity = usernameField.validateUsername(inputText: updatedText)
        } else if(textField == passwordField.mainTextField) {
            passwordValidity = passwordField.validatePassword(inputText: updatedText)
        }
        setStateMainButton()
        return true
    }
}

