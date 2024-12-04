//
//  BaseViewController.swift
//  gramejia
//
//  Created by Adam on 02/12/24.
//

import UIKit
import Combine


class BaseViewController<ViewModel: BaseViewModel>: UIViewController {
    private var snackbarView: SnackbarView?
    private var loadingView: LoadingView?
    var cancellables = Set<AnyCancellable>()
    open var viewModel: ViewModel! {
        didSet {
            bindDataViewModel()
        }
    }
    let blurTransitioningDelegate = PopupTransitioningDelegate()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    private func bindDataViewModel() {
        viewModel.isLoading
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isLoading in
                if isLoading {
                    self?.startLoading()
                } else {
                    self?.stopLoading()
                }
            }
            .store(in: &cancellables)
        
        viewModel.error
            .receive(on: DispatchQueue.main)
            .sink { [weak self] error in
                if let _ = error {
                    self?.showPopupGeneral()
                    return
                }
            }
            .store(in: &cancellables)
    }
    
    func showPopupGeneral() {
        let popupView = PopupViewController()
        popupView.transitioningDelegate = blurTransitioningDelegate
        popupView.delegate = self
        popupView.popupValue = PopupModel(title: "Error Occured", description: "There is an error while requesting your request", secondButtonTitle: "Dismiss")
        present(popupView, animated: true)
    }
    
    func showSnackbar(message: String, duration: TimeInterval = 3.0) {
        snackbarView?.dismiss()
        snackbarView = SnackbarView(message: message)
        guard let snackbarView = snackbarView else { return }
        snackbarView.show(in: view, duration: duration)
    }
    
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
}


extension BaseViewController: PopupViewDelegate {
    func onDismissed() {
        
    }
    
    func didTappedFirstButton() {
        
    }
    
    func didTappedSecondButton() {
        
    }
}
