//
//  AythorizedView.swift
//  InterestingNumbers
//
//  Created by Olga Sabadina on 09.09.2023.
//

import UIKit

class AuthorisedView: UIView {
    
    let titleLabel = UILabel()
    let descriptionLabel = UILabel()
    let nameTextField = UITextField()
    let emailTextField = UITextField()
    let passwordTextField = UITextField()
    let cubesView = UIImageView()
    var titlesStack = UIStackView()
    var authorizedStack = UIStackView()
    var signInStack = UIStackView()
    let signInButton = UIButton(type: .system)
    let forgetButton = UIButton(type: .system)
    let loginButton = UIButton(type: .system)
    let namePlaceholderLabel = UILabel()
    var emailPlaceholderLabel = UILabel()
    let passwordPlaceholderLabel = UILabel()
    
    
    override init(frame: CGRect) {
        super .init(frame: frame)
        setCubesView()
        setTitlesLabel()
        setTitlesStack()
        setAythorizedTextFields()
        setSingInStack()
        setAuthorizedStack()
        configureLoginButton()
        registerKeyboard()
        setConstraint()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        removeKeyboardObserver()
        print("remove observer")
    }
    
    func setFogetPasswordButton() {
        addSubview(forgetButton)
        forgetButton.translatesAutoresizingMaskIntoConstraints = false
        forgetButton.setTitle(TitleConstants.forgetButton, for: .normal)
        forgetButton.titleLabel?.font = .boldSystemFont(ofSize: 18)
        NSLayoutConstraint.activate([
            forgetButton.trailingAnchor.constraint(equalTo: authorizedStack.trailingAnchor),
            forgetButton.topAnchor.constraint(equalTo: authorizedStack.bottomAnchor, constant: 10)
        ])
    }
    
    func setLoginButton(_ isAuthorized: Bool) {
        let titleLabelForButton = isAuthorized ? TitleConstants.logInButton : TitleConstants.registerButton
        loginButton.setTitle(titleLabelForButton, for: .normal)
        loginButton.tag = isAuthorized ? 0 : 1
    }
    
