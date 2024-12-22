//
//  TransactionViewController.swift
//  gramejia
//
//  Created by Adam on 18/12/24.
//

import UIKit

class TransactionViewController: BaseViewController<TransactionViewModel> {
    
    @IBOutlet weak var emptyView: EmptyView!
    @IBOutlet weak var mainContainer: UIView!
    
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
        transactionTableView.separatorStyle = .singleLine
        transactionTableView.separatorColor = .gray
    }
    
    private func bindDataViewModel() {
        viewModel?.transactionlist
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.transactionTableView.reloadData()
                self?.updateState()
            }
            .store(in: &cancellables)
        
        viewModel?.isTransactionDeleted
            .receive(on: DispatchQueue.main)
            .sink { [weak self] response in
                self?.viewModel.isLoading.send(false)
                if response {
                    self?.showSnackbar(message: "Your Transaction is deleted")
                    self?.updateState()
                } else {
                    self?.viewModel.getTransactionList()
                }
            }
            .store(in: &cancellables)
    }
    
    private func updateState() {
        let items = viewModel.transactionlist.value
       
        if(items.isEmpty) {
            emptyView.isHidden = false
            mainContainer.isHidden = true
        } else {
            emptyView.isHidden = true
            transactionTableView.reloadData()
            mainContainer.isHidden = false
        }
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
        let total =  item.items.reduce(0, { $0 + ($1.price * Double($1.quantity))})
        cell.totalCostLabel.text = "-\(total.toRupiah())"
        cell.totalSubproductLabel.text = "\(item.items.count) sub products"
        cell.usernameLabel.text = "@\(item.owner?.username ?? "")"
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .delete
    }
    
    // Enable swipe-to-delete
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let item = viewModel.transactionlist.value[indexPath.row]
            viewModel.transactionlist.value.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)
            viewModel.deleteTransaction(idTransaction: item.id)
            updateState()
        }
    }
    
}
