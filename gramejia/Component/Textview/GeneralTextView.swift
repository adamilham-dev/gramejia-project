//
//  GeneralTextView.swift
//  gramejia
//
//  Created by Adam on 07/12/24.
//

import UIKit


protocol GeneralTextViewDelegate: AnyObject {
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool
}

class GeneralTextView: UIView {
    @IBOutlet weak var mainTextView: UITextView!
    @IBOutlet var rootView: UIView!
    @IBOutlet weak var mainStackView: UIStackView!
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var leftImageView: UIImageView!
    @IBOutlet weak var rightImageView: UIImageView!
    @IBOutlet weak var fieldStackView: UIStackView!
    @IBOutlet weak var leftImageWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var rightImageWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var placeholderLabel: UILabel!
    
    weak var delegate: GeneralTextViewDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupView()
        
    }
    
    open func setupView() {
        guard let view = loadViewFromNib(nibName: String(describing: GeneralTextView.self)) else { return }
        view.frame = bounds
        addSubview(view)
        
        mainTextView.delegate = self
        stylingView()
        setActions()
    }
    
    open func stylingView() {
        mainTextView.borderStyle = .none
        rootView.backgroundColor = .clear
        self.backgroundColor = .clear
        
        fieldStackView.layoutMargins = .init(top: 16, left: 16, bottom: 16, right: 16)
        fieldStackView.isLayoutMarginsRelativeArrangement = true
        fieldStackView.spacing = 8
        
        fieldStackView.addBorder(borderWidth: 2, borderColor: .mainBorderColor)
        fieldStackView.setCorner(cornerRadius: 16)
        mainStackView.spacing = 4
        mainTextView.keyboardType = .asciiCapable
        
        mainTextView.textContainerInset = .zero
        mainTextView.textContainer.lineFragmentPadding = 0
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
    }
    
    @objc private func rootTapped() {
        mainTextView.becomeFirstResponder()
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

extension GeneralTextView: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        UIView.animate(withDuration: 0.1) { [weak self] in
            self?.fieldStackView.layer.borderColor = UIColor.black.cgColor
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        UIView.animate(withDuration: 0.1) { [weak self] in
            self?.fieldStackView.layer.borderColor = UIColor.mainBorderColor.cgColor
        }
    }
    
    func textViewDidChange(_ textView: UITextView) {
        placeholderLabel.isHidden = !textView.text.isEmpty
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        return delegate?.textView(textView, shouldChangeTextIn: range, replacementText: text) ?? true
    }
}
