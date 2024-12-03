//
//  PopupTransitionDelegate.swift
//  gramejia
//
//  Created by Adam on 03/12/24.
//

import UIKit

class PopupTransitioningDelegate: NSObject, UIViewControllerTransitioningDelegate {
    private let blurEffect = UIBlurEffect(style: .dark)
    private var blurEffectView: UIVisualEffectView?
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return PopupAnimator(blurEffect: blurEffect)
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return PopupDismissalAnimator(blurEffectView: blurEffectView)
    }
}

class PopupAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    private let blurEffect: UIBlurEffect
    
    init(blurEffect: UIBlurEffect) {
        self.blurEffect = blurEffect
    }
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.5
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard let toViewController = transitionContext.viewController(forKey: .to) else { return }
        
        let containerView = transitionContext.containerView
        let blurEffectView = UIVisualEffectView(effect: nil)
        blurEffectView.frame = containerView.bounds
        containerView.addSubview(blurEffectView)
        
        let finalFrame = transitionContext.finalFrame(for: toViewController)
        toViewController.view.frame = finalFrame.offsetBy(dx: 0, dy: containerView.bounds.height)
        containerView.addSubview(toViewController.view)
        
        UIView.animate(withDuration: transitionDuration(using: transitionContext), animations: {
            blurEffectView.effect = self.blurEffect
            toViewController.view.frame = finalFrame
        }, completion: { finished in
            transitionContext.completeTransition(finished)
        })
    }
}

class PopupDismissalAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    private weak var blurEffectView: UIVisualEffectView?
    
    init(blurEffectView: UIVisualEffectView?) {
        self.blurEffectView = blurEffectView
    }
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.5
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard let fromViewController = transitionContext.viewController(forKey: .from) else { return }
        let containerView = transitionContext.containerView

        UIView.animate(withDuration: transitionDuration(using: transitionContext), animations: {
            self.blurEffectView?.effect = nil
            fromViewController.view.frame = fromViewController.view.frame.offsetBy(dx: 0, dy: containerView.bounds.height)
        }, completion: { finished in
            self.blurEffectView?.removeFromSuperview()
            transitionContext.completeTransition(finished)
        })
    }
}
