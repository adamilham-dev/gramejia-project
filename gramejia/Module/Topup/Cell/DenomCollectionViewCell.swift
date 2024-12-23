//
//  DenomCollectionViewCell.swift
//  gramejia
//
//  Created by Adam on 21/12/24.
//

import UIKit

class DenomCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var denomLabel: UILabel!
    @IBOutlet weak var mainContainer: UIView!
    
    static let identifier = String(describing: DenomCollectionViewCell.self)
    static let nib = UINib(nibName: identifier, bundle: nil)
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupView()
    }
    
    private func setupView(){
        mainContainer.setCorner(cornerRadius: 16)
        mainContainer.addBorder(borderWidth: 2, borderColor: .mainBorder)
    }
    
    func configure(denom: String, isSelected: Bool?) {
        denomLabel.text = denom
        if isSelected == true {
            mainContainer.layer.borderColor = UIColor.black.cgColor
        } else {
            mainContainer.layer.borderColor = UIColor.mainBorderColor.cgColor
        }
    }
}
