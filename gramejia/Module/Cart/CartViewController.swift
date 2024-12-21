//
//  CartViewController.swift
//  gramejia
//
//  Created by Adam on 15/12/24.
//

import UIKit

class CartViewController: BaseViewController<CartViewModel> {
    
    @IBOutlet weak var mainTableView: UITableView!
    
    @IBOutlet weak var mainCartContainer: UIView!
    @IBOutlet weak var emptyView: EmptyView!
    @IBOutlet weak var balanceLabel: UILabel!
    @IBOutlet weak var totalCostLabel: UILabel!
    @IBOutlet weak var checkoutButton: MainActionButton!
    
    private var selectedCartItem: CartItemModel? = nil
    private var totalCost: Double = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.viewModel = CartViewModel()
        
        setupView()
        bindDataViewModel()
        viewModel.getCarts()
        viewModel.getCustomer()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.getCarts()
        viewModel.getCustomer()
    }
    
    private func setupView() {
        setupNavigation()
        checkoutButton.isEnabled = false
        setupTableView()
    }
    
    private func setupNavigation() {
        navigationController?.navigationBar.tintColor = .mainAccent
        
        let rightBarButton = UIBarButtonItem(
            image: UIImage(systemName: "book.pages"),
            style: .plain,
            target: self,
            action: #selector(transactionButtonTapped)
        )
        
        rightBarButton.tintColor = .black
        self.title = "Cart"
        navigationItem.rightBarButtonItem = rightBarButton
    }
    
    @objc private func transactionButtonTapped() {
        performSegue(withIdentifier: "gotoTransaction", sender: nil)
    }
    
    private func setupTableView() {
        mainTableView.showsVerticalScrollIndicator = false
        mainTableView.isScrollEnabled = true
        mainTableView.allowsSelection = true
        mainTableView.separatorStyle = .none
        mainTableView.estimatedRowHeight = 80
        mainTableView.rowHeight = UITableView.automaticDimension
        
        mainTableView.register(CartTableViewCell.nib, forCellReuseIdentifier: CartTableViewCell.identifier)
        mainTableView.delegate = self
        mainTableView.dataSource = self
    }
    
    private func bindDataViewModel() {
        viewModel?.cartItemList
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.mainTableView.reloadData()
            }
            .store(in: &cancellables)
        
        viewModel?.customerBalance
            .receive(on: DispatchQueue.main)
            .sink { [weak self] balance in
                self?.balanceLabel.text = balance.toRupiah()
                self?.updateCart()
            }
            .store(in: &cancellables)
        
        viewModel?.isTransactionAdded
            .combineLatest(viewModel.isSuccessUpdateBalance, viewModel.isSuccessUpdateStockBook)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isTransactionAdded, isUpdatedBalance, isUpdateStockBook in
                self?.viewModel.isLoading.send(false)
                if(isTransactionAdded && isUpdatedBalance && isUpdateStockBook) {
                    self?.showSnackbar(message: "Your Transaction is success")
                    self?.viewModel.cartItemList.value.removeAll()
                    self?.updateCart()
                }
            }
            .store(in: &cancellables)
        
        viewModel?.isCartItemDeleted
            .receive(on: DispatchQueue.main)
            .sink { [weak self] response in
                self?.viewModel.isLoading.send(false)
                if response {
                    self?.showSnackbar(message: "Book successfully deleted from Cart")
                    self?.mainTableView.reloadData()
                } else {
                    self?.viewModel.getCarts()
                }
            }
            .store(in: &cancellables)
    }
    
    private func updateCart(){
        let items = viewModel.cartItemList.value
        self.totalCost = items.reduce(0, { $0 + Double($1.quantity) * ($1.book?.price ?? 0) })
        self.totalCostLabel.text = totalCost.toRupiah()
        
        let isBalanceSufficient = totalCost <= viewModel.customerBalance.value
        checkoutButton.setTitle(isBalanceSufficient ? "Checkout" : "Insufficient Balance", for: .normal)
        checkoutButton.isEnabled = isBalanceSufficient
        
        
        if(items.isEmpty) {
            emptyView.isHidden = false
            mainCartContainer.isHidden = true
        } else {
            emptyView.isHidden = true
            mainTableView.reloadData()
            mainCartContainer.isHidden = false
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "gotoDetailBook", let detailBookVC = segue.destination as? DetailBookViewController {
            detailBookVC.hidesBottomBarWhenPushed = true
            detailBookVC.bookModel = selectedCartItem?.book
        } else if segue.identifier == "gotoTransaction", let transactionVC = segue.destination as? TransactionViewController {
            transactionVC.hidesBottomBarWhenPushed = true
        }
    }
    @IBAction func checkoutButtonTapped(_ sender: Any) {
        viewModel.checkoutTransaction()
        viewModel.updateBalance(balance: -totalCost)
        viewModel.updateStockBook()
    }
}

extension CartViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.cartItemList.value.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: CartTableViewCell.identifier, for: indexPath) as? CartTableViewCell else { return UITableViewCell() }
        
        let item = viewModel.cartItemList.value[indexPath.row]
        
        if let book = item.book, let imageData = Data(base64Encoded: book.coverImage ?? "") {
            cell.coverImageView.image =  UIImage(data: imageData)
            cell.titleLabel.text = book.title
            cell.priceQuantityLabel.text = "\(book.price.toRupiah()) x \(item.quantity) pcs"
            
            let subTotal = book.price * Double(item.quantity)
            cell.subtotalLabel.text = "\(subTotal.toRupiah())"
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.selectedCartItem = viewModel.cartItemList.value[indexPath.row]
        performSegue(withIdentifier: "gotoDetailBook", sender: nil)
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .delete
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let item = viewModel.cartItemList.value[indexPath.row]
            viewModel.cartItemList.value.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)
            viewModel.deleteCartItem(idBook: item.book?.id ?? "")
            
            updateCart()
        }
    }
}
