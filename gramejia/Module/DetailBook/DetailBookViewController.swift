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
        bindDataViewModel()
        
        if let idBook = bookModel?.id {
            viewModel.getCartBookItem(idBook: idBook)
        }
    }
    
    private func setupView() {
        mainContainerInfo.setCorner(cornerRadius: 36, corners: [.topLeft, .topRight])
        
        backButton.image = UIImage(systemName: "chevron.backward")
        backButton.imageColor = .black
        backButton.normalBackgroundColor = .white
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
    
    private func bindDataViewModel() {
        viewModel?.isBookToCartSuccess
            .receive(on: DispatchQueue.main)
            .sink { [weak self] response in
                if response {
                    self?.showSnackbar(message: "Book successfully added to Cart")
                    self?.navigationController?.popViewController(animated: true)
                } else {
                    self?.viewModel.isLoading.send(false)
                }
            }
            .store(in: &cancellables)
        
        viewModel?.currentCartItem
            .receive(on: DispatchQueue.main)
            .sink { [weak self] cartItem in
                if let cartItem = cartItem {
                    self?.bookModel = cartItem.book
                    self?.productCountView.currentCount = cartItem.quantity
                    self?.productCountView.updateCount()
                    self?.setBookToView()
                    self?.updatePaymentOrder(count: self?.productCountView.currentCount ?? 0, price: self?.bookModel?.price ?? 0)
                    self?.viewModel.isLoading.send(false)
                }
            }
            .store(in: &cancellables)
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
        guard let book = bookModel else { return }
        viewModel.addBookToCart(idBook: book.id, quantity: productCountView.currentCount)
    }
    
    @IBAction func backButtonAction(_ sender: Any) {
        self.viewModel.isLoading.send(false)
        self.navigationController?.popViewController(animated: true)
    }
    
    private func updatePaymentOrder(count: Int64, price: Double) {
        let total = Double(count) * price
        
        totalPaymentLabel.text = total.toRupiah()
        addToCardButton.isEnabled = total > 0
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "gotoDetailInfoBook" {
            if let detailInfoBookVC = segue.destination as? DetailInfoBookViewController {
                detailInfoBookVC.bookModel = bookModel
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
}

extension DetailBookViewController: ProductCounterViewDelegate {
    func didChangeCount(on: ProductCounterView, updatedCount: Int64) {
        updatePaymentOrder(count: updatedCount, price: self.bookModel?.price ?? 0)
    }
}
