//
//  DetailBookViewController.swift
//  gramejia
//
//  Created by Adam on 11/12/24.
//

import UIKit

class DetailBookViewController: BaseViewController<DetailBookViewModel> {

    @IBOutlet weak var mainContainerInfo: UIView!
    @IBOutlet weak var addToCardButton: MainActionButton!
    @IBOutlet weak var backButton: ImageActionButton!
    @IBOutlet weak var moreChevronIcon: UIImageView!
    @IBOutlet weak var coverImageView: UIImageView!
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var authorLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var stockLabel: UILabel!
    
    @IBOutlet weak var productCountView: ProductCounterView!
    
    @IBOutlet weak var totalPaymentLabel: UILabel!
    
    
    var bookModel: BookModel? = mockBook
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.viewModel = DetailBookViewModel()
        
        setupView()
        setupAction()
    }
    
    private func setupView() {
        mainContainerInfo.setCorner(cornerRadius: 36, corners: [.topLeft, .topRight])
        
        backButton.image = UIImage(systemName: "chevron.backward")
        backButton.normalBackgroundColor = .black
        backButton.imagePadding = .init(top: 8, left: 8, bottom: 8, right: 8)
        
        productCountView.delegate = self
        productCountView.maximumProduct = bookModel?.stock ?? 0
        productCountView.updateCount()
        
        addToCardButton.isEnabled = false
        addToCardButton.setTitle((bookModel?.stock ?? 0) > 0 ? "Add to Cart" : "Out of Stock", for: .normal)
        
        setBookToView()
        updatePaymentOrder(count: 0, price: bookModel?.price ?? 0)
    }
    
    private func setBookToView() {
        if let book = self.bookModel {
            if let imageData = Data(base64Encoded: book.coverImage ?? "") {
                coverImageView.image = UIImage(data: imageData)
            }
            
            titleLabel.text = book.title
            authorLabel.text = "Author: \(book.author)"
            priceLabel.text = book.price.toRupiah()
            stockLabel.text = "\(book.stock) pcs"
        } else {
            
        }
    }
    
    private func setupAction() {
        moreChevronIcon.isUserInteractionEnabled = true
        let moreChevronIconGesture = UITapGestureRecognizer(target: self, action: #selector(moreInfoTapped))
        moreChevronIcon.addGestureRecognizer(moreChevronIconGesture)
    }
    
    @objc private func moreInfoTapped() {
        performSegue(withIdentifier: "gotoDetailInfoBook", sender: nil)
    }
    
    
    @IBAction func addToCardAction(_ sender: Any) {
    }
    
    @IBAction func backButtonAction(_ sender: Any) {
        
    }
    
    private func updatePaymentOrder(count: Int64, price: Double) {
        let total = Double(count) * price
        
        totalPaymentLabel.text = total.toRupiah()
        addToCardButton.isEnabled = total > 0
    }
    
}

extension DetailBookViewController: ProductCounterViewDelegate {
    func didChangeCount(on: ProductCounterView, updatedCount: Int64) {
        updatePaymentOrder(count: updatedCount, price: self.bookModel?.price ?? 0)
    }
}
