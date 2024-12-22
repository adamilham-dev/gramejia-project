//
//  PopupViewController.swift
//  gramejia
//
//  Created by Adam on 02/12/24.
//

import UIKit
import Lottie

class PopupViewController: UIViewController {
    
    @IBOutlet weak var mainContainerView: UIView!
    @IBOutlet weak var grabberView: UIView!
    @IBOutlet weak var mainStackView: UIStackView!
    
    @IBOutlet weak var animationContainer: UIView!
    
    @IBOutlet weak var firstButton: MainActionButton?
    @IBOutlet weak var secondButton: MainActionButton?
    
    @IBOutlet weak var titleLabel: UILabel?
    @IBOutlet weak var descriptionLabel: UILabel?
    
    private var originalPosition: CGPoint!
    private var currentPositionTouched: CGPoint!
    
    let animationView = LottieAnimationView(name: "error")
    weak var delegate: PopupViewDelegate?
    
    var popupValue: PopupModel = PopupModel() {
        didSet {
            setPopupValue(title: popupValue.title, description: popupValue.description, firstButtonTitle: popupValue.firstButtonTitle, secondButtonTitle: popupValue.secondButtonTitle)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        
        setPopupValue(title: popupValue.title, description: popupValue.description, firstButtonTitle: popupValue.firstButtonTitle, secondButtonTitle: popupValue.secondButtonTitle)
    }
    
    private func setupView() {
        mainContainerView.setCorner(cornerRadius: 24, corners: [.topLeft, .topRight])
        grabberView.setCorner(cornerRadius: 5)
        
        firstButton?.normalBackgroundColor = .clear
        firstButton?.addBorder(borderWidth: 2, borderColor: .black)
        firstButton?.normalTextColor = .black
        addPanGestureToPopup()
        
        setupAnimationView()
    }
    
    private func setupAnimationView() {
        animationContainer.addSubview(animationView)
        animationView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            animationView.leadingAnchor.constraint(equalTo: animationContainer.leadingAnchor),
            animationView.trailingAnchor.constraint(equalTo: animationContainer.trailingAnchor),
            animationView.topAnchor.constraint(equalTo: animationContainer.topAnchor),
            animationView.bottomAnchor.constraint(equalTo: animationContainer.bottomAnchor)
        ])
        
        animationView.contentMode = .scaleAspectFit
        animationView.animationSpeed = 1.0
        animationView.loopMode = .loop
        
        animationView.play()
    }
    
    private func addPanGestureToPopup() {
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture(_:)))
        mainContainerView.isUserInteractionEnabled = true
        mainContainerView.addGestureRecognizer(panGesture)
    }
    
    @objc private func handlePanGesture(_ gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: self.view)
        
        switch gesture.state {
        case .began:
            originalPosition = mainContainerView.center
        case .changed:
            if translation.y > 0 {
                mainContainerView.center = CGPoint(x: originalPosition.x, y: originalPosition.y + translation.y)
            }
        case .ended:
            let velocity = gesture.velocity(in: self.view)
            if translation.y > 100 || velocity.y > 500 {
                mainContainerView.center = CGPoint(x: originalPosition.x, y: originalPosition.y + translation.y)
                dismissPopup()
            } else {
                UIView.animate(withDuration: 0.3) {
                    self.mainContainerView.center = self.originalPosition
                }
            }
        default:
            break
        }
    }
    
    private func dismissPopup() {
        UIView.animate(withDuration: 0.3, animations: {
            self.mainContainerView.isHidden = true
        }) { _ in
            self.delegate?.onDismissed()
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    func setPopupValue(title: String?, description: String?, firstButtonTitle: String?, secondButtonTitle: String?){
        titleLabel?.text = title
        titleLabel?.isHidden = title == nil
        
        descriptionLabel?.text = description
        descriptionLabel?.isHidden = description == nil
        
        firstButton?.setTitle(firstButtonTitle, for: .normal)
        firstButton?.isHidden = firstButtonTitle == nil
        
        secondButton?.setTitle(secondButtonTitle, for: .normal)
        secondButton?.isHidden = secondButtonTitle == nil
    }
    
    @IBAction func firstButtonTapped(_ sender: Any) {
        self.delegate?.didTappedFirstButton()
    }
    
    @IBAction func secondButtonTapped(_ sender: Any) {
        self.delegate?.didTappedSecondButton()
        self.dismiss(animated: true)
    }
}
