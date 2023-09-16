//
//  TextField + Extension.swift
//  Interesting_Numbers
//
//  Created by Yura Sabadin on 11.09.2023.
//

import UIKit
import Combine


extension UITextField {

    func setCustomPlaceholder(placeholderLabel: UILabel, frame: CGRect) {
        self.addSubview(placeholderLabel)
        placeholderLabel.frame = frame
        placeholderLabel.textColor = .lightGray
        placeholderLabel.font = .systemFont(ofSize: 15)
        
        self.autocapitalizationType = .none
        self.autocorrectionType = .no
    }
}

class UITextFieldPadding: UITextField {

    let padding = UIEdgeInsets(top: 20, left: 16, bottom: 5, right: 70)
    var rightStack = UIStackView()
    let clearButton = UIButton(type: .system)
    let eyeButton = UIButton(type: .system)
    let emailImage = UIImageView()
    var isSequreText = true
    var placeHolderCustomLabel = UILabel()
    var animating: UIActivityIndicatorView? = nil
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupRightStack()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override open func textRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: padding)
    }

    override open func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: padding)
    }

    override open func editingRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: padding)
    }
    
    func ccnfigureCustomPlaceholder(text: String, frame: CGRect) {
        self.addSubview(placeHolderCustomLabel)
        placeHolderCustomLabel.frame = frame
        placeHolderCustomLabel.text = text
        placeHolderCustomLabel.textColor = .lightGray
        placeHolderCustomLabel.font = .systemFont(ofSize: 15)
        
        self.autocapitalizationType = .none
        self.autocorrectionType = .no
    }
    
    func ccnfigureFrameCustomPlaceHolder(frame: CGRect) {
        placeHolderCustomLabel.frame = frame
    }
    
    func emailIsExists(isExists: Bool) {
        if isExists {
            emailImage.image = ImageConstants.emailOk
            emailImage.tintColor = .systemMint
            placeHolderCustomLabel.textColor = .systemMint
            placeHolderCustomLabel.text = "Your email is correct"
        } else {
            emailImage.image = ImageConstants.emailOk
            emailImage.tintColor = .lightGray
            placeHolderCustomLabel.textColor = .lightGray
            placeHolderCustomLabel.text = TitleConstants.email
        }
    }
    
    func emailAlreadyBusy(isBusy: Bool) {
        if isBusy {
            emailImage.image = ImageConstants.emailBusy
            emailImage.tintColor = .red
            self.layer.borderColor = UIColor.red.cgColor
            placeHolderCustomLabel.text = TitleConstants.emailBusy
            placeHolderCustomLabel.textColor = .red
        } else {
            emailImage.image = ImageConstants.emailOk
            self.layer.borderColor = UIColor.gray.cgColor
            placeHolderCustomLabel.text = TitleConstants.email
            placeHolderCustomLabel.textColor = .lightGray
            if let text = self.text, !text.isEmpty {
                emailImage.tintColor = .systemMint
            }
        }
    }
    
    func setupRightStack() {
        let rightView = UIView(frame: CGRect(x: 0, y: 15, width: 65, height: 25))
        rightStack.frame = .init(x: 0, y: 0, width: 55, height: 25)
        rightStack.tintColor = .gray
        rightStack.spacing = 5
        rightStack.distribution = .fillEqually
        rightView.addSubview(rightStack)
        self.rightView = rightView
        self.rightViewMode = .whileEditing
        
        clearButton.addTarget(self, action: #selector(clearText), for: .touchUpInside)
        clearButton.setImage(ImageConstants.clearText, for: .normal)
        clearButton.widthAnchor.constraint(equalTo: clearButton.heightAnchor).isActive = true
        eyeButton.setImage(ImageConstants.closeEye, for: .normal)
        eyeButton.addTarget(self, action: #selector(changeSequreText), for: .touchUpInside)
        eyeButton.widthAnchor.constraint(equalTo: eyeButton.heightAnchor).isActive = true
    }
    
    func addEmailImageAndClearButton() {
        rightStack.addArrangedSubview(emailImage)
        rightStack.addArrangedSubview(clearButton)
    }
    
    func addSequreAndClearButtons() {
        self.isSecureTextEntry = isSequreText
        rightStack.addArrangedSubview(eyeButton)
        rightStack.addArrangedSubview(clearButton)
    }
    
    func setAnimating() {
        animating = UIActivityIndicatorView()
        guard let animating = animating else {return}
        addSubview(animating)
        animating.hidesWhenStopped = true
        animating.stopAnimating()
        animating.color = .blue
        animating.translatesAutoresizingMaskIntoConstraints = false
        animating.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        animating.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -70).isActive = true
    }
    
    @objc func clearText() {
        self.text = ""
    }
    
    @objc private func changeSequreText() {
        isSequreText.toggle()
        let imageButtonSequre = isSequreText ? ImageConstants.closeEye : ImageConstants.openEye
        eyeButton.setImage(imageButtonSequre, for: .normal)
        self.isSecureTextEntry = isSequreText
    }
}



extension UITextField {
    
    var textPublisher: AnyPublisher<String, Never> {
        NotificationCenter.default
            .publisher(for: UITextField.textDidChangeNotification, object: self)
            .compactMap { $0.object as? UITextField }
            .map { $0.text ?? "" }
            .eraseToAnyPublisher()
    }
}
