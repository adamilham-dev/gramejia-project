//
//  DashboardViewController.swift
//  gramejia
//
//  Created by Adam on 04/12/24.
//

import UIKit


class HomeViewController: BaseViewController<HomeViewModel> {
    
    @IBOutlet weak var mainCollectionView: UICollectionView!
    
    private var selectedBook: BookModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.viewModel = HomeViewModel()
        
        setupView()
        bindDataViewModel()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.getBookList()
    }
    
    private func setupView() {
        setupNavigation()
        setupCollectionView()
    }
    
    private func setupCollectionView() {
        mainCollectionView.showsVerticalScrollIndicator = false
        mainCollectionView.allowsSelection = true
        mainCollectionView.delegate = self
        mainCollectionView.dataSource = self
        
        
        mainCollectionView.register(BookCollectionViewCell.nib, forCellWithReuseIdentifier: BookCollectionViewCell.identifier)
        
        let horizontalSpacing: CGFloat = 24
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = horizontalSpacing
        layout.minimumLineSpacing = 24
        layout.sectionInset = UIEdgeInsets(top: 24, left: horizontalSpacing, bottom: 24, right: horizontalSpacing)
        
        let totalSpacing = (2 * horizontalSpacing) + horizontalSpacing // (Insets + inter-item spacing)
        let width = ( UIScreen.main.bounds.width - totalSpacing) / 2
        let height = width * 1.5
        layout.itemSize = CGSize(width: width, height: height)
        
        mainCollectionView.collectionViewLayout = layout
    }
    
    private func setupNavigation() {
        navigationController?.navigationBar.tintColor = .mainAccent
        self.title = "Home"
        //MARK NN: change level
        if(viewModel.userLevel == "admin") {
            let rightBarButton = UIBarButtonItem(
                image: UIImage(systemName: "plus.app"),
                style: .plain,
                target: self,
                action: #selector(addBookNavItemTapped)
            )
            
            rightBarButton.tintColor = .black
            navigationItem.rightBarButtonItem = rightBarButton
        }
    }
    
    private func bindDataViewModel() {
        viewModel?.bookList
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.mainCollectionView.reloadData()
            }
            .store(in: &cancellables)
    }
    
    @objc func addBookNavItemTapped() {
        performSegue(withIdentifier: "gotoAddBook", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "gotoAddBook", let addBookVC = segue.destination as? AddBookViewController {
            addBookVC.hidesBottomBarWhenPushed = true
            if let _ = sender as? String {
                addBookVC.bookModel = selectedBook
            }
            
        } else if segue.identifier == "gotoDetailBook", let detailBookVC = segue.destination as? DetailBookViewController {
            detailBookVC.hidesBottomBarWhenPushed = true
            detailBookVC.bookModel = selectedBook
        }
    }
}

extension HomeViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.bookList.value.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: BookCollectionViewCell.identifier, for: indexPath) as? BookCollectionViewCell else { return UICollectionViewCell() }
        
        let item = viewModel.bookList.value[indexPath.item]
        
        if let imageData = Data(base64Encoded: item.coverImage ?? "") {
            cell.coverImageView.image =  UIImage(data: imageData)
            cell.titleLabel.text = item.title
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.selectedBook = viewModel.bookList.value[indexPath.item]
        //MARK NN: change level
        if(viewModel.userLevel == "admin") {
            performSegue(withIdentifier: "gotoAddBook", sender: "edit")
        } else {
            performSegue(withIdentifier: "gotoDetailBook", sender: nil)
        }
    }
}
