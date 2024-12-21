//
//  TransactionViewController.swift
//  gramejia
//
//  Created by Adam on 18/12/24.
//

import UIKit

class TransactionViewController: BaseViewController<TransactionViewModel> {

    @IBOutlet weak var transactionTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.viewModel = TransactionViewModel()
        
        setupView()
        bindDataViewModel()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.getTransactionList()
    }
    
    private func setupView() {
        setupNavigation()
        setupTableView()
    }
    
    private func setupNavigation() {
        navigationController?.navigationBar.tintColor = .mainAccent
        self.title = "Transaction"
    }
    
    @objc private func transactionButtonTapped() {
        performSegue(withIdentifier: "gotoTransaction", sender: nil)
    }
    
    private func setupTableView() {
        transactionTableView.showsVerticalScrollIndicator = false
        transactionTableView.isScrollEnabled = true
        transactionTableView.allowsSelection = true
        transactionTableView.separatorStyle = .none
        transactionTableView.estimatedRowHeight = 80
        transactionTableView.rowHeight = UITableView.automaticDimension
        
        transactionTableView.register(TransactionTableViewCell.nib, forCellReuseIdentifier: TransactionTableViewCell.identifier)
        transactionTableView.delegate = self
        transactionTableView.dataSource = self
    }
    
    private func bindDataViewModel() {
        viewModel?.transactionlist
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.transactionTableView.reloadData()
            }
            .store(in: &cancellables)
    }
}

extension TransactionViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.transactionlist.value.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: TransactionTableViewCell.identifier, for: indexPath) as? TransactionTableViewCell else { return UITableViewCell() }
        
        let item = viewModel.transactionlist.value[indexPath.row]
        
        cell.dateLabel.text = item.transactionDate.formatISODate()
        cell.totalCostLabel.text = item.items.reduce(0, { $0 + ($1.price * Double($1.quantity))}).toRupiah()
        cell.totalSubproductLabel.text = "\(item.items.count) sub products"
//        if let book = item.book, let imageData = Data(base64Encoded: book.coverImage ?? "") {
//            cell.coverImageView.image =  UIImage(data: imageData)
//            cell.titleLabel.text = book.title
//            cell.priceQuantityLabel.text = "\(book.price.toRupiah()) x \(item.quantity) pcs"
//            
//            let subTotal = book.price * Double(item.quantity)
//            cell.subtotalLabel.text = "\(subTotal.toRupiah())"
//        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        self.selectedCartItem = viewModel.cartItemList.value[indexPath.row]
//        performSegue(withIdentifier: "gotoDetailBook", sender: nil)
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .delete
    }
    
    // Enable swipe-to-delete
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            viewModel.transactionlist.value.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
    }
    
}
