//
//  CartTableViewCell.swift
//  gramejia
//
//  Created by Adam on 15/12/24.
//

import UIKit

class CartTableViewCell: UITableViewCell {

    @IBOutlet weak var coverImageView: UIImageView!
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var priceQuantityLabel: UILabel!
    @IBOutlet weak var subtotalLabel: UILabel!
     
    @IBOutlet weak var mainContainerView: UIView!
    static let identifier = String(describing: CartTableViewCell.self)
    static let nib = UINib(nibName: identifier, bundle: nil)
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        setupView()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    private func setupView() {
        mainContainerView.setCorner(cornerRadius: 16)
    }
    
}
