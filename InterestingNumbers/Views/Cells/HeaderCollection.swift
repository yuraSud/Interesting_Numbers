//
//  HeaderCollection.swift
//  Interesting_Numbers
//
//  Created by Yura Sabadin on 20.09.2023.
//

import Foundation
import UIKit
import SDWebImage

class HeaderCollection: UICollectionViewCell {
    
    static let headerIdentifier = "HeaderCollection"
    var headerData: HeaderSectionModel? {
        didSet {
            setImageAndTitleForHeader()
        }
    }
    
    private var stackView = UIStackView()
    private let headerLabel = UILabel()
    private let headerImageView = UIImageView()
    
    override init(frame: CGRect) {
        super .init(frame: frame)
        setStackView()
        setConstraint()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        headerLabel.text = ""
        headerImageView.image = nil
    }
    
    func setImageAndTitleForHeader() {
        headerLabel.text = headerData?.title
        headerLabel.font = .boldSystemFont(ofSize: 20)
        guard let headerData else {return}
        StorageService.shared.downloadImage(refference: .header, id: headerData.imageId) { result in
            switch result {
            case .success(let url):
                self.headerImageView.sd_setImage(with: url, placeholderImage: nil, options: [.continueInBackground, .progressiveLoad], completed: nil)
            case .failure(let err):
                print(err)
            }
        }
    }
    
    private func setStackView() {
        let leftStackView = UIStackView(arrangedSubviews: [headerImageView, headerLabel])
        headerImageView.contentMode = .scaleAspectFit
        headerImageView.tintColor = .label
        headerImageView.image?.withTintColor(.yellow)
        headerImageView.widthAnchor.constraint(equalTo: headerImageView.heightAnchor).isActive = true
        
        leftStackView.axis = .horizontal
        leftStackView.distribution = .fill
        leftStackView.spacing = 10
        
        stackView = UIStackView(arrangedSubviews: [leftStackView])
        stackView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(stackView)
    }
    
    private func setConstraint() {
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
            stackView.topAnchor.constraint(equalTo: topAnchor, constant: 10),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10)
        ])
    }
}
