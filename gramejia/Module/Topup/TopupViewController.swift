//
//  TopupViewController.swift
//  gramejia
//
//  Created by Adam on 21/12/24.
//

import UIKit

class TopupViewController: BaseViewController<TopupViewModel> {
    @IBOutlet weak var denomCollectionView: UICollectionView!
    @IBOutlet weak var specifiedAmountField: GeneralTextFieldView!
    @IBOutlet weak var topupButton: MainActionButton!
    
    private var selectedDenomIndex: Int? = nil
    private var currentDenom: Double? = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.viewModel = TopupViewModel()
        setupView()
        bindDataViewModel()
    }
    
    private func bindDataViewModel() {
        viewModel?.isSuccessUpdateBalance
            .receive(on: DispatchQueue.main)
            .sink { [weak self] response in
                if response {
                    self?.resetForm()
                    self?.showSnackbar(message: "Successfully Update Balance")
                }
            }
            .store(in: &cancellables)
    }
    
    private func resetForm() {
        self.currentDenom = nil
        self.selectedDenomIndex = nil
        self.denomCollectionView.reloadData()
        self.specifiedAmountField.mainTextField.text = ""
        self.specifiedAmountField.mainTextField.resignFirstResponder()
    }
    
    private func setupView() {
        setupNavigation()
        setupFields()
        setupCollectionView()
        
        topupButton.isEnabled = false
    }
    
    private func setupNavigation() {
        navigationController?.navigationBar.tintColor = .mainAccent
        self.title = "Top Up"
    }
    
    private func setupFields() {
        specifiedAmountField.setTextFieldProperty(leftSystemImage: "banknote.fill", placeholder: "Input your specified amount")
        specifiedAmountField.delegate = self
    }
    
    private func setupCollectionView() {
        denomCollectionView.showsVerticalScrollIndicator = false
        denomCollectionView.allowsSelection = true
        denomCollectionView.delegate = self
        denomCollectionView.dataSource = self
        
        denomCollectionView.register(DenomCollectionViewCell.nib, forCellWithReuseIdentifier: DenomCollectionViewCell.identifier)
        
        let horizontalSpacing: CGFloat = 24
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = horizontalSpacing
        layout.minimumLineSpacing = 24
        layout.sectionInset = UIEdgeInsets(top: 4, left: horizontalSpacing, bottom: 0, right: horizontalSpacing)
        
        let totalSpacing = (2 * horizontalSpacing) + horizontalSpacing // (Insets + inter-item spacing)
        let width = (UIScreen.main.bounds.width - totalSpacing) / 2
        let height: CGFloat = 50
        layout.itemSize = CGSize(width: width, height: height)
        
        denomCollectionView.collectionViewLayout = layout
        
    }
    
    @IBAction func topupButtonTapped(_ sender: Any) {
        guard let balance = self.currentDenom else { return }
        viewModel.updateBalance(balance: balance)
    }
    
    private func setStateMainButton(){
        topupButton.isEnabled = (currentDenom ?? 0) > 0
    }
}

extension TopupViewController: GeneralTextFieldViewDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        let currentText = textField.text ?? ""
        let updatedText = (currentText as NSString).replacingCharacters(in: range, with: string)
        if(textField == specifiedAmountField.mainTextField) {
            if(updatedText.isEmpty){
                currentDenom = nil
                setStateMainButton()
            } else {
                guard let denom = Double(updatedText) else { return false}
                currentDenom = denom
                setStateMainButton()
            }
        }
        return true
    }
}

extension TopupViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.denomList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: DenomCollectionViewCell.identifier, for: indexPath) as? DenomCollectionViewCell else { return UICollectionViewCell() }
        
        let item = viewModel.denomList[indexPath.item]
        if let index = selectedDenomIndex {
            cell.configure(denom: item.toRupiah(), isSelected: index == indexPath.item)
        } else {
            cell.configure(denom: item.toRupiah(), isSelected: nil)
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let selectedIndex = self.selectedDenomIndex, let previouslySelectedCell = collectionView.cellForItem(at: IndexPath(row: selectedIndex, section: 0)) as? DenomCollectionViewCell {
            
            let item = self.viewModel.denomList[selectedIndex]
            previouslySelectedCell.configure(denom: item.toRupiah(), isSelected: false)
        }
        
        let currentItem = viewModel.denomList[indexPath.item]
        let selectedCell = collectionView.cellForItem(at: indexPath) as? DenomCollectionViewCell
        selectedCell?.configure(denom: currentItem.toRupiah(), isSelected: true)
        
        selectedDenomIndex = indexPath.item
        collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
        self.currentDenom = currentItem
        specifiedAmountField.mainTextField.resignFirstResponder()
        specifiedAmountField.mainTextField.text = ""
        setStateMainButton()
    }
    
    func textFieldRootTapped(_ textField: UITextField) {
        self.selectedDenomIndex = nil
        self.denomCollectionView.reloadData()
        self.currentDenom = nil
        setStateMainButton()
    }
}
