//
//  File.swift
//  FantasyFootballChat
//
//  Created by Андрей Гончаров on 12/04/2018.
//  Copyright © 2018 Goncharov Andrei. All rights reserved.
//

import UIKit

class ChatInputContainerView: UIView, UITextFieldDelegate {
    
    var chatController: ChatController? {
        didSet {
            sendButton.addTarget(chatController, action: #selector(ChatController.handleSend), for: .touchUpInside)
            uploadImageView.addTarget(chatController, action: #selector(ChatController.handleUploadImage), for: .touchUpInside)
        }
    }
    
    let uploadImageView: UIButton = {
        let uploadImageView = UIButton()
        let uploadImage = UIImage(named: "uploadImage")
        uploadImageView.setImage(uploadImage, for: .normal)
        uploadImageView.translatesAutoresizingMaskIntoConstraints = false
        return uploadImageView
    }()
    
    let sendButton: UIButton = {
        let sendButton = UIButton()
        sendButton.setTitle("Send", for: .normal)
        sendButton.translatesAutoresizingMaskIntoConstraints = false
        sendButton.setTitleColor(UIColor(red: 10/255 , green: 80/255, blue: 10/255, alpha: 1), for: .normal)
        return sendButton
    }()
    
    lazy var inputTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Enter message..."
        textField.tintColor = UIColor(red: 10/255 , green: 80/255, blue: 10/255, alpha: 1)
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.delegate = self
        return textField
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = UIColor.white
        addSubview(uploadImageView)
        
        // constraints
        uploadImageView.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        uploadImageView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        uploadImageView.widthAnchor.constraint(equalToConstant: 40).isActive = true
        uploadImageView.heightAnchor.constraint(equalToConstant: 40).isActive = true
        
        addSubview(sendButton)
        
        // constraints
        sendButton.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        sendButton.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        sendButton.widthAnchor.constraint(equalToConstant: 80).isActive = true
        sendButton.heightAnchor.constraint(equalTo: heightAnchor).isActive = true
        
        addSubview(self.inputTextField)
        // constraints
        self.inputTextField.leftAnchor.constraint(equalTo: uploadImageView.rightAnchor, constant: 8).isActive = true
        self.inputTextField.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        self.inputTextField.rightAnchor.constraint(equalTo: sendButton.leftAnchor).isActive = true
        self.inputTextField.heightAnchor.constraint(equalTo: heightAnchor).isActive = true
        
        let separatorLineView = UIView()
        separatorLineView.backgroundColor = UIColor(red: 10/255 , green: 80/255, blue: 10/255, alpha: 1)
        separatorLineView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(separatorLineView)
        
        // contraints
        separatorLineView.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        separatorLineView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        separatorLineView.widthAnchor.constraint(equalTo: widthAnchor).isActive = true
        separatorLineView.heightAnchor.constraint(equalToConstant: 1).isActive = true
        
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        chatController?.handleSend()
        return true
    }
}


