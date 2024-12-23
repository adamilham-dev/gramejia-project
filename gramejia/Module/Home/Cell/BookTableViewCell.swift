//
//  BooktTableViewCell.swift
//  gramejia
//
//  Created by Adam on 08/12/24.
//

import UIKit

class BookTableViewCell: UITableViewCell {

    static let identifier = String(describing: BookTableViewCell.self)
    static let nib = UINib(nibName: identifier, bundle: nil)
    
    
    @IBOutlet weak var contentImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var stockLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupView()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    private func setupView() {
        contentImageView.setCorner(cornerRadius: 16)
    }
    
}