    @objc private func keyboardWillShow(_ notification: Notification) {
        let userInfo = notification.userInfo
        let keyboardFrame = (userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue

        let heightScreen = window?.screen.bounds.height ?? 0
        let keyboardHeight = keyboardFrame.height
        let textFieldY = loginButton.frame.minY
        let offsetOnY = heightScreen-keyboardHeight-textFieldY

        guard offsetOnY < 0 else {return}
        self.frame.origin.y = offsetOnY
    }

    @objc private func keyboardWillHide() {
        frame.origin = CGPoint(x: frame.origin.x, y: 0)
    }

    private func configureLoginButton() {
        addSubview(loginButton)
        loginButton.translatesAutoresizingMaskIntoConstraints = false
        loginButton.titleLabel?.font = .boldSystemFont(ofSize: 18)
        loginButton.setBorderLayer(backgroundColor: .link, borderColor: .gray, borderWidth: 1, cornerRadius: 5, tintColor: .systemBackground)
    }
    
    private func setCubesView() {
        cubesView.image = ImageConstants.dice
        cubesView.translatesAutoresizingMaskIntoConstraints = false
        cubesView.contentMode = .scaleAspectFit
        addSubview(cubesView)
    }
    
    private func setTitlesLabel() {
        let labels = [titleLabel, descriptionLabel]
        labels.forEach { label in
            label.textAlignment = .center
            label.numberOfLines = 0
            label.textColor = .label
        }
        titleLabel.text = TitleConstants.titleLabel
        titleLabel.font = .boldSystemFont(ofSize: 24)
        descriptionLabel.text = TitleConstants.descriptionLabel
        descriptionLabel.font = .systemFont(ofSize: 16)
    }
    
    private func setAythorizedTextFields() {
        let textFields = [nameTextField, emailTextField, passwordTextField]
        let placeholderArray = [TitleConstants.name, TitleConstants.email, TitleConstants.password]
        let labelPlaceholderArray = [namePlaceholderLabel, emailPlaceholderLabel, passwordPlaceholderLabel]
        
        textFields.enumerated().forEach { index, tf in
            labelPlaceholderArray[index].text = placeholderArray[index]
            tf.setCustomPlaceholder(placeholderLabel: labelPlaceholderArray[index], frame: .init(x: 10, y: 5, width: 200, height: 40))
            tf.font = .systemFont(ofSize: 21)
            tf.delegate = self
            tf.heightAnchor.constraint(equalToConstant: 50).isActive = true
            tf.setBorderLayer(backgroundColor: .secondarySystemBackground, borderColor: .lightGray, borderWidth: 1, cornerRadius: 4, tintColor: nil)
        }
    }
    
    private func setTitlesStack() {
        titlesStack = UIStackView(arrangedSubviews: [titleLabel, descriptionLabel])
        titlesStack.axis = .vertical
        titlesStack.spacing = 10
        titlesStack.translatesAutoresizingMaskIntoConstraints = false
        addSubview(titlesStack)
    }
    
    private func setAuthorizedStack() {
        authorizedStack = UIStackView(arrangedSubviews: [nameTextField, emailTextField,passwordTextField])
        authorizedStack.axis = .vertical
        authorizedStack.spacing = 10
        authorizedStack.distribution = .fillEqually
        authorizedStack.translatesAutoresizingMaskIntoConstraints = false
        addSubview(authorizedStack)
    }
    
    private func setSingInStack() {
        let signInLabel = UILabel()
        signInLabel.text = TitleConstants.signInLabel
        signInLabel.font = .systemFont(ofSize: 18)
        signInLabel.textColor = .label
        signInLabel.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        
        signInButton.setTitle(TitleConstants.singInButton, for: .normal)
        signInButton.tintColor = .link
        signInButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        
        signInStack = UIStackView(arrangedSubviews: [signInLabel, signInButton])
        signInStack.axis = .horizontal
        signInStack.spacing = 8
        signInStack.translatesAutoresizingMaskIntoConstraints = false
        addSubview(signInStack)
    }
    
    private func registerKeyboard() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    private func removeKeyboardObserver() {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    private func setConstraint() {
        NSLayoutConstraint.activate([
            titlesStack.topAnchor.constraint(equalTo: self.topAnchor),
            titlesStack.heightAnchor.constraint(equalToConstant: 100),
            titlesStack.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -20),
            titlesStack.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 20),
            
            cubesView.topAnchor.constraint(equalTo: titlesStack.bottomAnchor, constant: 40),
            cubesView.heightAnchor.constraint(equalToConstant: 150),
            cubesView.centerXAnchor.constraint(equalTo: centerXAnchor),
            cubesView.widthAnchor.constraint(equalTo: cubesView.heightAnchor),
        
            authorizedStack.topAnchor.constraint(equalTo: cubesView.bottomAnchor, constant: 20),
            authorizedStack.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -20),
            authorizedStack.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 20),
            
            loginButton.trailingAnchor.constraint(equalTo: authorizedStack.trailingAnchor),
            loginButton.leadingAnchor.constraint(equalTo: authorizedStack.leadingAnchor),
            loginButton.heightAnchor.constraint(equalToConstant: 50),
            loginButton.topAnchor.constraint(equalTo: authorizedStack.bottomAnchor, constant: 55),
            
            signInStack.leadingAnchor.constraint(greaterThanOrEqualTo: leadingAnchor, constant: 40),
            signInStack.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor, constant: -40),
            signInStack.bottomAnchor.constraint(equalTo: bottomAnchor),
            signInStack.centerXAnchor.constraint(equalTo: centerXAnchor),
        ])
    }
}

extension AuthorisedView: UITextFieldDelegate {
    
    private func minimizePlaceholder(_ label: UILabel) {
        UIView.animate(withDuration: 0.3) {
            label.frame = .init(x: 20, y: 3, width: 200, height: 17)
        }
    }
    
    private func expandLabel(_ label: UILabel) {
        UIView.animate(withDuration: 0.5) {
            label.frame = .init(x: 20, y: 5, width: 200, height: 40)
        }
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField == nameTextField {
            minimizePlaceholder(namePlaceholderLabel)
        } else if textField == emailTextField {
            minimizePlaceholder(emailPlaceholderLabel)
        } else {
            minimizePlaceholder(passwordPlaceholderLabel)
        }
        textField.contentVerticalAlignment = .bottom
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        guard let text = textField.text, text.isEmpty else {return}
        if textField == nameTextField {
            expandLabel(namePlaceholderLabel)
        } else if textField == emailTextField {
            expandLabel(emailPlaceholderLabel)
        } else {
            expandLabel(passwordPlaceholderLabel)
        }
        textField.contentVerticalAlignment = .center
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        endEditing(true)
        return true
    }
}
