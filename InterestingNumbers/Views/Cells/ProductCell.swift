//
//  ProductCell.swift
//  Interesting_Numbers
//
//  Created by Yura Sabadin on 20.09.2023.
//
import Combine
import Foundation
import UIKit
import SDWebImage

final class ProductCell: UICollectionViewCell {
    
    static var identCell = "ProductCell"
    
    var productModel: ProductModel? {
        didSet {
            refreshCell()
        }
    }
    
    private let imageView = UIImageView()
    private var stackLabel = UIStackView()
    private let costLabel = UILabel()
    private let nameProductLabel = UILabel()
    
    override init(frame: CGRect) {
        super .init(frame: frame)
        configImageView()
        refreshCell()
        setStackLabels()
        setConstraints()
        setImage()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        setShadowCell()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        imageView.image = nil
    }
    
    private func setStackLabels() {
        stackLabel = UIStackView(arrangedSubviews: [costLabel,nameProductLabel])
        stackLabel.axis = .vertical
        stackLabel.translatesAutoresizingMaskIntoConstraints = false
        costLabel.font = .boldSystemFont(ofSize: 20)
        costLabel.textColor = .link
        costLabel.textAlignment = .right
        costLabel.sizeToFit()
        costLabel.adjustsFontSizeToFitWidth = true
        nameProductLabel.numberOfLines = 2
        nameProductLabel.sizeToFit()
        nameProductLabel.adjustsFontSizeToFitWidth = true
        stackLabel.distribution = .fillEqually
        addSubview(stackLabel)
    }
    
    private func setImage() {
        imageView.image = ImageConstants.addImage
    }
    
    private func setShadowCell() {
        backgroundColor = .lightText
        self.setShadowWithCornerRadius(cornerRadius: 12, shadowColor: .gray, shadowOffset: .zero, shadowOpacity: 0.6, shadowRadius: 6)
    }
    
    private func configImageView() {
        addSubview(imageView)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        imageView.layer.masksToBounds = true
        imageView.layer.cornerRadius = 8
    }
    
    private func refreshCell() {
            guard let product = productModel else {return}
            self.nameProductLabel.text = product.nameProduct
            self.costLabel.text = product.cost + " €"
       
        StorageService.shared.downloadImage(refference: .product, id: product.id) { result in
            switch result {
            case .success(let url):
                self.imageView.sd_setImage(with: url, placeholderImage: nil, options: [.continueInBackground, .progressiveLoad], completed: nil)
            case .failure(let err):
                print(err)
            }
        }
    }
        
    private func setConstraints() {
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: topAnchor),
            imageView.bottomAnchor.constraint(equalTo: stackLabel.topAnchor),
            imageView.trailingAnchor.constraint(equalTo: trailingAnchor),
            imageView.leadingAnchor.constraint(equalTo: leadingAnchor),
            
            stackLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -5),
            stackLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 7),
            stackLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -7),
            stackLabel.heightAnchor.constraint(equalToConstant: 48)
        ])
    }
}
