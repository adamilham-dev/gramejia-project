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
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        backgroundColor = UIColor.black.withAlphaComponent(0.8)
        layer.cornerRadius = 8
        clipsToBounds = true
        
        // Configure label
        messageLabel.textColor = .white
        messageLabel.font = UIFont.systemFont(ofSize: 14)
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
    
    func show(in parentView: UIView, duration: TimeInterval = 3.0) {
        parentView.addSubview(self)
        
        // Position the snackbar off-screen at the bottom
        translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            leadingAnchor.constraint(equalTo: parentView.leadingAnchor, constant: 16),
            trailingAnchor.constraint(equalTo: parentView.trailingAnchor, constant: -16),
            bottomAnchor.constraint(equalTo: parentView.bottomAnchor, constant: 80) // Start off-screen
        ])
        
        parentView.layoutIfNeeded()
        
        // Animate the snackbar into view
        UIView.animate(withDuration: 0.3, animations: {
            self.transform = CGAffineTransform(translationX: 0, y: -120) // Move into view
        })
        
        // Dismiss after the specified duration
        dismissTimer = Timer.scheduledTimer(withTimeInterval: duration, repeats: false) { [weak self] _ in
            self?.dismiss()
        }
    }
    
    func dismiss() {
        dismissTimer?.invalidate()
        
        // Animate the snackbar out of view
        UIView.animate(withDuration: 0.3, animations: {
            self.transform = .identity // Move back off-screen
        }) { _ in
            self.removeFromSuperview()
        }
    }
}
