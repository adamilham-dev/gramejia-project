//
//  CartViewController.swift
//  gramejia
//
//  Created by Adam on 15/12/24.
//

import UIKit

class CartViewController: BaseViewController<CartViewModel> {
    
    @IBOutlet weak var mainTableView: UITableView!
    
    @IBOutlet weak var mainCartContainer: UIStackView!
    @IBOutlet weak var emptyView: EmptyView!
    @IBOutlet weak var balanceLabel: UILabel!
    @IBOutlet weak var totalCostLabel: UILabel!
    @IBOutlet weak var checkoutButton: MainActionButton!
    
    @IBOutlet weak var checkoutCartContainer: UIView!
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
        
        checkoutCartContainer.isHidden = viewModel.userLevel == "admin"
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
        
        viewModel?.cartUserList
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
        if(viewModel.userLevel == "customer") {
            let items = viewModel.cartItemList.value
            self.totalCost = items.reduce(0, { $0 + Double($1.quantity) * ($1.book?.price ?? 0) })
            self.totalCostLabel.text = totalCost.toRupiah()
            
            let isBalanceSufficient = totalCost <= viewModel.customerBalance.value
            checkoutButton.setTitle(isBalanceSufficient ? "Checkout" : "Insufficient Balance", for: .normal)
            checkoutButton.isEnabled = isBalanceSufficient
            updateViewCart(isEmpty: items.isEmpty)
        } else {
            updateViewCart(isEmpty: viewModel.cartUserList.value.isEmpty)
        }
    }
    
    private func updateViewCart(isEmpty: Bool) {
        if(isEmpty) {
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
        if(viewModel.userLevel == "customer") {
            return viewModel.cartItemList.value.count
        } else {
            return viewModel.cartUserList.value[section].items.count
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if(viewModel.userLevel == "customer") {
            return 1
        } else {
            return viewModel.cartUserList.value.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: CartTableViewCell.identifier, for: indexPath) as? CartTableViewCell else { return UITableViewCell() }
        var item: CartItemModel? = nil
        
        if(viewModel.userLevel == "customer") {
            item = viewModel.cartItemList.value[indexPath.row]
        } else {
            let section = viewModel.cartUserList.value[indexPath.section]
            item = section.items[indexPath.row]
        }
        
        if let item = item, let book = item.book, let imageData = Data(base64Encoded: book.coverImage ?? "") {
            cell.coverImageView.image =  UIImage(data: imageData)
            cell.titleLabel.text = book.title
            cell.priceQuantityLabel.text = "\(book.price.toRupiah()) x \(item.quantity) pcs"
            cell.selectionStyle = .none
            
            let subTotal = book.price * Double(item.quantity)
            cell.subtotalLabel.text = "\(subTotal.toRupiah())"
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if(viewModel.userLevel == "customer") {
            return nil
        } else {
            return viewModel.cartUserList.value[section].owner?.name ?? ""
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if(viewModel.userLevel == "customer") {
            self.selectedCartItem = viewModel.cartItemList.value[indexPath.row]
            performSegue(withIdentifier: "gotoDetailBook", sender: nil)
        }
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .delete
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if(viewModel.userLevel == "customer") {
            return 0
        } else {
            return 50
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if(viewModel.userLevel == "customer") {
            return nil
        } else {
            let owner = viewModel.cartUserList.value[section].owner
            let headerView = UIView()
            
            let label = UILabel()
            label.text = "\(owner?.name.capitalized ?? "")'s Cart"
            label.font = UIFont.nunitoBold(size: 17)
            label.textColor = .white
            label.translatesAutoresizingMaskIntoConstraints = false
            label.textAlignment = .left
            headerView.backgroundColor = .mainAccent
            
            headerView.addSubview(label)
            NSLayoutConstraint.activate([
                label.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 24),
                label.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -24),
                label.topAnchor.constraint(equalTo: headerView.topAnchor, constant: 8),
                label.bottomAnchor.constraint(equalTo: headerView.bottomAnchor, constant: -8)
            ])
            return headerView
        }
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            if(viewModel.userLevel == "customer") {
                let item = viewModel.cartItemList.value[indexPath.row]
                viewModel.cartItemList.value.remove(at: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: .automatic)
                viewModel.deleteCartItem(idBook: item.book?.id ?? "")
                
            } else {
                let section = viewModel.cartUserList.value[indexPath.section]
                let item = section.items[indexPath.row]
                viewModel.cartUserList.value[indexPath.section].items.remove(at: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: .automatic)
                
                if(viewModel.cartUserList.value[indexPath.section].items.isEmpty){
                    viewModel.cartUserList.value.remove(at: indexPath.section)
                    tableView.deleteSections(IndexSet(integer: indexPath.section), with: .automatic)
                }
                viewModel.deleteCartItem(idBook: item.book?.id ?? "", username: section.owner?.username ?? "")
            }
            updateCart()
        }
    }
}
