//
//  DashboardViewController.swift
//  gramejia
//
//  Created by Adam on 04/12/24.
//

import UIKit


class HomeViewController: BaseViewController<HomeViewModel> {
    @IBOutlet weak var mainTableView: ContentSizedTableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.viewModel = HomeViewModel()
        
        setupView()
        bindDataViewModel()
        viewModel.getBookList()
    }
    
    private func setupView() {
        setupNavigation()
        
        mainTableView.register(BookTableViewCell.nib, forCellReuseIdentifier: BookTableViewCell.identifier)
        mainTableView.delegate = self
        mainTableView.dataSource = self
        mainTableView.rowHeight = UITableView.automaticDimension
    }
    
    private func setupNavigation() {
        let rightBarButton = UIBarButtonItem(
            image: UIImage(systemName: "plus.app"),
            style: .plain,
            target: self,
            action: #selector(addBookNavItemTapped)
        )
        
        rightBarButton.tintColor = .black
        self.title = "Home"
        navigationItem.rightBarButtonItem = rightBarButton
    }
    
    private func bindDataViewModel() {
        viewModel?.bookList
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.mainTableView.reloadData()
            }
            .store(in: &cancellables)
    }
    
    @objc func addBookNavItemTapped() {
        performSegue(withIdentifier: "gotoAddBook", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "gotoAddBook",
           let addBookVC = segue.destination as? AddBookViewController {
            addBookVC.hidesBottomBarWhenPushed = true
        }
    }
    
}

extension HomeViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.bookList.value.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: BookTableViewCell.identifier, for: indexPath) as? BookTableViewCell else { return UITableViewCell() }
        
        let item = viewModel.bookList.value[indexPath.row]
        
        if let imageData = Data(base64Encoded: item.coverImage ?? "") {
            cell.contentImageView.image =  UIImage(data: imageData)
            cell.priceLabel.text = "Rp\(item.price)"
            cell.titleLabel.text = item.title
            cell.stockLabel.text = "\(item.stock) pcs"
        }
        return cell
    }
}
