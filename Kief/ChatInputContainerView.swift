//
//  ChatInputContainerView.swift
//  KiefApp
//
//  Created by Simon Elhoej Steinmejer on 6/5/17.
//  Copyright © 2017 Simon Elhoej Steinmejer. All rights reserved.
//

import UIKit

class ChatInputContainerView: UIView, UITextFieldDelegate
{
    weak var chatLogController: ChatLogController?
    {
        didSet
        {
            sendButton.addTarget(chatLogController, action: #selector(ChatLogController.handleSend), for: .touchUpInside)
            
            uploadImageView.addGestureRecognizer(UITapGestureRecognizer(target: chatLogController, action: #selector(ChatLogController.handleUploadTap)))
        }
    }

    lazy var inputTextField: UITextField =
    {
        let textField = UITextField()
        textField.placeholder = "Enter message..."
        textField.delegate = self
        textField.addTarget(self, action: #selector(handleTextInput), for: .editingChanged)
            
        return textField
    }()
    
    let sendButton: UIButton =
    {
        let sendButton = UIButton(type: .system)
        sendButton.setTitle("Send", for: .normal)
        sendButton.isEnabled = false
        
        return sendButton
    }()
    
    
    let uploadImageView: UIImageView =
    {
        let uploadImageView = UIImageView()
        uploadImageView.isUserInteractionEnabled = true
        uploadImageView.image = UIImage(named: "upload_image_icon")
        
        return uploadImageView
    }()
    
    let seperatorLine: UIView =
    {
        let seperatorLine = UIView()
        seperatorLine.backgroundColor = UIColor.rgb(red: 220, green: 220, blue: 220)
        seperatorLine.translatesAutoresizingMaskIntoConstraints = false
        
        return seperatorLine
    }()

    override init(frame: CGRect)
    {
        super.init(frame: frame)
        
        isUserInteractionEnabled = false
        
        backgroundColor = UIColor.white

        addSubview(uploadImageView)
        addSubview(sendButton)
        addSubview(self.inputTextField)
        addSubview(seperatorLine)
        
        uploadImageView.anchor(top: nil, left: leftAnchor, bottom: nil, right: nil, paddingTop: 0, paddingLeft: 0, paddingRight: 0, paddingBottom: 0, width: 44, height: 44)
        uploadImageView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        
        sendButton.anchor(top: nil, left: nil, bottom: nil, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingRight: 0, paddingBottom: 0, width: 80, height: 0)
        sendButton.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true

        self.inputTextField.anchor(top: topAnchor, left: uploadImageView.rightAnchor, bottom: bottomAnchor, right: sendButton.leftAnchor, paddingTop: 0, paddingLeft: 8, paddingRight: 0, paddingBottom: 0, width: 0, height: 0)
        self.inputTextField.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true

        seperatorLine.anchor(top: topAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingRight: 0, paddingBottom: 0, width: 0, height: 1)
    }
    
    func handleTextInput()
    {
        if (inputTextField.text?.characters.count)! < 1
        {
            sendButton.isEnabled = false
        }
        else if (inputTextField.text?.characters.count)! > 0
        {
            sendButton.isEnabled = true
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool
    {
        chatLogController?.handleSend()
        return true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
