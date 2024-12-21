//
//  EmptyView.swift
//  gramejia
//
//  Created by Rivaldo Fernandes on 21/12/24.
//

import UIKit
import Lottie

class EmptyView: UIView {
    
    @IBOutlet weak var emptyAnimationView: UIView!
    
    @IBOutlet weak var emptyLabel: UILabel!
    let animationView = LottieAnimationView(name: "empty")
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupView()
        
    }
    
    private func loadViewFromNib(nibName: String) -> UIView? {
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: nibName, bundle: bundle)
        return nib.instantiate(withOwner: self, options: nil).first as? UIView
    }
    
    private func setupView() {
        guard let view = loadViewFromNib(nibName: String(describing: EmptyView.self)) else { return }
        view.frame = bounds
        self.backgroundColor = .clear
        view.backgroundColor = .clear
        addSubview(view)
        emptyAnimationView.addSubview(animationView)
        
        setupAnimationView()
    }
    
    private func setupAnimationView() {

        animationView.frame = emptyAnimationView.bounds
        animationView.contentMode = .scaleAspectFit
        animationView.animationSpeed = 1.0
        animationView.loopMode = .loop
        animationView.center = center
        animationView.play()
    }
    
    override func layoutSubviews() {
        animationView.frame = emptyAnimationView.bounds
    }
}
