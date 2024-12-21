//
//  SnackBarView.swift
//  gramejia
//
//  Created by Adam on 02/12/24.
//

import UIKit

class SnackbarView: UIView {
    private let messageLabel = UILabel()
    private var dismissTimer: Timer?
    
    init(message: String) {
        super.init(frame: .zero)
        setupView()
        configureMessage(message)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    override func layoutSubviews() {
        setCorner(cornerRadius: bounds.size.height / 4)
    }
    private func setupView() {
        backgroundColor = UIColor.black.withAlphaComponent(0.8)
        messageLabel.textColor = .white
        messageLabel.font = .nunitoBold(size: 18)
        messageLabel.textAlignment = .center
        messageLabel.numberOfLines = 0
        
        addSubview(messageLabel)
        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            messageLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            messageLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            messageLabel.topAnchor.constraint(equalTo: topAnchor, constant: 10),
            messageLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10)
        ])
    }
    
    private func configureMessage(_ message: String) {
        messageLabel.text = message
    }
    
    func show(in parentView: UIView, duration: TimeInterval = 3.0, dismissCompletion: (() -> Void)? = nil) {
        parentView.addSubview(self)
       
        translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            leadingAnchor.constraint(equalTo: parentView.leadingAnchor, constant: 24),
            trailingAnchor.constraint(equalTo: parentView.trailingAnchor, constant: -24),
            bottomAnchor.constraint(equalTo: parentView.bottomAnchor, constant: 80) // Start off-screen
        ])
        
        parentView.layoutIfNeeded()
        UIView.animate(withDuration: 0.3, animations: {
            self.transform = CGAffineTransform(translationX: 0, y: -120) // Move into view
        })

        dismissTimer = Timer.scheduledTimer(withTimeInterval: duration, repeats: false) { [weak self] _ in
            self?.dismiss()
            dismissCompletion?()
        }
    }
    
    func dismiss() {
        dismissTimer?.invalidate()

        UIView.animate(withDuration: 0.3, animations: {
            self.transform = .identity
        }) { _ in
            self.removeFromSuperview()
        }
    }
}
