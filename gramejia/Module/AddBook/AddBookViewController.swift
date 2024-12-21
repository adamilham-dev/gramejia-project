//
//  AddBookViewController.swift
//  gramejia
//
//  Created by Adam on 30/11/24.
//

import UIKit

class AddBookViewController: BaseViewController<AddBookViewModel>, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    @IBOutlet weak var mainScrollView: UIScrollView!
    @IBOutlet weak var isbnField: GeneralTextFieldView!
    @IBOutlet weak var imageField: ImageFieldView!
    @IBOutlet weak var titleField: GeneralTextFieldView!
    @IBOutlet weak var synopsisField: GeneralTextView!
    @IBOutlet weak var authorField: GeneralTextFieldView!
    @IBOutlet weak var publisherField: GeneralTextFieldView!
    @IBOutlet weak var publishedDateField: GeneralTextFieldView!
    @IBOutlet weak var priceField: GeneralTextFieldView!
    @IBOutlet weak var stockField: GeneralTextFieldView!
    @IBOutlet weak var submitButton: MainActionButton!
    
    var bookModel: BookModel? = nil
    
    
    var formValidity = [
        "isbn": false,
        "image": false,
        "title": false,
        "synopsis": false,
        "author": false,
        "publisher": false,
        "publishedDate": false,
        "price": false,
        "stock": false
    ]
    
    var activeTextField: UITextField?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.viewModel = AddBookViewModel()
        
        setupView()
        bindDataViewModel()
        setBookToView()
    }
    
    private func setupView() {
        setupNavigation()
        mainScrollView.showsVerticalScrollIndicator = false
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        setupFields()
        
        submitButton.isEnabled = false
    }
    
    private func setBookToView() {
        guard let book = bookModel else { return }
        
        isbnField.mainTextField.text = book.id
        titleField.mainTextField.text = book.title
        synopsisField.mainTextView.text = book.synopsis
        authorField.mainTextField.text = book.author
        publisherField.mainTextField.text = book.publisher
        publishedDateField.mainTextField.text = book.publishedDate.formatISODate()
        priceField.mainTextField.text = String(book.price)
        stockField.mainTextField.text = String(book.stock)
        if let imageData = Data(base64Encoded: book.coverImage ?? "") {
            imageField.setImage(image: UIImage(data: imageData))
        }
        
        for key in formValidity.keys {
            formValidity[key] = true
        }
    }
    
    private func setupNavigation() {
        navigationController?.navigationBar.tintColor = .mainAccent
        
        if(bookModel == nil) {
            title = "Add Book"
        } else {
            title = "Detail Book"
            let rightBarButton = UIBarButtonItem(
                image: UIImage(systemName: "trash.fill"),
                style: .plain,
                target: self,
                action: #selector(deleteBookTapped)
            )
            
            rightBarButton.tintColor = .mainAccent
            navigationItem.rightBarButtonItem = rightBarButton
        }
    }
    
    @objc private func deleteBookTapped(){
        let alert = UIAlertController(title: "Are you sure to delete this book?", message: "This action cannot be undone", preferredStyle: .alert)
        let continueButton = UIAlertAction(title: "Delete", style: .destructive) { [weak self] _ in
            self?.viewModel.deleteBook(idBook: self?.bookModel?.id ?? "")
        }
        let cancelButton = UIAlertAction(title: "Cancel", style: .cancel)
        
        alert.addAction(continueButton)
        alert.addAction(cancelButton)
        self.present(alert, animated: true)
    }
    
    private func bindDataViewModel() {
        viewModel?.isSuccessAddBook
            .receive(on: DispatchQueue.main)
            .sink { [weak self] response in
                if response {
                    self?.resetForm()
                    self?.showSnackbar(message: "Successfully Add Book")
                }
            }
            .store(in: &cancellables)
        
        viewModel?.isSuccessDeleteBook
            .receive(on: DispatchQueue.main)
            .sink { [weak self] response in
                if response {
                    self?.resetForm()
                    self?.showSnackbar(message: "Successfully delete Book")
                    self?.navigationController?.popViewController(animated: true)
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
        isbnField.mainTextField.text = ""
        titleField.mainTextField.text = ""
        synopsisField.mainTextView.text = ""
        synopsisField.placeholderLabel.isHidden = false
        authorField.mainTextField.text = ""
        publisherField.mainTextField.text = ""
        publishedDateField.mainTextField.text = ""
        priceField.mainTextField.text = ""
        stockField.mainTextField.text = ""
        imageField.setImage(image: nil)
        
        formValidity = formValidity.mapValues { _ in
            return false
        }
        setStateMainButton()
    }
    private func setupFields() {
        isbnField.setTextFieldProperty(leftSystemImage: "filemenu.and.selection", placeholder: "Input ISBN")
        titleField.setTextFieldProperty(leftSystemImage: "character", placeholder: "Input the title")
        synopsisField.setTextFieldProperty(leftSystemImage: "paragraphsign", placeholder: "Input the synopsis")
        authorField.setTextFieldProperty(leftSystemImage: "person.fill.questionmark", placeholder: "Input the author")
        publisherField.setTextFieldProperty(leftSystemImage: "house.and.flag.fill", placeholder: "Input the publisher")
        publishedDateField.setTextFieldProperty(leftSystemImage: "calendar", placeholder: "Input the published date")
        priceField.setTextFieldProperty(leftSystemImage: "dollarsign", placeholder: "Input the price")
        stockField.setTextFieldProperty(leftSystemImage: "books.vertical", placeholder: "Input the total stock")
        
        imageField.delegate = self
        isbnField.delegate = self
        titleField.delegate = self
        synopsisField.delegate = self
        authorField.delegate = self
        publisherField.delegate = self
        publishedDateField.delegate = self
        priceField.delegate = self
        stockField.delegate = self
        
        setupDatePicker()
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
        submitButton.isEnabled = formValidity.values.allSatisfy { $0 == true }
    }
    
    @objc func keyboardWillHide(notification: Notification) {
        mainScrollView.contentInset = .zero
        mainScrollView.scrollIndicatorInsets = .zero
    }
    
    @objc func dateChange(datePicker: UIDatePicker) {
        let selectedDate = datePicker.date
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .long
        let formattedDate = dateFormatter.string(from: selectedDate)
        publishedDateField.mainTextField.text = formattedDate
        formValidity["publishedDate"] = true
        setStateMainButton()
    }
    
    @IBAction func submitButtonTapped(_ sender: Any) {
        guard let isbn = isbnField.mainTextField.text,
              let title = titleField.mainTextField.text,
              let synopsis = synopsisField.mainTextView.text,
              let author = authorField.mainTextField.text,
              let publisher = publisherField.mainTextField.text,
              let publishedDate = publishedDateField.mainTextField.text?.formatToDateISO8601(),
              let price = Double(priceField.mainTextField.text ?? ""),
              let stock = Int64(stockField.mainTextField.text ?? ""),
              let image = imageField.contentImageView.image?.compressTo(targetSizeKB: 2024)?.base64EncodedString()
        else { return }
        
        let book = BookModel(id: isbn, author: author, coverImage: image, price: price, publishedDate: publishedDate, publisher: publisher, stock: stock, synopsis: synopsis, title: title, updatedDate: Date().ISO8601Format())
        
        viewModel.addBook(book: book)
    }
    
    private func setupDatePicker() {
        let datePicker = UIDatePicker()
        datePicker.datePickerMode = .date
        datePicker.preferredDatePickerStyle = .wheels
        datePicker.tintColor = .mainAccent
        datePicker.addTarget(self, action: #selector(dateChange(datePicker:)), for: .valueChanged)
        datePicker.maximumDate = Date()
        datePicker.frame.size = CGSize(width: 0, height: 300)
        
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        let doneButton = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(finishDatePicker))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        
        toolbar.items = [spaceButton, doneButton]
        publishedDateField.mainTextField.inputAccessoryView = toolbar
        publishedDateField.mainTextField.inputView = datePicker
    }
    
    @objc func finishDatePicker() {
        publishedDateField.mainTextField.resignFirstResponder()
    }
    
    func showImagePickerOptions() {
        self.imageField.becomeFirstResponder()
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
        
        if imageField.contentImageView.image != nil {
            alertController.addAction(UIAlertAction(title: "Delete Image", style: .destructive, handler: { _ in
                self.imageField.setImage(image: nil)
                self.formValidity["image"] = false
                self.setStateMainButton()
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
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let selectedImage = info[.originalImage] as? UIImage {
            imageField.setImage(image: selectedImage)
            formValidity["image"] = true
        } else {
            imageField.setImage(image: nil)
            formValidity["false"] = false
        }
        setStateMainButton()
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}


extension AddBookViewController: GeneralTextFieldViewDelegate, GeneralTextViewDelegate, ImageFieldDelegate {
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        
        let currentText = textView.text ?? ""
        let updatedText = (currentText as NSString).replacingCharacters(in: range, with: text)
        
        if(textView == synopsisField.mainTextView) {
            formValidity["synopsis"] = synopsisField.validateSynopsis(inputText: updatedText)
        }
        imageField.setIsActive(false)
        setStateMainButton()
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let currentText = textField.text ?? ""
        let updatedText = (currentText as NSString).replacingCharacters(in: range, with: string)
        if(textField == isbnField.mainTextField) {
            formValidity["isbn"] = isbnField.validateDigits(inputText: updatedText, minDigits: 13, maxDigits: 13)
        } else if(textField == titleField.mainTextField) {
            formValidity["title"] = titleField.validateTitle(inputText: updatedText)
        } else if(textField == authorField.mainTextField) {
            formValidity["author"] = authorField.validateName(inputText: updatedText)
        } else if(textField == publisherField.mainTextField) {
            formValidity["publisher"] = publisherField.validateName(inputText: updatedText)
        } else if(textField == publishedDateField.mainTextField) {
            setStateMainButton()
            return false
        } else if(textField == priceField.mainTextField) {
            formValidity["price"] = priceField.validatePrice(inputText: updatedText)
        } else if(textField == stockField.mainTextField) {
            formValidity["stock"] = stockField.validatePrice(inputText: updatedText)
        }
        setStateMainButton()
        return true
    }
    
    func contentTapped(imageField: ImageFieldView) {
        if(imageField == self.imageField) {
            activeTextField?.resignFirstResponder()
            showImagePickerOptions()
            imageField.becomeFirstResponder()
            imageField.setIsActive(true)
        }
    }
    
    func textViewRootTapped(_ textView: UITextView) {
        imageField.setIsActive(false)
        
    }
    
    func textFieldRootTapped(_ textField: UITextField) {
        imageField.setIsActive(false)
    }
}
