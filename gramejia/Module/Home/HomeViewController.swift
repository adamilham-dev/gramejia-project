//
//  DashboardViewController.swift
//  gramejia
//
//  Created by Adam on 04/12/24.
//

import UIKit


class HomeViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }
    
    private func setupView() {
        setupNavigation()
    }
    
    private func setupNavigation() {
        let rightBarButton = UIBarButtonItem(
            image: UIImage(systemName: "plus.app"),
            style: .plain,
            target: self,
            action: #selector(addBookNavItemTapped)
        )
        
        rightBarButton.tintColor = .black
        self.title = "Home"
        navigationItem.rightBarButtonItem = rightBarButton
    }
    
    
    @objc func addBookNavItemTapped() {
        print("LOGDEBUG: tapped")
    }
    
}
