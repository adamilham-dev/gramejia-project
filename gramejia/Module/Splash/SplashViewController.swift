//
//  SplashViewController.swift
//  gramejia
//
//  Created by Adam on 22/12/24.
//

import UIKit

class SplashViewController: UIViewController {

    @IBOutlet weak var appIconImageView: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        animateSplash()
    }
    
    private func animateSplash() {
        appIconImageView.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
        appIconImageView.alpha = 0.0
        UIView.animate(withDuration: 2.5, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.8, options: .curveEaseInOut, animations: {
                    self.appIconImageView.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
                    self.appIconImageView.alpha = 1.0
                }, completion: { _ in
                    self.determineScreen()
                })
    }
    
    private func determineScreen() {
        let isSignedIn: Bool? = UserDefaultsManager.shared.get(forKey: .isSignedIn)
        if isSignedIn == true {
            performSegue(withIdentifier: "gotoMain", sender: nil)
        } else {
            performSegue(withIdentifier: "gotoLogin", sender: nil)
        }
    }
}
