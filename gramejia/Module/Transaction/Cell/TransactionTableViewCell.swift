//
//  TransactionTableViewCell.swift
//  gramejia
//
//  Created by Adam on 19/12/24.
//

import UIKit

class TransactionTableViewCell: UITableViewCell {

    @IBOutlet weak var dateLabel: UILabel!
    
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var mainContainer: UIView!
    @IBOutlet weak var totalSubproductLabel: UILabel!
    
    @IBOutlet weak var totalCostLabel: UILabel!
    
    static let identifier = String(describing: TransactionTableViewCell.self)
    static let nib = UINib(nibName: identifier, bundle: nil)
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupView()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    
    private func setupView() {
    }
}
