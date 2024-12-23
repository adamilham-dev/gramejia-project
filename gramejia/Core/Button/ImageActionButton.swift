//
//  ImageButton.swift
//  gramejia
//
//  Created by Adam on 02/12/24.
//

import UIKit

class ImageActionButton: UIButton {
    
    var config = UIButton.Configuration.filled()
    
    var image: UIImage? = nil {
        didSet {
            config.image = image
            configuration = config
            setNeedsLayout()
        }
    }
    
    var imageSize: CGSize = CGSize(width: 50, height: 50) {
        didSet {
            setNeedsLayout()
        }
    }
    
    var imagePadding: UIEdgeInsets = .zero {
            didSet {
                setNeedsLayout()
            }
        }
    
    var normalBackgroundColor: UIColor = .mainAccent {
        didSet {
            config.baseBackgroundColor = normalBackgroundColor
            configuration = config
            setNeedsLayout()
        }
    }
    
    var imageColor: UIColor = .black {
        didSet {
            config.baseForegroundColor = imageColor
            configuration = config
            setNeedsLayout()
        }
    }
    
    var highlightedBackgroundColor: UIColor = .mainAccent.withAlphaComponent(0.7)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupButton()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupButton()
    }
    
    private func setupButton() {
        self.imageView?.contentMode = .scaleAspectFit
        setTitle("", for: .normal)
        setCorner(cornerRadius: 16)
        addTarget(self, action: #selector(buttonHighlighted), for: .touchDown)
        addTarget(self, action: #selector(buttonTappedHighlight), for: .touchUpInside)
        addTarget(self, action: #selector(buttonReleased), for: .touchUpOutside)
        

        self.configuration = config
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
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if let imageView = self.imageView {
            imageView.frame = self.bounds.inset(by: imagePadding)
        }
    }
}
