//
//  DescriptionNumberViewController.swift
//  InterestingNumbers
//
//  Created by Yura Sabadin on 23.09.2023.
//

import UIKit
import Combine

class DescriptionNumberViewController: UIViewController {
    
    var numberRequest = ""
    var typeRequest: TypeRequest = .oneNumber
    private let closeButton = UIButton(type: .system)
    private let discriptionView = UITextView()
    private let numbersViewModel = RequestNumberViewModel()
    private var cancellable = Set<AnyCancellable>()
    
//MARK: - life cycle:
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setView()
        setDiscriptionView()
        setupNavButton()
        subscribeToNumberModel()
        getNumberFromRequest()
        setConstraints()
    }
    
//MARK: - @objc Functions:
    
    @objc func closeDiscriptionVC() {
        navigationController?.popViewController(animated: true)
    }
    
//MARK: - private func:
    
    private func setView() {
        self.navigationItem.setHidesBackButton(true, animated: false)
        view.backgroundColor = .customColor
    }
    
    private func setDiscriptionView() {
        discriptionView.font = UIFont(name: FontsEnum.regular, size: 16)
        discriptionView.textColor = .white
        discriptionView.backgroundColor = .clear
        discriptionView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(discriptionView)
    }
    
    private func setupNavButton() {
        closeButton.frame = .init(x: 0, y: 0, width: 20, height: 20)
        closeButton.titleLabel?.sizeToFit()
        closeButton.clipsToBounds = true
        closeButton.layer.cornerRadius = 15
        closeButton.setImage(ImageConstants.close, for: .normal)
        closeButton.tintColor = .white
        closeButton.addTarget(self, action: #selector(closeDiscriptionVC), for: .touchUpInside)
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: closeButton)
    }
    
    private func getNumberFromRequest() {
        guard !numberRequest.isEmpty else {return}
        switch typeRequest {
        case .oneNumber, .year, .random:
            numbersViewModel.fetchNumber(typeRequest: typeRequest, numberRequest)
        case .range:
            numbersViewModel.fetchRangeNumber(numberRequest)
        }
    }
    
    private func subscribeToNumberModel() {
        numbersViewModel.$oneNumberDescription
            .sink(receiveValue: { value in
                self.appendOneTextToTextView(numberRequest: self.numberRequest, textBody: value.text ?? "")
            })
            .store(in: &cancellable)
        
        numbersViewModel.$rangeNumbersDescription
            .sink(receiveValue: { dictionary in
                self.appendTextsToTextView(textBody: dictionary)
            })
            .store(in: &cancellable)
    }
    
    private func appendOneTextToTextView(numberRequest: String ,textBody: String) {
        let paragraphString = "\n\(numberRequest)"
        let textBody = "\n\n\(textBody)"
        let paragraph = NSMutableParagraphStyle()
        paragraph.alignment = .center
        let attributedText = NSMutableAttributedString(string: paragraphString, attributes: [.font: UIFont.boldSystemFont(ofSize: 26), .paragraphStyle: paragraph, .foregroundColor: UIColor.yellow])
        attributedText.append(NSAttributedString(string: textBody, attributes: [.font: UIFont.systemFont(ofSize: 19), .foregroundColor: UIColor.white]))
        discriptionView.attributedText = attributedText
    }
    
    private func appendTextsToTextView(textBody: RangeNumbers) {
        let paragraph = NSMutableParagraphStyle()
        paragraph.alignment = .center
        let enter = "\n"
        let attributedText = NSMutableAttributedString()
        let arrayKeys = textBody.keys.sorted()
       
        for numbers in arrayKeys {
            let description = textBody[numbers] ?? ""
            
            attributedText.append(NSAttributedString(string: numbers, attributes: [.font: UIFont.boldSystemFont(ofSize: 26), .paragraphStyle: paragraph, .foregroundColor: UIColor.yellow]))
            attributedText.append(NSAttributedString(string: enter))
            attributedText.append(NSAttributedString(string: description, attributes: [.font: UIFont.systemFont(ofSize: 19), .foregroundColor: UIColor.white]))
            attributedText.append(NSAttributedString(string: enter))
            attributedText.append(NSAttributedString(string: enter))
        }
        discriptionView.attributedText = attributedText
    }
    
//MARK: - Constraints:
    
    private func setConstraints() {
        NSLayoutConstraint.activate([
            discriptionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            discriptionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            discriptionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            discriptionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])
    }
}

