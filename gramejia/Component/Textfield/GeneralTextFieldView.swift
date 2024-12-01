//
//  GeneralTextFieldView.swift
//  gramejia
//
//  Created by Adam on 01/12/24.
//

import UIKit

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
        mainTextField.becomeFirstResponder()
    }
}


extension GeneralTextFieldView: UITextFieldDelegate {
// UITextFieldDelegate method: When editing begins
    func textFieldDidBeginEditing(_ textField: UITextField) {
        UIView.animate(withDuration: 0.1) { [weak self] in
            self?.fieldStackView.layer.borderColor = UIColor.black.cgColor
        }
        
    }
    
    // UITextFieldDelegate method: When editing ends
    func textFieldDidEndEditing(_ textField: UITextField) {
        UIView.animate(withDuration: 0.1) { [weak self] in
            self?.fieldStackView.layer.borderColor = UIColor.mainBorderColor.cgColor
        }
    }
}