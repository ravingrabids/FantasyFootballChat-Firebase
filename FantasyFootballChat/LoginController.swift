//
//  ViewController.swift
//  FantasyFootballChat
//
//  Created by Андрей Гончаров on 14/03/2018.
//  Copyright © 2018 Goncharov Andrei. All rights reserved.
//

import UIKit
import Firebase

class LoginController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    var dialoguesController = DialoguesController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(red: 10/255 , green: 110/255, blue: 10/255, alpha: 1)
        view.addSubview(inputsContainerView)
        view.addSubview(loginRegisterButton)
        view.addSubview(applicationNameTextField)
        view.addSubview(loginRegisterSegmentedControl)
        view.addSubview(addProfileImage)
        setupInputsContainerView()
        setupLoginRegisterButton()
        setupApplicationNameTextField()
        setupLoginRegisterSegmentedControl()
        setupAddProfileImage()
    }
    
    // setuping views for vc
    // container for inputs
    let inputsContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.white
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 5
        view.layer.masksToBounds = true
        return view
    }()
    
    // login/ registration button
    let loginRegisterButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = UIColor(red: 10/255 , green: 80/255, blue: 10/255, alpha: 1)
        button.setTitle("Register", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitleColor(UIColor.white, for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        button.layer.cornerRadius = 5
        button.layer.masksToBounds = true
        button.addTarget(self, action: #selector(handleLoginRegister), for: .touchUpInside)
        return button
    }()
    
    // profile image button
    let addProfileImage: UIButton = {
        let addImage = UIButton()
        let image = UIImage(named: "addPhoto1")
        addImage.setImage(image, for: .normal)
        addImage.layer.cornerRadius = 5
        addImage.layer.masksToBounds = true
        addImage.translatesAutoresizingMaskIntoConstraints = false
        addImage.addTarget(self, action: #selector(handleAddPhotoToProfile), for: .touchUpInside)
        return addImage
    }()
    
    let nameTextField: UITextField = {
        let name = UITextField()
        name.placeholder = "Name"
        name.translatesAutoresizingMaskIntoConstraints = false
        return name
    }()
    
    let emailTextField: UITextField = {
        let email = UITextField()
        email.placeholder = "Email address"
        email.translatesAutoresizingMaskIntoConstraints = false
        return email
    }()
    
    let passwordTextField: UITextField = {
        let password = UITextField()
        password.placeholder = "Password"
        password.translatesAutoresizingMaskIntoConstraints = false
        password.isSecureTextEntry = true
        return password
    }()
    
    let nameSeparatorView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(red: 200/255, green: 200/255, blue: 200/255, alpha: 1)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let emailSeparatorView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(red: 200/255, green: 200/255, blue: 200/255, alpha: 1)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let applicationNameTextField: UILabel = {
        let appName = UILabel()
        appName.text = "Fantasy Football Chat"
        appName.textColor = UIColor.white
        appName.font = UIFont.boldSystemFont(ofSize: 18)
        appName.translatesAutoresizingMaskIntoConstraints = false
        appName.textAlignment = NSTextAlignment.center
        return appName
    }()
    
    let loginRegisterSegmentedControl: UISegmentedControl = {
        let segmentedControl = UISegmentedControl(items: ["Login","Register"])
        segmentedControl.translatesAutoresizingMaskIntoConstraints = false
        segmentedControl.tintColor = UIColor.white
        segmentedControl.selectedSegmentIndex = 1
        segmentedControl.addTarget(self, action: #selector(handleLoginRegisterChange), for: .valueChanged)
        return segmentedControl
    }()
    
    // constraints for Login/ Register segment control
    func setupLoginRegisterSegmentedControl() {
        // constraints for segmentedcontrol
        loginRegisterSegmentedControl.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        loginRegisterSegmentedControl.bottomAnchor.constraint(equalTo: inputsContainerView.topAnchor, constant: -12).isActive = true
        loginRegisterSegmentedControl.widthAnchor.constraint(equalTo: inputsContainerView.widthAnchor, multiplier: 1).isActive = true
        loginRegisterSegmentedControl.heightAnchor.constraint(equalToConstant: 35).isActive = true
    }
    
    var inputsContainerViewHeightAnchor: NSLayoutConstraint?
    var nameTextFieldHeightAnchor: NSLayoutConstraint?
    var emailTextFieldHeightAnchor: NSLayoutConstraint?
    var passwordTextFieldHeightAnchor: NSLayoutConstraint?
    
    func setupInputsContainerView() {
        // constraints
        inputsContainerView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        inputsContainerView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        inputsContainerView.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -24).isActive = true
        inputsContainerViewHeightAnchor = inputsContainerView.heightAnchor.constraint(equalToConstant: 150)
        inputsContainerViewHeightAnchor?.isActive = true
        
        inputsContainerView.addSubview(nameTextField)
        inputsContainerView.addSubview(nameSeparatorView)
        inputsContainerView.addSubview(emailTextField)
        inputsContainerView.addSubview(emailSeparatorView)
        inputsContainerView.addSubview(passwordTextField)
        
        // constraints for name TextFiled
        nameTextField.leftAnchor.constraint(equalTo: inputsContainerView.leftAnchor, constant: 12).isActive = true
        nameTextField.topAnchor.constraint(equalTo: inputsContainerView.topAnchor).isActive = true
        nameTextField.widthAnchor.constraint(equalTo: inputsContainerView.widthAnchor).isActive = true
        nameTextFieldHeightAnchor = nameTextField.heightAnchor.constraint(equalTo: inputsContainerView.heightAnchor, multiplier: 1/3)
        nameTextFieldHeightAnchor?.isActive = true
        
        // constraints for nameSeparator
        nameSeparatorView.leftAnchor.constraint(equalTo: inputsContainerView.leftAnchor).isActive = true
        nameSeparatorView.topAnchor.constraint(equalTo: nameTextField.bottomAnchor).isActive = true
        nameSeparatorView.widthAnchor.constraint(equalTo: inputsContainerView.widthAnchor).isActive = true
        nameSeparatorView.heightAnchor.constraint(equalToConstant: 1).isActive = true
        
        // constraints for emailTextField
        emailTextField.leftAnchor.constraint(equalTo: inputsContainerView.leftAnchor, constant: 12).isActive = true
        emailTextField.topAnchor.constraint(equalTo: nameTextField.bottomAnchor).isActive = true
        emailTextField.widthAnchor.constraint(equalTo: inputsContainerView.widthAnchor).isActive = true
        emailTextFieldHeightAnchor = emailTextField.heightAnchor.constraint(equalTo: inputsContainerView.heightAnchor, multiplier: 1/3)
        emailTextFieldHeightAnchor?.isActive = true
        
        
        // constraints for emailSeparatorView
        emailSeparatorView.leftAnchor.constraint(equalTo: inputsContainerView.leftAnchor).isActive = true
        emailSeparatorView.topAnchor.constraint(equalTo: emailTextField.bottomAnchor).isActive = true
        emailSeparatorView.widthAnchor.constraint(equalTo: inputsContainerView.widthAnchor).isActive = true
        emailSeparatorView.heightAnchor.constraint(equalToConstant: 1).isActive = true
        
        // constraints for passwordTextField
        passwordTextField.leftAnchor.constraint(equalTo: inputsContainerView.leftAnchor, constant: 12).isActive = true
        passwordTextField.topAnchor.constraint(equalTo: emailTextField.bottomAnchor).isActive = true
        passwordTextField.widthAnchor.constraint(equalTo: inputsContainerView.widthAnchor).isActive = true
        passwordTextFieldHeightAnchor = passwordTextField.heightAnchor.constraint(equalTo: inputsContainerView.heightAnchor, multiplier: 1/3)
        passwordTextFieldHeightAnchor?.isActive = true
    }
    
    func setupLoginRegisterButton() {
        // constraints for login / register button
        loginRegisterButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        loginRegisterButton.topAnchor.constraint(equalTo: inputsContainerView.bottomAnchor, constant: 12).isActive = true
        loginRegisterButton.widthAnchor.constraint(equalTo: inputsContainerView.widthAnchor).isActive = true
        loginRegisterButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
    }
    
    func setupApplicationNameTextField() {
        // constraints for applicationNameTextField
        applicationNameTextField.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        applicationNameTextField.bottomAnchor.constraint(equalTo: view.centerYAnchor, constant: -200).isActive = true
        applicationNameTextField.widthAnchor.constraint(equalToConstant: 200).isActive = true
        applicationNameTextField.heightAnchor.constraint(equalToConstant: 40).isActive = true
    }
    
    func setupAddProfileImage() {
        // constraints for addProfileImage
        addProfileImage.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        addProfileImage.topAnchor.constraint(equalTo: applicationNameTextField.bottomAnchor, constant: 8).isActive = true
        addProfileImage.widthAnchor.constraint(equalToConstant: 50).isActive = true
        addProfileImage.heightAnchor.constraint(equalToConstant: 50).isActive = true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // handle login register
    @objc func handleLoginRegister() {
        if loginRegisterSegmentedControl.selectedSegmentIndex == 0 {
            handleLogin()
        } else {
            handleRegister()
        }
    }
    
    // handle login firebase
    @objc func handleLogin() {
        guard let email = emailTextField.text, let password = passwordTextField.text
            else {
                print("Form is not valid")
                return
            }
        Auth.auth().signIn(withEmail: email, password: password) { (user, err) in
            if err != nil {
                print(err!)
                let alertLogin = UIAlertController(title: "Oops", message: "Email or password is incorrect", preferredStyle: UIAlertControllerStyle.alert)
                alertLogin.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
                self.present(alertLogin, animated: true, completion: nil)
                return
                }
            self.dialoguesController.fetchUserAndSetupNavBarTitle()
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    @objc func handleRegister() {
        guard let email = emailTextField.text, let password = passwordTextField.text, let name = nameTextField.text
            else {
                print("Form is not valid")
                return
        }
        Auth.auth().createUser(withEmail: email, password: password) { ( user, error) in
            if error != nil {
                print(error!)
                let alertRegister = UIAlertController(title: "Oops", message: "The email address is already in use by another account", preferredStyle: UIAlertControllerStyle.alert)
                alertRegister.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
                self.present(alertRegister, animated: true, completion: nil)
            }
            guard let uid = user?.uid
                else {
                    return
            }
            let imageName = NSUUID().uuidString
            let storageRef = Storage.storage().reference().child("ProfileImages").child("\(imageName).jpg")
            if let uploadData = UIImageJPEGRepresentation(self.addProfileImage.image(for: .normal)!, 0.1) {
                storageRef.putData(uploadData, metadata: nil, completion: { (metadata, error) in
                if error != nil {
                    print(error!)
                    return
                }
                if let profileImageUrl = metadata?.downloadURL()?.absoluteString {
                    let values = ["Name" : name, "Email": email, "ProfileImageUrl": profileImageUrl]
                    self.registerUserIntoDatabaseWithUid(uid: uid, values: values as [String : AnyObject])
                    // user added to base (name, email and photo)
                    }
                })
            }
        }
    }
    
    private func registerUserIntoDatabaseWithUid(uid: String, values: [String : AnyObject]) {
        let ref = Database.database().reference()
        let usersReference = ref.child("users").child(uid)
        usersReference.updateChildValues(values, withCompletionBlock: { (err, ref) in
            if err != nil {
                print(err!)
                return
                }
            })
    // func setupNavBarWithUser
        let user = User()
        user.setValuesForKeys(values)
        self.dialoguesController.setupNavBarWithUser(user: user)
 
        self.dismiss(animated: true, completion: nil)
                // user successfully added to base, successfully authed
    }
    
    // add photo to user profile
    @objc func handleAddPhotoToProfile() {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.allowsEditing = true
        present(picker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        var selectedFromPicker: UIImage?
        if let editedImage = info["UIImagePickerControllerEditedImage"] as! UIImage? {
            selectedFromPicker = editedImage
        } else if let originalImage = info["UIImagePickerControllerOriginalImage"] as! UIImage? {
            selectedFromPicker = originalImage
            }
        if let selectedImage = selectedFromPicker {
            addProfileImage.setImage(selectedImage, for: .normal)
            }
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    // change button title login register
    @objc func handleLoginRegisterChange() {
        let title = loginRegisterSegmentedControl.titleForSegment(at: (loginRegisterSegmentedControl.selectedSegmentIndex))
        loginRegisterButton.setTitle( title, for: .normal)
            // change uiview of inputsContainer
        inputsContainerViewHeightAnchor?.constant = loginRegisterSegmentedControl.selectedSegmentIndex == 0 ? 100 : 150
            // change height of nameTextField
        nameTextFieldHeightAnchor?.isActive = false
        nameTextFieldHeightAnchor = nameTextField.heightAnchor.constraint(equalTo: inputsContainerView.heightAnchor, multiplier: loginRegisterSegmentedControl.selectedSegmentIndex == 0 ? 0 : 1/3)
        nameTextFieldHeightAnchor?.isActive = true
            // change height of emailTextFiled
        emailTextFieldHeightAnchor?.isActive = false
        emailTextFieldHeightAnchor = emailTextField.heightAnchor.constraint(equalTo: inputsContainerView.heightAnchor, multiplier: loginRegisterSegmentedControl.selectedSegmentIndex == 0 ? 1/2 : 1/3)
        emailTextFieldHeightAnchor?.isActive = true
            // change height of passwordTextField
        passwordTextFieldHeightAnchor?.isActive = false
        passwordTextFieldHeightAnchor = passwordTextField.heightAnchor.constraint(equalTo: inputsContainerView.heightAnchor, multiplier: loginRegisterSegmentedControl.selectedSegmentIndex == 0 ? 1/2 : 1/3)
        passwordTextFieldHeightAnchor?.isActive = true
            // hide adding profile image
        if loginRegisterSegmentedControl.selectedSegmentIndex == 0 {
            addProfileImage.isHidden = true
        } else {
            addProfileImage.isHidden = false
            }
    }
    
}
