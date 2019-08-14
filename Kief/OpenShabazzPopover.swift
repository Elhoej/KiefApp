//
//  OpenShabazzPopover.swift
//  KiefApp
//
//  Created by Simon Elhoej Steinmejer on 6/10/17.
//  Copyright © 2017 Simon Elhoej Steinmejer. All rights reserved.
//

import UIKit
import Firebase

class OpenShabazzPopover: UIViewController
{
    var statusController = StatusController()
    
    let titleLabel: UILabel =
    {
        let label = UILabel()
        label.text = "Enter the amount of hours you will be open for, starting from now."
        label.textColor = UIColor.rgb(red: 48, green: 42, blue: 35)
        label.font = UIFont.boldSystemFont(ofSize: 18)
        label.numberOfLines = 3
        label.textAlignment = .center
        
        return label
    }()
    
    let inputTextField: UITextField =
    {
        let inputTextField = UITextField()
        inputTextField.placeholder = "Hours..."
        inputTextField.placeHolderTextColor = UIColor(red: 235/255, green: 216/255, blue: 164/255, alpha: 0.3)
        inputTextField.textColor = UIColor.rgb(red: 235, green: 216, blue: 164)
        inputTextField.backgroundColor = UIColor.rgb(red: 48, green: 42, blue: 35)
        inputTextField.borderStyle = .roundedRect
        inputTextField.font = UIFont.systemFont(ofSize: 14)
        inputTextField.keyboardType = .numberPad
        inputTextField.addTarget(self, action: #selector(handeMinChar), for: .editingChanged)
        
        return inputTextField
    }()
    
    let openButton: UIButton =
    {
        let openButton = UIButton(type: .system)
        openButton.setTitle("Open", for: .normal)
        openButton.backgroundColor = UIColor(red: 48/255, green: 42/255, blue: 35/255, alpha: 0.7)
        openButton.setTitleColor(UIColor.rgb(red: 235, green: 216, blue: 164), for: .normal)
        openButton.addTarget(self, action: #selector(handleOpenShabazz), for: .touchUpInside)
        openButton.layer.cornerRadius = 5
        openButton.layer.masksToBounds = true
        openButton.isEnabled = false
        
        return openButton
    }()
    
    let cancelButton: UIButton =
    {
        let cancelButton = UIButton(type: .system)
        cancelButton.setTitle("Cancel", for: .normal)
        cancelButton.backgroundColor = UIColor.rgb(red: 48, green: 42, blue: 35)
        cancelButton.setTitleColor(UIColor.rgb(red: 235, green: 216, blue: 164), for: .normal)
        cancelButton.addTarget(self, action: #selector(handleCancel), for: .touchUpInside)
        
        return cancelButton
    }()
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.init(white: 0, alpha: 0.8)
        
        setupOpenView()
        
        self.hideKeyboardWhenTappedAround()
    }
    
    func setupOpenView()
    {
        let containerView = UIView()
        containerView.backgroundColor = UIColor.rgb(red: 235, green: 216, blue: 164)
        containerView.layer.cornerRadius = 8
        containerView.layer.borderWidth = 1
        containerView.layer.borderColor = UIColor.black.cgColor
        containerView.layer.masksToBounds = true
        
        view.addSubview(containerView)
        
        containerView.anchor(top: nil, left: nil, bottom: nil, right: nil, paddingTop: 0, paddingLeft: 0, paddingRight: 0, paddingBottom: 0, width: 260, height: 200)
        containerView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        containerView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        
        containerView.addSubview(titleLabel)
        containerView.addSubview(cancelButton)
        containerView.addSubview(openButton)
        containerView.addSubview(inputTextField)
        
        titleLabel.anchor(top: containerView.topAnchor, left: containerView.leftAnchor, bottom: nil, right: containerView.rightAnchor, paddingTop: 16, paddingLeft: 8, paddingRight: 8, paddingBottom: 0, width: 0, height: 0)
        
        cancelButton.anchor(top: nil, left: containerView.leftAnchor, bottom: containerView.bottomAnchor, right: containerView.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingRight: 0, paddingBottom: 0, width: 0, height: 50)
        
        inputTextField.anchor(top: titleLabel.bottomAnchor, left: containerView.leftAnchor, bottom: nil, right: nil, paddingTop: 16, paddingLeft: 20, paddingRight: 0, paddingBottom: 0, width: 102, height: 0)
        
        openButton.anchor(top: nil, left: nil, bottom: nil, right: containerView.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingRight: 20, paddingBottom: 0, width: 102, height: 0)
        openButton.centerYAnchor.constraint(equalTo: inputTextField.centerYAnchor).isActive = true
        openButton.heightAnchor.constraint(equalTo: inputTextField.heightAnchor).isActive = true
    }
    
    func handeMinChar()
    {
        if (inputTextField.text?.characters.count)! > 0
        {
            openButton.backgroundColor = UIColor.rgb(red: 48, green: 42, blue: 35)
            openButton.isEnabled = true
        }
        else
        {
            openButton.backgroundColor = UIColor(red: 48/255, green: 42/255, blue: 35/255, alpha: 0.7)
            openButton.isEnabled = false
        }
    }
    
    func handleOpenShabazz()
    {
        if let hours: Int = Int(inputTextField.text!)
        {
            let hoursInSeconds = hours * 3600
            let currentTime = Int(Date().timeIntervalSince1970)
            let closingTime = hoursInSeconds + currentTime
            
            FIRDatabase.database().reference().child("timer").updateChildValues(["closetime": closingTime], withCompletionBlock: { (error, ref) in
                
                if error != nil
                {
                    print("Failed to upload timer data")
                    return
                }
                
                FIRDatabase.database().reference().child("button").updateChildValues(["shabazz": true], withCompletionBlock: { (error, ref) in
                    
                    if error != nil
                    {
                        print("Failed to update button status")
                        return
                    }
                    
                    self.statusController.sendPush(title: "Shabazz is now open!", message: "Click on the coffee cup to let people know you are coming.")
                    
                    self.dismiss(animated: true, completion: nil)
                    
                })
                
            })
            
        }
    }
    
    func handleCancel()
    {
        dismiss(animated: true, completion: nil)
    }
    
    
}
