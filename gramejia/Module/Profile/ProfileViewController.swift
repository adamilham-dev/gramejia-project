//
//  ProfileViewController.swift
//  gramejia
//
//  Created by Adam on 04/12/24.
//

import UIKit

class ProfileViewController: BaseViewController<ProfileViewModel> {
    
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var changeImageButton: ImageActionButton!
    
    @IBOutlet weak var balanceField: GeneralTextFieldView!
    @IBOutlet weak var nameField: GeneralTextFieldView!
    
    @IBOutlet weak var usernameField: GeneralTextFieldView!
    
    @IBOutlet weak var balanceStack: UIStackView!
    @IBOutlet weak var passwordField: PasswordTextFieldView!
    @IBOutlet weak var confirmationField: PasswordTextFieldView!
    @IBOutlet weak var mainScrollView: UIScrollView!
    
    @IBOutlet weak var updateProfileButton: MainActionButton!
    
    
    var nameValidity = false
    var passwordValidity = false
    var confirmationValidity = false
    
    var activeTextField: UITextField?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.viewModel = ProfileViewModel()
        setupView()
        bindDataViewModel()
    }
    
    @objc func saveButtonTapped() {
        
    }
    
    private func setupView() {
        setupNavigation()
        
        profileImageView.setCorner(cornerRadius: 60)
        profileImageView.contentMode = .scaleAspectFill
        
        changeImageButton.image = UIImage(systemName: "camera.fill")
        changeImageButton.imageColor = .black
        changeImageButton.normalBackgroundColor = .white
        changeImageButton.imagePadding = .init(top: 8, left: 8, bottom: 8, right: 8)
        
        setupFields()
    }
    
    @objc private func logoutButtonTapped() {
        let alert = UIAlertController(title: "Are you sure to logout?", message: "You must relogin after this action", preferredStyle: .alert)
        let continueButton = UIAlertAction(title: "Continue", style: .default) { _ in
            self.viewModel.logoutUser()
            self.navigateToLogin()
        }
        let cancelButton = UIAlertAction(title: "Cancel", style: .destructive)
        
        alert.addAction(continueButton)
        alert.addAction(cancelButton)
        self.present(alert, animated: true)
    }
    
    private func navigateToLogin() {
        guard let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = scene.windows.first else {
            print("No active window scene found")
            return
        }
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let loginVC = storyboard.instantiateViewController(withIdentifier: "MainNavigationController") // Replace with your Login VC identifier

        window.rootViewController = loginVC
        window.makeKeyAndVisible()
    }
    
    private func setupNavigation() {
        navigationController?.navigationBar.tintColor = .mainAccent
        
        let logoutButton = UIBarButtonItem(
            image: UIImage(systemName: "rectangle.portrait.and.arrow.right"),
            style: .plain,
            target: self,
            action: #selector(logoutButtonTapped)
        )
        
        logoutButton.tintColor = .black
        navigationItem.rightBarButtonItem = logoutButton
        self.title = "Profile"
    }
    
    private func setupFields() {
        balanceField.setTextFieldProperty(leftSystemImage: "banknote.fill", rightSystemImage: "plus.app.fill", placeholder: "")
        nameField.setTextFieldProperty(leftSystemImage: "person.fill", placeholder: "Input your name")
        passwordField.setTextFieldProperty(leftSystemImage: "lock.fill", placeholder: "Input your password")
        confirmationField.setTextFieldProperty(leftSystemImage: "key.fill", placeholder: "Input your confirmation password")
        usernameField.setTextFieldProperty(leftSystemImage: "mail.fill", placeholder: "Input your username")
        usernameField.isUserInteractionEnabled = false
        
        balanceField.mainTextField.isUserInteractionEnabled = false
        nameField.mainTextField.textContentType = .name
        passwordField.mainTextField.textContentType = .password
        confirmationField.mainTextField.textContentType = .password
        balanceStack.isHidden = viewModel.typeUser == "admin"
        balanceField.delegate = self
        nameField.delegate = self
        passwordField.delegate = self
        confirmationField.delegate = self
    }
    
    private func bindDataViewModel() {
        
        viewModel?.userProfile
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] userProfile in
                self?.nameField.mainTextField.text = userProfile?.name
                self?.passwordField.mainTextField.text = userProfile?.password
                self?.confirmationField.mainTextField.text = userProfile?.password
                self?.usernameField.mainTextField.text = userProfile?.username
                self?.balanceField.mainTextField.text = userProfile?.balance?.toRupiah()
                
                self?.nameValidity = !(userProfile?.name ?? "").isEmpty
                self?.passwordValidity = !(userProfile?.password ?? "").isEmpty
                self?.confirmationValidity = (self?.passwordField.mainTextField.text == self?.confirmationField.mainTextField.text)
                
                if let imageString = userProfile?.profileImage, !imageString.isEmpty {
                    if let imageData = Data(base64Encoded: imageString) {
                        self?.profileImageView.image = UIImage(data: imageData)
                    }
                }
                self?.setStateMainButton()
                self?.resetErrorInline()
            })
            .store(in: &cancellables)
        
        viewModel?.isSuccessUpdateUser
            .receive(on: DispatchQueue.main)
            .sink { [weak self] response in
                if response {
                    self?.showSnackbar(message: "Successfully Update Profile")
                }
            }
            .store(in: &cancellables)
    }
    
    private func resetErrorInline() {
        nameField.removeError()
        passwordField.removeError()
        confirmationField.removeError()
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
    
    
    @IBAction func changeImageButtonTapped(_ sender: Any) {
        showImagePickerOptions()
    }
    
    func showImagePickerOptions() {
        let alertController = UIAlertController(title: "Select Image", message: "Choose where you want to pick an image from.", preferredStyle: .actionSheet)
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            alertController.addAction(UIAlertAction(title: "Camera", style: .default, handler: { _ in
                self.presentImagePicker(sourceType: .camera)
            }))
        }
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            alertController.addAction(UIAlertAction(title: "Photo Library", style: .default, handler: { _ in
                self.presentImagePicker(sourceType: .photoLibrary)
            }))
        }
        
        if let imageString = viewModel.userProfile.value?.profileImage, !imageString.isEmpty {
            alertController.addAction(UIAlertAction(title: "Delete Image", style: .destructive, handler: { _ in
                self.profileImageView.image = UIImage(named: "icon-profile-placeholder")
                self.viewModel.userProfile.value?.profileImage = nil
            }))
        }
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: {_ in
        }))
        self.present(alertController, animated: true, completion: nil)
    }
    
    func presentImagePicker(sourceType: UIImagePickerController.SourceType) {
        if sourceType == .camera {
            if UIImagePickerController.isSourceTypeAvailable(.camera) {
                let imagePickerController = UIImagePickerController()
                imagePickerController.sourceType = .camera
                imagePickerController.delegate = self
                self.present(imagePickerController, animated: true, completion: nil)
            } else {
                let alert = UIAlertController(title: "Error", message: "Camera is not available on this device.", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
        } else if sourceType == .photoLibrary {
            let imagePickerController = UIImagePickerController()
            imagePickerController.sourceType = .photoLibrary
            imagePickerController.delegate = self
            self.present(imagePickerController, animated: true, completion: nil)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.getUser()
    }
    
    private func setStateMainButton(){
        updateProfileButton.isEnabled = (nameValidity && passwordValidity && confirmationValidity)
    }
    
    @IBAction func updateProfileButtonTapped(_ sender: Any) {
        guard let name = nameField.mainTextField.text,
              let username = usernameField.mainTextField.text,
              let password = passwordField.mainTextField.text else { return }
        
        self.viewModel.userProfile.value?.name = name
        self.viewModel.userProfile.value?.username = username
        self.viewModel.userProfile.value?.password = password
        
        self.viewModel?.updateUser()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "gotoTopup",
           let topupVC = segue.destination as? TopupViewController {
            topupVC.hidesBottomBarWhenPushed = true
        }
    }
    
}

extension ProfileViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let selectedImage = info[.originalImage] as? UIImage {
            self.profileImageView.image = selectedImage
            self.viewModel.userProfile.value?.profileImage = selectedImage.compressTo(targetSizeKB: 2024)?.base64EncodedString()
        } else {
            self.profileImageView.image = nil
        }
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}

extension ProfileViewController: GeneralTextFieldViewDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        let currentText = textField.text ?? ""
        let updatedText = (currentText as NSString).replacingCharacters(in: range, with: string)
        if(textField == nameField.mainTextField) {
            nameValidity = nameField.validateName(inputText: updatedText)
        } else if(textField == passwordField.mainTextField) {
            passwordValidity = passwordField.validatePassword(inputText: updatedText)
            confirmationValidity = confirmationField.validateConfirmationPassword(passwordText: updatedText, inputText: confirmationField.mainTextField.text ?? "")
        } else if(textField == confirmationField.mainTextField){
            confirmationValidity = confirmationField.validateConfirmationPassword(secondTextField: passwordField, inputText: updatedText)
        }
        setStateMainButton()
        return true
    }
    
    func textFieldRightImageTapped(_ textField: UITextField) {
        if(textField == balanceField.mainTextField) {
            performSegue(withIdentifier: "gotoTopup", sender: nil)
        }
    }
    
    func textFieldRootTapped(_ textField: UITextField) {
        if(textField == balanceField.mainTextField) {
            performSegue(withIdentifier: "gotoTopup", sender: nil)
        }
    }
}
