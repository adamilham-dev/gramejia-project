//
//  ProfileViewController.swift
//  gramejia
//
//  Created by Adam on 04/12/24.
//

import UIKit

class ProfileViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        setupView()
    }
    
    @objc func saveButtonTapped() {
        
    }
    
    private func setupView() {
        setupNavigation()
    }
    
    
    private func setupNavigation() {
        let rightBarButton = UIBarButtonItem(
            title: "Save",
            style: .plain,
            target: self,
            action: #selector(saveButtonTapped)
        )
        
        self.title = "Profile"
        navigationItem.rightBarButtonItem = rightBarButton
    }
    
}
