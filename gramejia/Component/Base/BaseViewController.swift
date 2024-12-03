//
//  BaseViewController.swift
//  gramejia
//
//  Created by Adam on 02/12/24.
//

import UIKit


class BaseViewController: UIViewController {
    private var snackbarView: SnackbarView?
    private var loadingView: LoadingView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white // Set default background color
    }
    
    // Show snackbar with message
    func showSnackbar(message: String, duration: TimeInterval = 3.0) {
        // Ensure only one snackbar is visible at a time
        snackbarView?.dismiss()
        snackbarView = SnackbarView(message: message)
        
        guard let snackbarView = snackbarView else { return }
        snackbarView.show(in: view, duration: duration)
    }
    
    // Hide snackbar manually
    func hideSnackbar() {
        snackbarView?.dismiss()
    }
    
    func startLoading() {
        UIView.animate(withDuration: 0.2, animations: { [weak self] in
            guard let self = self, self.loadingView == nil else { return }
            let overlayView = LoadingView(frame: self.view.bounds)
            self.view.addSubview(overlayView)
            self.loadingView = overlayView
        })
    }
    
    func stopLoading() {
        loadingView?.removeFromSuperview()
        loadingView = nil
    }
    
    private var errorPopup: UIView?
    private var dimBackground: UIView?
    
    // Function to show the error popup with image and message
    func showErrorPopup(image: UIImage?, message: String) {
        guard errorPopup == nil else { return } // Prevent multiple popups
        
        // Create a dimmed background view to cover the entire screen
        let dimView = UIView()
        dimView.frame = view.bounds
        dimView.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        dimView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(dimView)
        dimBackground = dimView
        
        // Create the popup view
        let popupView = UIView()
        popupView.frame = CGRect(x: 0, y: view.bounds.height, width: view.bounds.width, height: 250)
        popupView.backgroundColor = .white
        popupView.layer.cornerRadius = 12
        popupView.layer.masksToBounds = true
        popupView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        // Add a grabber to the top of the popup
        let grabberView = UIView()
        grabberView.frame = CGRect(x: (view.bounds.width - 60) / 2, y: 12, width: 60, height: 6)
        grabberView.backgroundColor = .lightGray
        grabberView.layer.cornerRadius = 3
        popupView.addSubview(grabberView)
        
        // Add an image for the error icon
        let errorImageView = UIImageView(image: image ?? UIImage(systemName: "exclamationmark.triangle.fill"))
        errorImageView.frame = CGRect(x: 20, y: 40, width: 40, height: 40)
        errorImageView.tintColor = .red
        popupView.addSubview(errorImageView)
        
        // Add the error message label
        let messageLabel = UILabel()
        messageLabel.frame = CGRect(x: 80, y: 40, width: view.bounds.width - 100, height: 120)
        messageLabel.text = message
        messageLabel.textColor = .darkGray
        messageLabel.numberOfLines = 0
        messageLabel.font = UIFont.systemFont(ofSize: 16)
        popupView.addSubview(messageLabel)
        
        // Add the popup view to the screen
        view.addSubview(popupView)
        
        // Add the pan gesture recognizer to allow the popup to follow gestures
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture(_:)))
        popupView.addGestureRecognizer(panGesture)
        
        // Slide in the popup from the bottom
        UIView.animate(withDuration: 0.3) {
            popupView.frame.origin.y = self.view.bounds.height - 250
        }
        
        // Set the popup view reference for later use
        errorPopup = popupView
    }
    
    // Handle pan gesture to make the popup follow the user's swipe
    @objc private func handlePanGesture(_ gesture: UIPanGestureRecognizer) {
        guard let popupView = errorPopup else { return }
        
        let translation = gesture.translation(in: view)
        let newY = popupView.frame.origin.y + translation.y
        
        // Move the popup with the gesture
        if newY >= view.bounds.height - 250 && newY <= view.bounds.height - 50 {
            popupView.frame.origin.y = newY
            gesture.setTranslation(.zero, in: view)
        }
        
        // Dismiss the popup when swiped down sufficiently
        if gesture.state == .ended {
            if newY >= view.bounds.height - 150 {
                //                    dismissErrorPopup()
            } else {
                // Snap back to the original position if not swiped enough
                UIView.animate(withDuration: 0.3) {
                    popupView.frame.origin.y = self.view.bounds.height - 250
                }
            }
        }
    }
    
    // Function to dismiss the error popup
    func dismissErrorPopup() {
        UIView.animate(withDuration: 0.3, animations: {
            self.errorPopup?.frame.origin.y = self.view.bounds.height
            self.dimBackground?.alpha = 0
        }) { _ in
            self.errorPopup?.removeFromSuperview()
            self.dimBackground?.removeFromSuperview()
            self.errorPopup = nil
            self.dimBackground = nil
        }
    }
    
}
