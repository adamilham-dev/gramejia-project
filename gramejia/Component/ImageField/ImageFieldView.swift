//
//  ImageField.swift
//  gramejia
//
//  Created by Adam on 07/12/24.
//

import UIKit
import Lottie

@objc protocol ImageFieldDelegate: AnyObject {
    @objc optional func contentTapped(imageField: ImageFieldView)
}

class ImageFieldView: UIView {
    
    @IBOutlet var rootView: UIView!
    @IBOutlet weak var subContentContainer: UIView!
    @IBOutlet weak var mainContentContainer: UIView!
    @IBOutlet weak var contentImageView: UIImageView!
    @IBOutlet weak var animationContainer: UIView!
    @IBOutlet weak var errorLabel: UILabel!
    
    weak var delegate: ImageFieldDelegate?
    let animationView = LottieAnimationView(name: "add-image")
    
    override var canBecomeFirstResponder: Bool {
        return true
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupView()
    }
    
    open func setupView() {
        guard let view = loadViewFromNib(nibName: String(describing: ImageFieldView.self)) else { return }
        view.frame = bounds
        addSubview(view)
        
        stylingView()
        setupAnimation()
        setupAction()
    }
    
    open func stylingView() {
        rootView.backgroundColor = .clear
        self.backgroundColor = .clear
        
        mainContentContainer.layoutMargins = .init(top: 16, left: 16, bottom: 16, right: 16)
        
        mainContentContainer.addBorder(borderWidth: 2, borderColor: .mainBorderColor)
        mainContentContainer.setCorner(cornerRadius: 16)
    }
    
    private func setupAnimation() {
        animationContainer.addSubview(animationView)
        animationView.frame = animationContainer.bounds
        
        animationView.contentMode = .scaleAspectFit
        animationView.animationSpeed = 1.0
        animationView.play()
    }
    
    private func setupAction() {
        self.subContentContainer.isUserInteractionEnabled = true
        let subContentGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(_:)))
        subContentGesture.minimumPressDuration = 0
        self.subContentContainer.addGestureRecognizer(subContentGesture)
    }
    
    @objc func handleLongPress(_ gesture: UILongPressGestureRecognizer) {
        switch gesture.state {
        case .began:
            self.contentHighlighted()
        case .ended:
            self.contentTapped()
        default:
            break
        }
    }
    
    
    @objc private func contentHighlighted() {
        UIView.animate(withDuration: 0.1) {
            self.subContentContainer.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
            self.subContentContainer.alpha = 0.8
        }
    }
    
    @objc private func contentTapped() {
        contentHighlighted()
        
        delegate?.contentTapped?(imageField: self)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.contentReleased()
        }
        
    }
    
    @objc private func contentReleased() {
        UIView.animate(withDuration: 0.1) {
            self.subContentContainer.transform = .identity
            self.subContentContainer.alpha = 1.0
        }
    }
    
    private func loadViewFromNib(nibName: String) -> UIView? {
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: nibName, bundle: bundle)
        return nib.instantiate(withOwner: self, options: nil).first as? UIView
    }
    
    func setImage(image: UIImage?){
        if(image == nil) {
            contentImageView.image = image
            animationContainer.isHidden = false
            contentImageView.isHidden = true
            animationView.stop()
            animationView.play(fromProgress: 0, toProgress: 1) 
        } else {
            contentImageView.image = image
            animationContainer.isHidden = true
            contentImageView.isHidden = false
        }
    }
    
    func setIsActive(_ isActive: Bool) {
        UIView.animate(withDuration: 0.1) { [weak self] in
            self?.mainContentContainer.layer.borderColor = isActive ? UIColor.black.cgColor : UIColor.mainBorderColor.cgColor
        }
    }
}
