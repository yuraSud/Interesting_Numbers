//
//  AythorizedView.swift
//  InterestingNumbers
//
//  Created by Olga Sabadina on 09.09.2023.
//

import UIKit

class AuthorisedView: UIView {
    
    let titleLabel = UILabel()
    let signInLabel = UILabel()
    let descriptionLabel = UILabel()
    let nameTextField = UITextFieldPadding()
    let emailTextField = UITextFieldPadding()
    let passwordTextField = UITextFieldPadding()
    let cubesView = UIImageView()
    var titlesStack = UIStackView()
    var authorizedStack = UIStackView()
    var signInStack = UIStackView()
    var animating = UIActivityIndicatorView()
    let signInButton = UIButton(type: .system)
    let forgetButton = UIButton(type: .system)
    let loginButton = UIButton(type: .system)
    let buttonEye = UIButton()
    var isHaveAccount: Bool = false {
        didSet {
            setLoginButton()
        }
    }
    
    //MARK: - Life cycle:
    
    override init(frame: CGRect) {
        super .init(frame: frame)
        setCubesView()
        setTitlesLabel()
        setTitlesStack()
        setAuthorisedTextFields()
        setSingInStack()
        setAuthorizedStack()
        configureLoginButton()
        registerKeyboard()
        setConstraint()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        removeKeyboardObserver()
        animating.stopAnimating()
        print("deinit removeKeyboardObserver")
    }
    
    //MARK: - Func:
    
    //MARK: - @objc private func:
    
    @objc private func keyboardWillShow(_ notification: Notification) {
        let userInfo = notification.userInfo
        let keyboardFrame = (userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        
        let heightScreen = window?.screen.bounds.height ?? 0
        let keyboardHeight = keyboardFrame.height
        let textFieldY = loginButton.frame.minY
        let offsetOnY = heightScreen-keyboardHeight-textFieldY
        
        guard offsetOnY < 0 else {return}
        frame.origin = CGPoint(x: frame.origin.x, y: offsetOnY)
    }
    
    @objc private func keyboardWillHide() {
        frame.origin = CGPoint(x: frame.origin.x, y: 0)
    }
    
    //MARK: - private func:
    
    private func configureLoginButton() {
        addSubview(loginButton)
        loginButton.translatesAutoresizingMaskIntoConstraints = false
        loginButton.titleLabel?.font = .boldSystemFont(ofSize: 18)
        loginButton.setBorderLayer(backgroundColor: .link, borderColor: .gray, borderWidth: 1, cornerRadius: 5, tintColor: .systemBackground)
        loginButton.addSubview(animating)
        animating.hidesWhenStopped = true
        animating.stopAnimating()
        animating.color = .white
        animating.translatesAutoresizingMaskIntoConstraints = false
    }
    
    private func setLoginButton() {
        let titleLabelForButton = isHaveAccount ? TitleConstants.logInButton : TitleConstants.registerButton
        loginButton.setTitle(titleLabelForButton, for: .normal)
        loginButton.tag = isHaveAccount ? 0 : 1
        
        signInLabel.text = isHaveAccount ? TitleConstants.signUpLabel : TitleConstants.signInLabel
        let buttonLabel = isHaveAccount ? TitleConstants.signUpButton : TitleConstants.singInButton
        signInButton.setTitle(buttonLabel, for: .normal)
        
        if isHaveAccount {
            nameTextField.isHidden = true
            setFogetPasswordButton()
        } else {
            nameTextField.isHidden = false
            forgetButton.isHidden = true
        }
    }
    
    private func setFogetPasswordButton() {
        addSubview(forgetButton)
        forgetButton.translatesAutoresizingMaskIntoConstraints = false
        forgetButton.setTitle(TitleConstants.forgetButton, for: .normal)
        forgetButton.titleLabel?.font = .boldSystemFont(ofSize: 18)
        NSLayoutConstraint.activate([
            forgetButton.trailingAnchor.constraint(equalTo: authorizedStack.trailingAnchor),
            forgetButton.topAnchor.constraint(equalTo: authorizedStack.bottomAnchor, constant: 10)
        ])
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
    
    private func setAuthorisedTextFields() {
        let textFields = [nameTextField, emailTextField, passwordTextField]
        let placeholderArray = [TitleConstants.name, TitleConstants.email, TitleConstants.password]

        textFields.enumerated().forEach { index, tf in
            tf.delegate = self
            tf.font = .systemFont(ofSize: 19)
            tf.heightAnchor.constraint(equalToConstant: 50).isActive = true
            tf.ccnfigureCustomPlaceholder(text: placeholderArray[index],
                                          frame: .init(x: 14, y: 5, width: 200, height: 40))
            tf.setBorderLayer(backgroundColor: .secondarySystemBackground,
                              borderColor: .lightGray,
                              borderWidth: 1,
                              cornerRadius: 9,
                              tintColor: nil)
        }
        nameTextField.addEmailImageAndClearButton()
        passwordTextField.addSequreAndClearButtons()
        emailTextField.addEmailImageAndClearButton()
        emailTextField.setAnimating()
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
        signInLabel.font = .systemFont(ofSize: 18)
        signInLabel.textColor = .label
        signInLabel.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        
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
    
    //MARK: - Constraints:
    
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
            authorizedStack.bottomAnchor.constraint(lessThanOrEqualTo: signInStack.topAnchor, constant: 10),
            
            signInStack.leadingAnchor.constraint(greaterThanOrEqualTo: leadingAnchor, constant: 40),
            signInStack.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor, constant: -40),
            signInStack.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor),
            signInStack.centerXAnchor.constraint(equalTo: centerXAnchor),
            
            loginButton.trailingAnchor.constraint(equalTo: authorizedStack.trailingAnchor),
            loginButton.leadingAnchor.constraint(equalTo: authorizedStack.leadingAnchor),
            loginButton.heightAnchor.constraint(equalToConstant: 50),
            loginButton.topAnchor.constraint(equalTo: authorizedStack.bottomAnchor, constant: 55),
            
            animating.trailingAnchor.constraint(equalTo: loginButton.trailingAnchor, constant: -20),
            animating.centerYAnchor.constraint(equalTo: loginButton.centerYAnchor),
        ])
    }
}

//MARK: - TextField Delegate:

extension AuthorisedView: UITextFieldDelegate {

    private func minimizePlaceholder(_ tf: UITextField) {
        UIView.animate(withDuration: 0.3) {
            guard let tf = tf as? UITextFieldPadding else {return}
            tf.ccnfigureFrameCustomPlaceHolder(frame: .init(x: 14, y: 3, width: 200, height: 17))
        }
    }

    private func expandLabel(_ tf: UITextField) {
        UIView.animate(withDuration: 0.5) {
            guard let tf = tf as? UITextFieldPadding else {return}
            tf.ccnfigureFrameCustomPlaceHolder(frame: .init(x: 14, y: 5, width: 200, height: 40))
        }
    }

    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField == nameTextField {
            minimizePlaceholder(textField)
        } else if textField == emailTextField {
            minimizePlaceholder(textField)
        } else {
            minimizePlaceholder(textField)
        }
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        guard let text = textField.text, text.isEmpty else {return}
        if textField == nameTextField {
            expandLabel(textField)
        } else if textField == emailTextField {
            expandLabel(textField)
        } else {
            expandLabel(textField)
        }
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        endEditing(true)
        return true
    }
}


