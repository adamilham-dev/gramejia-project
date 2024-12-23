//
//  ProductCounterView.swift
//  gramejia
//
//  Created by Adam on 14/12/24.
//

import UIKit

class ProductCounterView: UIView {
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var minButton: ImageActionButton!
    @IBOutlet weak var plusButton: ImageActionButton!
    @IBOutlet weak var currentCountLabel: UILabel!
    
    weak var delegate: ProductCounterViewDelegate?
    
    var maximumProduct: Int64 = 10
    var minimumProduct: Int64 = 0
    var currentCount: Int64 = 0
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupView()
        
    }
    @IBAction func plusButtonAction(_ sender: Any) {
        if(currentCount < maximumProduct) {
            currentCount += 1
            updateCount()
        }
        
    }
    @IBAction func minButtonAction(_ sender: Any) {
        if(currentCount > minimumProduct) {
            currentCount -= 1
            updateCount()
        }
    }
    
    func updateCount() {
        if(currentCount == maximumProduct){
            plusButton.isEnabled = false
        } else {
            plusButton.isEnabled = true
        }
        
        if(currentCount == minimumProduct){
            minButton.isEnabled = false
        } else {
            minButton.isEnabled = true
        }
        
        currentCountLabel.text = String(currentCount)
        delegate?.didChangeCount(on: self, updatedCount: currentCount)
    }
    
    private func setupView() {
        guard let view = loadViewFromNib(nibName: String(describing: ProductCounterView.self)) else { return }
        view.frame = bounds
        addSubview(view)
        
        minButton.image = UIImage(systemName: "minus")
        minButton.normalBackgroundColor = .mainAccent
        minButton.imagePadding = .init(top: 8, left: 8, bottom: 8, right: 8)
        minButton.setCorner(cornerRadius: 4)
        
        plusButton.image = UIImage(systemName: "plus")
        plusButton.normalBackgroundColor = .mainAccent
        plusButton.imagePadding = .init(top: 8, left: 8, bottom: 8, right: 8)
        plusButton.setCorner(cornerRadius: 4)
        updateCount()
    }
    
    private func loadViewFromNib(nibName: String) -> UIView? {
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: nibName, bundle: bundle)
        return nib.instantiate(withOwner: self, options: nil).first as? UIView
    }
}

protocol ProductCounterViewDelegate: AnyObject {
    func didChangeCount(on: ProductCounterView, updatedCount: Int64)
}
