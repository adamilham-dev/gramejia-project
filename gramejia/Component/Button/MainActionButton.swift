//
//  CapsuleButton.swift
//  gramejia
//
//  Created by Adam on 02/12/24.
//

import UIKit

class MainActionButton: UIButton {
    
    // You can customize the button's colors, font, etc. through these properties.
    var normalBackgroundColor: UIColor = .mainAccent {
        didSet {
            backgroundColor = normalBackgroundColor
        }
    }
    
    var highlightedBackgroundColor: UIColor = .mainAccent.withAlphaComponent(0.7)
    
    var normalTextColor: UIColor = .white {
        didSet {
            setTitleColor(normalTextColor, for: .normal)
        }
    }
    
    var highlightedTextColor: UIColor = .white
    
    // Initialize the button with a capsule shape
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupButton()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupButton()
    }
    
    private func setupButton() {
        setCorner(cornerRadius: 16)
        
        setTitleColor(normalTextColor, for: .normal)
        backgroundColor = normalBackgroundColor
        titleLabel?.font = .nunitoBold(size: 18)
        
        addTarget(self, action: #selector(buttonHighlighted), for: .touchDown)
        addTarget(self, action: #selector(buttonTappedHighlight), for: .touchUpInside)
        addTarget(self, action: #selector(buttonReleased), for: .touchUpOutside)
    }
    
    @objc private func buttonHighlighted() {
        UIView.animate(withDuration: 0.1) {
            self.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
            self.alpha = 0.8
        }
    }
    
    @objc private func buttonTappedHighlight() {
        buttonHighlighted()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.buttonReleased()
        }
    }
    
    @objc private func buttonReleased() {
        UIView.animate(withDuration: 0.1) {
            self.transform = .identity
            self.alpha = 1.0
        }
    }
}
