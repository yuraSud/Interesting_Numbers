//
//  StoreViewController.swift
//  Interesting_Numbers
//
//  Created by Yura Sabadin on 19.09.2023.
//
import Combine
import UIKit

class StoreViewController: UIViewController {

    let storeViewModel = StoreCollectionViewModel()
    var collectionView : UICollectionView?
    var subscribers = Set<AnyCancellable>()
    
//MARK: - Life Cycle:
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavButton()
        sinkToProperties()
        setCollectionView()
        setConstraints()
        setUpView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        collectionView?.scrollRectToVisible(.zero, animated: true)
        storeViewModel.getProducts()
    }
    
//MARK: - @objc Function:
    
    @objc func addItem() {
        let addItemVC = AddProductsViewController()
        
        addItemVC.reloadSubject.sink { isReload in
            if isReload {
                self.storeViewModel.getProducts()
            }
        }
        .store(in: &subscribers)
        
        
        if let sheet = addItemVC.sheetPresentationController {
            sheet.detents = [.medium()]
            sheet.prefersScrollingExpandsWhenScrolledToEdge = false
            sheet.prefersGrabberVisible = true
            sheet.preferredCornerRadius = 25
        }
        navigationController?.present(addItemVC, animated: true)
    }
    
//MARK: - Private Function:
    private func setupNavButton() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addItem))
    }
    
    private func setUpView() {
        title = "Store Firebase"
        view.backgroundColor = .secondarySystemBackground
        navigationController?.navigationBar.tintColor = .label
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
    }
    
    private func sinkToProperties() {
        NotificationCenter.default.publisher(for: Notification.errorPost)
            .compactMap({$0.userInfo?["error"] as? String})
            .filter{!$0.isEmpty}
            .sink { error in
                self.presentAlert(with: error, message: nil, buttonTitles: "OK", styleActionArray: [.default], alertStyle: .alert, completion: nil)
             }
            .store(in: &subscribers)
        
        storeViewModel.$products
            .debounce(for: 0.3, scheduler: DispatchQueue.main)
            .sink { array in
            print(array.count, "Number products in store")
            self.reloadCollection()
        }
        .store(in: &subscribers)
    }
    
    private func reloadCollection() {
        DispatchQueue.main.async {
            self.collectionView?.reloadData()
        }
    }
    
    private func setConstraints() {
        guard let collView = collectionView else {return}
        NSLayoutConstraint.activate([
            collView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            collView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            collView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }
}

//MARK: - UICollectionView:

extension StoreViewController {
    
    func setCollectionView() {
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: createLayout())
        collectionView?.delegate = self
        collectionView?.dataSource = self
        collectionView?.translatesAutoresizingMaskIntoConstraints = false
        collectionView?.backgroundColor = .clear
        
        //Register Cells and Headers
        collectionView?.register(ProductCell.self, forCellWithReuseIdentifier: ProductCell.identCell)
        collectionView?.register(HeaderCollection.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: HeaderCollection.headerIdentifier)
        
        view.addSubview(collectionView ?? UICollectionView())
    }
    
    private func createLayout() -> UICollectionViewLayout {
        
        let layout = UICollectionViewCompositionalLayout { (sectionIndex, leyoutEnvironment)-> NSCollectionLayoutSection? in
            
            guard let sectionKind = Section(rawValue: sectionIndex) else {return nil}
            let columns = sectionKind.columnCount(for: leyoutEnvironment.container.contentSize.width)
            
            switch sectionKind {
            case .product:
                return self.createProductSection(columns: columns)
            }
        }
        return layout
    }
    
    private func createProductSection(columns: Int = 1) -> NSCollectionLayoutSection {
        
        let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(40))
        let sectionHeader = NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: headerSize, elementKind: UICollectionView.elementKindSectionHeader, alignment: .top)
        sectionHeader.contentInsets = .init(top: 0, leading: 0, bottom: 0, trailing: 0)
        
        let item = CompositionalLayout.createItem(width: .fractionalWidth(1.0), height: .fractionalHeight(1.0), spacing: 10)
        
        let group = CompositionalLayout.createGroupeCount(aligment: .horizontal, width: .fractionalWidth(1.0/CGFloat(columns)), height: .absolute(170), item: item, count: columns)
        
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = .init(top: 10, leading: 16, bottom: 10, trailing: 16)
        section.interGroupSpacing = 15
        section.boundarySupplementaryItems = [sectionHeader]
        return section
    }
}

//  MARK: - CollectionViewDelegate,DataSours:

extension StoreViewController: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        storeViewModel.numberOfSections()
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        storeViewModel.numberOfItemsInSection(section)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let sectionKind = Section(rawValue: indexPath.section) else {return UICollectionViewCell()}
        switch sectionKind {
        case .product:
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ProductCell.identCell, for: indexPath) as? ProductCell else {return UICollectionViewCell()}
            cell.productModel = storeViewModel.products[indexPath.row]
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        guard let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: HeaderCollection.headerIdentifier, for: indexPath) as? HeaderCollection else {return UICollectionReusableView()}
        
        if kind == UICollectionView.elementKindSectionHeader {
            if indexPath.section == 0 {
                header.setImageAndTitleForHeader(ImageConstants.book, TitleConstants.productsHeader, fontSize: 20, false)
            }
        }
        return header
    }
}

//MARK: - UICollectionViewDelegate
extension StoreViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let sectionKind = Section(rawValue: indexPath.section) else {return}
        
        switch sectionKind {
            
        case .product:
            let cell = collectionView.cellForItem(at: indexPath) as? ProductCell
            print(cell?.productModel?.nameProduct ?? "nil", "This is product not buy yet")
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemsAt indexPaths: [IndexPath], point: CGPoint) -> UIContextMenuConfiguration? {
        guard indexPaths.count == 1,
              let cell = collectionView.cellForItem(at: indexPaths[0]) as? ProductCell,
              let product = cell.productModel
        else { return nil }
        
        return UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { _ in
            
            let cancel = UIAction(title: "Cancel", image: UIImage(systemName: "gear.badge.xmark")) { _ in
            }
            
            let delete = UIAction(title: "Delete", image: UIImage(systemName: "xmark.app.fill"), attributes: .destructive) { [weak self] _ in
                DatabaseService.shared.deleteProduct(product: product) { result in
                    switch result {
                    case .success(let succsess):
                        guard succsess else {return}
                        self?.storeViewModel.getProducts()
                    case .failure(let error):
                        self?.presentAlert(with: "Error", message: error.localizedDescription, buttonTitles: "OK", styleActionArray: [.default], alertStyle: .alert, completion: nil)
                    }
                }
            }
            return UIMenu(title: "Видалити з обраного ? :", options: .singleSelection, children: [delete, cancel])
        }
    }
}
