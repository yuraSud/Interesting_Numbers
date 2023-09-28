//
//  RequestNumberView.swift
//  Interesting_Numbers
//
//  Created by Yura Sabadin on 24.09.2023.
//
import UIKit

class ChoiseNumbersView: UIView {
    
    let showButton = UIButton(type: .system)
    let inputTextField = UITextField()
    var typeRequest: TypeRequest = .oneNumber
    private let titleLabel = UILabel()
    private let descriptionLabel = UILabel()
    private let enterLabel = UILabel()
    private var bezierDiceOne = BezierDiceFive()
    private var bezierDiceFive = BezierDiceFive()
    private let validateManager = ValidateManager()
    private var buttonTag = 0
    private var buttonsStack = UIStackView()
    private var titlesStack = UIStackView()
    private var inputStack = UIStackView()
    private var buttonsArray: [UIButton] = []
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setBezierPathView()
        setInputTextField()
        setShowButton()
        setNambersButtons()
        setEnterLabel()
        setTitlesLabel()
        setButtonsStack()
        setTitlesStack()
        setInputStack()
        setConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        removeKeyboardObserver()
    }
    
//MARK: - @objc private func:
    
    @objc private func keyboardWillShow(_ notification: Notification) {
        let userInfo = notification.userInfo
        let keyboardFrame = (userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        
        let keyboardHeight = keyboardFrame.height - 50
        frame.origin = CGPoint(x: frame.origin.x, y: -keyboardHeight)
    }
    
    @objc private func keyboardWillHide() {
        frame.origin = CGPoint(x: frame.origin.x, y: 0)
    }
    
    @objc private func buttonTap(_ sender: UIButton) {
        buttonTag = sender.tag
        switch buttonTag {
        case 0 : typeRequest = .oneNumber
        case 1 : typeRequest = .random
        case 2 : typeRequest = .range
        case 3 : typeRequest = .year
        default : return
        }
        buttonsArray.forEach { button in
            button == sender ? self.buttonTurnOn(button) : self.buttonTurnOff(button)
        }
    }
    
//MARK: - private func:
    
    private func setBezierPathView() {
        bezierDiceOne = BezierDiceFive(frame: CGRect(x: 170, y: 230, width: 120, height: 120))
        addSubview(bezierDiceOne)
        bezierDiceFive = BezierDiceFive(frame: CGRect(x: 50, y: 230, width: 120, height: 120))
        bezierDiceFive.rotate()
        addSubview(bezierDiceFive)
    }
    
    private func setTitlesLabel() {
        let labels = [titleLabel, descriptionLabel]
        labels.forEach { label in
            label.textAlignment = .center
            label.numberOfLines = 0
        }
        titleLabel.text = TitleConstants.titleLabel
        titleLabel.font = UIFont(name: FontsEnum.bold, size: 30)
        descriptionLabel.text = TitleConstants.descriptionLabel
        descriptionLabel.font = UIFont(name: FontsEnum.light, size: 16)
    }
    
    private func setNambersButtons() {
        let buttonsNames = [TitleConstants.userNumber,
                            TitleConstants.randomNumber,
                            TitleConstants.rangeNumber,
                            TitleConstants.multipleNumber]
        buttonsNames.enumerated().forEach { index, title in
            let button = UIButton(type: .system)
            button.setTitle(title, for: .normal)
            button.titleLabel?.font = UIFont(name: FontsEnum.regular, size: 13)
            button.titleLabel?.textAlignment = .center
            button.titleLabel?.lineBreakMode = NSLineBreakMode.byWordWrapping;
            buttonTurnOff(button)
            button.tag = index
            buttonsArray.append(button)
            buttonsStack.addArrangedSubview(button)
            button.addTarget(self, action: #selector(buttonTap(_:)), for: .touchUpInside)
            button.tag == 0 ? buttonTurnOn(button) : buttonTurnOff(button)
        }
    }
    
    private func buttonTurnOn(_ button: UIButton) {
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .customColor
        button.layer.shadowOpacity = 0
        setPlacholder(button)
        bezierDiceOne.setNeedsDisplay()
        bezierDiceFive.setNeedsDisplay()
    }
    
    private func setPlacholder (_ button: UIButton) {
        let placeholdersArray = [ TitleConstants.placeholderUserNumber, TitleConstants.placeholderRandomNumber, TitleConstants.placeholderRangeNumber, TitleConstants.placeholderDateNumber]
        if button.tag == 1 {
            let someNumber = Int.random(in: 1...1000)
            inputTextField.text = "\(someNumber)"
        } else {
            inputTextField.text = ""
            placeholdersArray.enumerated().forEach { index, text in
                guard index == button.tag else {return}
                inputTextField.placeholder = text
            }
        }
    }
    
    private func buttonTurnOff(_ button: UIButton) {
        button.setTitleColor(.label, for: .normal)
        button.setBorderLayer(backgroundColor: .secondarySystemBackground,
                              borderColor: .systemGray,
                              borderWidth: 0.1,
                              cornerRadius: 5,
                              tintColor: .label)

        button.setShadow(color: .systemGray2,
                         offsetWidh: 1,
                         offseHeight: 4,
                         opacity: 1,
                         radius: 4,
                         masksToBounds: false,
                         cornerRadius: 5)
    }
    
    private func setEnterLabel() {
        enterLabel.text = TitleConstants.enterLabel
        enterLabel.textAlignment = .left
        enterLabel.textColor = .label
        
        enterLabel.font = UIFont(name: FontsEnum.light, size: 15)
        enterLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(enterLabel)
    }
    
    private func setInputTextField() {
        inputTextField.delegate = self
        inputTextField.clearButtonMode = .whileEditing
        inputTextField.keyboardType = .numbersAndPunctuation
        inputTextField.setBorderLayer(backgroundColor: .secondarySystemBackground, borderColor: .systemGray, borderWidth: 0.6, cornerRadius: 10, tintColor: nil)
        let paddingView = UIView(frame: CGRectMake(0, 0, 15, self.inputTextField.frame.height))
        inputTextField.leftView = paddingView
        inputTextField.leftViewMode = .always
    }
    
    private func setShowButton() {
        showButton.titleLabel?.font = UIFont(name: FontsEnum.bold, size: 18)
        showButton.setBorderLayer(backgroundColor: .customColor, borderColor: .gray, borderWidth: 0.6, cornerRadius: 10, tintColor: .systemBackground)
        showButton.setTitle(TitleConstants.showButton, for: .normal)
        showButton.tintColor = .white
    }
    
    private func setButtonsStack() {
        buttonsStack.axis = .horizontal
        buttonsStack.spacing = 10
        buttonsStack.distribution = .fillEqually
        buttonsStack.translatesAutoresizingMaskIntoConstraints = false
        addSubview(buttonsStack)
    }
    
    private func setTitlesStack() {
        titlesStack = UIStackView(arrangedSubviews: [titleLabel, descriptionLabel])
        titlesStack.axis = .vertical
        titlesStack.spacing = 10
        titlesStack.translatesAutoresizingMaskIntoConstraints = false
        addSubview(titlesStack)
    }
    
    private func setInputStack() {
        inputStack = UIStackView(arrangedSubviews: [inputTextField, showButton])
        inputStack.axis = .vertical
        inputStack.distribution = .fillEqually
        inputStack.spacing = 20
        inputStack.translatesAutoresizingMaskIntoConstraints = false
        addSubview(inputStack)
    }
    
    private func registerKeyboard() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    private func removeKeyboardObserver() {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
// MARK: - Constraints:
    
    private func setConstraints() {
        NSLayoutConstraint.activate([
            
            titlesStack.topAnchor.constraint(equalTo: topAnchor),
            titlesStack.heightAnchor.constraint(equalToConstant: 100),
            titlesStack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            titlesStack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            
            buttonsStack.heightAnchor.constraint(equalToConstant: 80),
            buttonsStack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            buttonsStack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            buttonsStack.bottomAnchor.constraint(equalTo: enterLabel.topAnchor, constant: -10),
            
            enterLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            enterLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            enterLabel.bottomAnchor.constraint(equalTo: inputStack.topAnchor, constant: -5),
            enterLabel.heightAnchor.constraint(equalToConstant: 25),
            
            inputStack.heightAnchor.constraint(equalToConstant: 120),
            inputStack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            inputStack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            inputStack.bottomAnchor.constraint(equalTo: bottomAnchor, constant:  -20)
        ])
    }
}

//MARK: - TextField Delegate:

extension ChoiseNumbersView: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return endEditing(true)
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        registerKeyboard()
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        buttonTag != 1 ? true : false
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        let currentText = textField.text ?? ""
        guard let stringRange = Range(range, in: currentText) else { return false }
        let updatedText = currentText.replacingCharacters(in: stringRange, with: string)
        
        switch buttonTag {
        case 0, 1 :
            return validateManager.isContainsOnlyDigits(text: updatedText)
        default : return true
        }
    }
}




