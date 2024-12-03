//
//  LoadingView.swift
//  gramejia
//
//  Created by Adam on 02/12/24.
//

import UIKit
import Lottie


class LoadingView: UIView {
    private let loadingAnimationView = LottieAnimationView(name: "loading")
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    private func setupView() {
        backgroundColor = UIColor.black.withAlphaComponent(0.5)
        autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        loadingAnimationView.frame = CGRect(x: 0, y: 0, width: 300, height: 300)
        loadingAnimationView.contentMode = .scaleAspectFit
        loadingAnimationView.animationSpeed = 1.0
        loadingAnimationView.loopMode = .loop
        loadingAnimationView.center = center
        
        addSubview(loadingAnimationView)
        
        loadingAnimationView.play()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
