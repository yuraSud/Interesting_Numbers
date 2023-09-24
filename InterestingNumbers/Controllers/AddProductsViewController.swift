//
//  AddProductsViewController.swift
//  Interesting_Numbers
//
//  Created by Yura Sabadin on 19.09.2023.
//

import UIKit
import Combine

class AddProductsViewController: UIViewController {
    
    let addViewModel = AddProductViewModel()
    let cancelButton = UIButton(type: .system)
    let titleLabel = UILabel()
    let addImageView = UIImageView()
    let nameTextFielf = UITextFieldRightView()
    let costTextField = UITextFieldRightView()
    let categoryTextField = UITextFieldRightView()
    let addButton = UIButton(type: .system)
    var stackTF = UIStackView()
   
    let reloadSubject = PassthroughSubject<Bool,Never>()
    var subscribers = Set<AnyCancellable>()
    
    //MARK: - Life cycle:
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemGroupedBackground
        setCloseButton()
        configureUI()
        setConstraints()
        addTargetButton()
        sinkOnPublishers()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    //MARK: - Fuctions:
    
   
    
    //MARK: - @objc Functions:
    
    @objc private func closeVC() {
        self.dismiss(animated: true)
    }
    
    @objc func addProductsToStorage() {
        addViewModel.addToServer() { isUpload in
            if isUpload {
                self.reloadSubject.send(true)
            }
        }
        closeVC()
    }
    
    @objc func alertWhenTapOnImage() {
        let alert = UIAlertController(title: "choose Image Menu", message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Camera", style: .default, handler: { _ in self.openCamera() }))
        alert.addAction(UIAlertAction(title: "Gallary", style: .default, handler: { _ in
            self.openGallery() }))
        alert.addAction(UIAlertAction.init(title: "Cancel", style: .cancel, handler: nil))
    
        switch UIDevice.current.userInterfaceIdiom {
        case .pad:
            alert.popoverPresentationController?.sourceView = addImageView
            alert.popoverPresentationController?.sourceRect = addImageView.bounds
            alert.popoverPresentationController?.permittedArrowDirections = .up
        default:
            break
        }
        self.present(alert, animated: true, completion: nil)
    }
    
    
    //MARK: - private Functions:
    
    private func setCloseButton() {
        view.addSubview(cancelButton)
        cancelButton.translatesAutoresizingMaskIntoConstraints = false
        cancelButton.setImage(UIImage(systemName: "multiply"), for: .normal)
        cancelButton.setBorderLayer(backgroundColor: .black, borderColor: .gray, borderWidth: 2, cornerRadius: 15, tintColor: .white)
    }
    
    func configureUI() {
        configTitle()
        configImageView()
        configureStackTF()
    }
    
    func configTitle() {
        view.addSubview(titleLabel)
        titleLabel.text = TitleConstants.titleAddVC
        titleLabel.frame = .init(x: 16, y: 25, width: view.frame.width-32, height: 40)
        titleLabel.adjustsFontSizeToFitWidth = true
        titleLabel.textAlignment = .center
        titleLabel.font = .boldSystemFont(ofSize: 19)
    }
    
    func configImageView() {
        view.addSubview(addImageView)
        addImageView.image = ImageConstants.addImage
        addImageView.frame = .init(x: 50, y: 69, width: view.frame.width-100, height: 150)
        addImageView.contentMode = .scaleAspectFit
        addImageView.isUserInteractionEnabled = true
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(alertWhenTapOnImage))
        addImageView.addGestureRecognizer(tapGesture)
    }
    
    func configureStackTF() {
        let tfArray = [nameTextFielf,costTextField, categoryTextField]
        stackTF = UIStackView(arrangedSubviews: tfArray)
        stackTF.translatesAutoresizingMaskIntoConstraints = false
        stackTF.spacing = 10
        stackTF.axis = .vertical
        stackTF.distribution = .fillEqually
        view.addSubview(stackTF)
        tfArray.forEach { tf in
            tf.heightAnchor.constraint(equalToConstant: 37).isActive = true
            tf.autocorrectionType = .no
            tf.autocapitalizationType = .none
            tf.borderStyle = .roundedRect
            tf.font = .systemFont(ofSize: 17)
            tf.delegate = self
        }
        nameTextFielf.placeholder = "Enter name product"
        costTextField.placeholder = "Enter cost product"
        categoryTextField.placeholder = "Enter product category"
        costTextField.setupRightLabel(rightText: ", €")
        stackTF.addArrangedSubview(addButton)
        
        addButton.setTitle("Add to Storage", for: .normal)
        addButton.setBorderLayer(backgroundColor: .link, borderColor: .black, borderWidth: 1, cornerRadius: 8, tintColor: .white)
        addButton.titleLabel?.textColor = .white
        addButton.titleLabel?.font = .boldSystemFont(ofSize: 18)
    }
    
    func sinkOnPublishers() {
        addViewModel.addIsEnable
            .sink { isEnable in
                self.addButton.isEnabled = isEnable
            }
            .store(in: &subscribers)
        
        nameTextFielf.textPublisher
            .assign(to: \.name, on: addViewModel)
            .store(in: &subscribers)
        
        costTextField.textPublisher
            .assign(to: \.cost, on: addViewModel)
            .store(in: &subscribers)
        
        categoryTextField.textPublisher
            .assign(to: \.category, on: addViewModel)
            .store(in: &subscribers)
    }
   
    private func addTargetButton() {
        addButton.addTarget(self, action: #selector(addProductsToStorage), for: .touchUpInside)
        cancelButton.addTarget(self, action: #selector(closeVC), for: .touchUpInside)
    }
    
    private func setConstraints() {
        NSLayoutConstraint.activate([
            cancelButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -15),
            cancelButton.heightAnchor.constraint(equalTo: cancelButton.widthAnchor),
            cancelButton.widthAnchor.constraint(equalToConstant: 30),
            cancelButton.topAnchor.constraint(equalTo: view.topAnchor, constant: 15),
            
            stackTF.topAnchor.constraint(equalTo: addImageView.bottomAnchor, constant: 15),
            stackTF.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 30),
            stackTF.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -30)
        ])
    }
}

//MARK: - UITextFieldDelegate

extension AddProductsViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == nameTextFielf {
            costTextField.becomeFirstResponder()
        } else {
            view.endEditing(true)
        }
        return true
    }
}

//MARK: - UIImagePickerControllerDelegate
extension AddProductsViewController: UIImagePickerControllerDelegate,  UINavigationControllerDelegate {
    
    func openCamera(){
        if(UIImagePickerController .isSourceTypeAvailable(UIImagePickerController.SourceType.camera)){
            let imgPicker = UIImagePickerController()
            imgPicker.delegate = self
            imgPicker.sourceType = UIImagePickerController.SourceType.camera
            imgPicker.allowsEditing = false
            self.present(imgPicker, animated: true, completion: nil)
        } else {
            let alert  = UIAlertController(title: "Attention", message: "you have not camera", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func openGallery(){
        let imgPicker = UIImagePickerController()
        imgPicker.delegate = self
        imgPicker.sourceType = UIImagePickerController.SourceType.photoLibrary
        imgPicker.allowsEditing = true
        self.present(imgPicker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        var imageProduct = UIImage()
        if let picImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
            imageProduct = picImage
        } else if let originImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            imageProduct = originImage
        }
        addImageView.image = imageProduct
        addViewModel.image = imageProduct
        dismiss(animated: true)
    }
}
