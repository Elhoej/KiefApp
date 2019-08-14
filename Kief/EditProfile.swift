//
//  EditProfile.swift
//  KiefApp
//
//  Created by Simon Elhoej Steinmejer on 4/27/17.
//  Copyright © 2017 Simon Elhoej Steinmejer. All rights reserved.
//

import UIKit
import Firebase

var presentController = 0 //int to determine which controller to go back to when asked to relogin

class EditProfile: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate
{
    let changePhoto: UIButton =
    {
        let button = UIButton(type: .system)
        button.setTitle("Change profile picture", for: .normal)
        button.isEnabled = false
        button.addTarget(self, action: #selector(handleChangePhoto), for: .touchUpInside)
        
        return button
    }()
    
    let editPhoto: UIButton =
    {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "plus_photo").withRenderingMode(.alwaysOriginal), for: .normal)
        button.layer.shadowOffset = CGSize(width: 1, height: 1)
        button.layer.shadowRadius = 2
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOpacity = 1
        button.layer.masksToBounds = false
        button.addTarget(self, action: #selector(handleChoosePhoto), for: .touchUpInside)
        
        return button
    }()
    
    let cancelEditProfile: UIButton =
    {
        let button = UIButton(type: .system)
        button.setTitle("Go back", for: .normal)
        button.backgroundColor = UIColor.rgb(red: 235, green: 216, blue: 164)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        button.layer.cornerRadius = 5
        button.setTitleColor(UIColor.rgb(red: 48, green: 42, blue: 35), for: .normal)
        button.addTarget(self, action: #selector(handleCancelProfile), for: .touchUpInside)
        
        return button
    }()
    
    let editEmail: UIButton =
    {
        let button = UIButton(type: .system)
        button.setTitle("Change email", for: .normal)
        button.setTitleColor(UIColor.rgb(red: 235, green: 216, blue: 164), for: .normal)
        button.backgroundColor = UIColor.rgb(red: 48, green: 42, blue: 35)
        button.layer.cornerRadius = 5
        button.addTarget(self, action: #selector(handleChangeEmail), for: .touchUpInside)
        
        return button
    }()
    
    let editUsername: UIButton =
    {
        let button = UIButton(type: .system)
        button.setTitle("Change username", for: .normal)
        button.setTitleColor(UIColor.rgb(red: 235, green: 216, blue: 164), for: .normal)
        button.backgroundColor = UIColor.rgb(red: 48, green: 42, blue: 35)
        button.layer.cornerRadius = 5
        button.addTarget(self, action: #selector(handleChangeUsername), for: .touchUpInside)
        
        return button
    }()
    
    let editPassword: UIButton =
    {
        let button = UIButton(type: .system)
        button.setTitle("Change password", for: .normal)
        button.setTitleColor(UIColor.rgb(red: 235, green: 216, blue: 164), for: .normal)
        button.backgroundColor = UIColor.rgb(red: 48, green: 42, blue: 35)
        button.layer.cornerRadius = 5
        button.addTarget(self, action: #selector(handleChangePassword), for: .touchUpInside)
        
        return button
    }()
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        setupBackground()

        view.addSubview(editPhoto)
        editPhoto.anchor(top: view.topAnchor, left: nil, bottom: nil, right: nil, paddingTop: 40, paddingLeft: 0, paddingRight: 0, paddingBottom: 0, width: 140, height: 140)
        editPhoto.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
        view.addSubview(changePhoto)
        changePhoto.anchor(top: editPhoto.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 5, paddingLeft: 40, paddingRight: 40, paddingBottom: 0, width: 0, height: 0)
        
        setupElements()
        
        view.addSubview(cancelEditProfile)
        
        cancelEditProfile.anchor(top: nil, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, paddingTop: 0, paddingLeft: 20, paddingRight: 20, paddingBottom: -40, width: 0, height: 50)
    }
    
    fileprivate func setupElements()
    {
        let stackView = UIStackView(arrangedSubviews: [editUsername, editEmail, editPassword])
        
        stackView.distribution = .fillEqually
        stackView.axis = .vertical
        stackView.spacing = 10
    
        view.addSubview(stackView)
        
        stackView.anchor(top: changePhoto.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 20, paddingLeft: 20, paddingRight: 20, paddingBottom: 0, width: 0, height: 200)
    }
    
    func setupBackground()
    {
        UIGraphicsBeginImageContext(self.view.frame.size)
        UIImage(named: "baggrund")?.draw(in: self.view.bounds)
        let image: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        view.backgroundColor = UIColor(patternImage: image)
    }
    
    func handleChangeEmail()
    {
        let alertController = UIAlertController(title: "Enter a new email", message: nil, preferredStyle: .alert)
        
        alertController.addAction(UIAlertAction(title: "Confirm", style: .default, handler: { (_) in
        
        
        guard let emailField = alertController.textFields?[0].text else { return }
        guard let confirmField = alertController.textFields?[1].text else { return }
        
        if (emailField == confirmField)
        {
            do
            {
                FIRAuth.auth()?.currentUser?.updateEmail(emailField, completion: { (error: Error?) in
                    
                    if error == nil
                    {
                        print("Updated email successfully")
                        alertController.dismiss(animated: true, completion: nil)
                        let popUp = UIAlertController(title: nil, message: "You successfully updated your email!", preferredStyle: .alert)
                        popUp.addAction(UIAlertAction(title: "Okay", style: .default, handler: nil))
                        self.present(popUp, animated: true, completion: nil)
                    }
                    else
                    {
                        guard let errorCode = FIRAuthErrorCode(rawValue: error!._code) else { return }
                        if errorCode == FIRAuthErrorCode.errorCodeRequiresRecentLogin
                        {
                            presentController = 1
                            self.handleAuthUser()
                        }
                    }
                    
                })
            }
        }
        else
        {
            let popUp = UIAlertController(title: nil, message: "The entered emails does not match", preferredStyle: .alert)
            popUp.addAction(UIAlertAction(title: "Okay", style: .default, handler: nil))
            self.present(popUp, animated: true, completion: nil)
        }
            
        }))
        
        alertController.actions[0].isEnabled = false
        
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            
        alertController.addTextField(configurationHandler: { (textField : UITextField!) in
        textField.placeholder = "New email"
            textField.addTarget(self, action: #selector(self.handleTextFieldEdit), for: .editingChanged)
        })
            
        alertController.addTextField(configurationHandler: { (textField : UITextField!) in
        textField.placeholder = "Enter again"
            textField.addTarget(self, action: #selector(self.handleTextFieldEdit), for: .editingChanged)
        })
        
        present(alertController, animated: true, completion: nil)
        
        
    }
    
    func handleChangeUsername()
    {
        let alertController = UIAlertController(title: "Enter a new username", message: nil, preferredStyle: .alert)
        
        alertController.addAction(UIAlertAction(title: "Confirm", style: .default, handler: { (_) in
            
            
            guard let usernameField = alertController.textFields?[0].text else { return }
            guard let confirmField = alertController.textFields?[1].text else { return }
            
            if (usernameField == confirmField)
            {
                do
                {
                    

                    guard let uid = FIRAuth.auth()?.currentUser?.uid else { return }
                    
                    let values = ["username": usernameField]
                    
                    FIRDatabase.database().reference().child("users").child(uid).updateChildValues(values, withCompletionBlock: { (error: Error?, ref) in

                        if error == nil
                        {
                            print("Updated username successfully")
                            alertController.dismiss(animated: true, completion: nil)
                            let popUp = UIAlertController(title: nil, message: "You successfully updated your username", preferredStyle: .alert)
                            popUp.addAction(UIAlertAction(title: "Okay", style: .default, handler: nil))
                            self.present(popUp, animated: true, completion: nil)
                        }
                        else
                        {
                            guard let errorCode = FIRAuthErrorCode(rawValue: error!._code) else { return }
                            if errorCode == FIRAuthErrorCode.errorCodeRequiresRecentLogin
                            {
                                presentController = 3
                                self.handleAuthUser()
                            }
                        }
                        
                    })
                }
            }
            else
            {
                let popUp = UIAlertController(title: nil, message: "The entered usernames does not match", preferredStyle: .alert)
                popUp.addAction(UIAlertAction(title: "Okay", style: .default, handler: nil))
                self.present(popUp, animated: true, completion: nil)
            }
            
        }))
        
        alertController.actions[0].isEnabled = false
        
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        alertController.addTextField(configurationHandler: { (textField : UITextField!) in
            textField.placeholder = "New username"
            textField.addTarget(self, action: #selector(self.handleTextFieldEdit), for: .editingChanged)
        })
        
        alertController.addTextField(configurationHandler: { (textField : UITextField!) in
            textField.placeholder = "Enter again"
            textField.addTarget(self, action: #selector(self.handleTextFieldEdit), for: .editingChanged)
        })
        
        present(alertController, animated: true, completion: nil)
    }
    
    func handleChangePassword()
    {
        let alertController = UIAlertController(title: "Enter a new password", message: nil, preferredStyle: .alert)
        
        alertController.addAction(UIAlertAction(title: "Confirm", style: .default, handler: { (_) in
            
            
            guard let passwordField = alertController.textFields?[0].text else { return }
            guard let confirmField = alertController.textFields?[1].text else { return }
            
            if (passwordField == confirmField)
            {
                do
                {
                    FIRAuth.auth()?.currentUser?.updatePassword(passwordField, completion: { (error: Error?) in
                        
                        if error == nil
                        {
                            print("Updated password successfully")
                            alertController.dismiss(animated: true, completion: nil)
                            let popUp = UIAlertController(title: nil, message: "You successfully updated your password!", preferredStyle: .alert)
                            popUp.addAction(UIAlertAction(title: "Okay", style: .default, handler: nil))
                            self.present(popUp, animated: true, completion: nil)
                        }
                        else
                        {
                            guard let errorCode = FIRAuthErrorCode(rawValue: error!._code) else { return }
                            if errorCode == FIRAuthErrorCode.errorCodeRequiresRecentLogin
                            {
                                presentController = 2
                                self.handleAuthUser()
                            }
                        }
                        
                    })
                }
            }
            else
            {
                let popUp = UIAlertController(title: nil, message: "The entered passwords does not match", preferredStyle: .alert)
                popUp.addAction(UIAlertAction(title: "Okay", style: .default, handler: nil))
                self.present(popUp, animated: true, completion: nil)
            }
            
        }))
        
        alertController.actions[0].isEnabled = false
        
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        alertController.addTextField(configurationHandler: { (textField : UITextField!) in
            textField.placeholder = "New password"
            textField.isSecureTextEntry = true
            textField.addTarget(self, action: #selector(self.handleTextFieldEdit), for: .editingChanged)
        })
        

        
        alertController.addTextField(configurationHandler: { (textField : UITextField!) in
            textField.placeholder = "Enter again"
            textField.isSecureTextEntry = true
            textField.addTarget(self, action: #selector(self.handleTextFieldEdit(sender:)), for: .editingChanged)
        })
        
        present(alertController, animated: true, completion: nil)
    }
    
    
    func handleTextFieldEdit(sender: UITextField)
    {
        let alertController:UIAlertController = self.presentedViewController as! UIAlertController
        let textField: UITextField  = alertController.textFields![0]
        let confirmField: UITextField = alertController.textFields![1]
        let addAction: UIAlertAction = alertController.actions[0];
        
        if ((textField.text?.characters.count)! > 4 && (confirmField.text?.characters.count)! > 4)
        {
            addAction.isEnabled = true
        }
        else if ((textField.text?.characters.count)! <= 4 || (confirmField.text?.characters.count)! <= 4)
        {
            addAction.isEnabled = false
        }
    }
    
    func handleChoosePhoto()
    {
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.allowsEditing = true
        
        present(imagePickerController, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any])
    {
        if let editedImage = info["UIImagePickerControllerEditedImage"] as? UIImage
        {
            editPhoto.setImage(editedImage.withRenderingMode(.alwaysOriginal), for: .normal)
            changePhoto.isEnabled = true
        }
        else if let originalImage = info["UIImagePickerControllerOriginalImage"] as? UIImage
        {
            editPhoto.setImage(originalImage.withRenderingMode(.alwaysOriginal), for: .normal)
            changePhoto.isEnabled = true
        }
        editPhoto.layer.cornerRadius = 140 / 2
        editPhoto.layer.masksToBounds = true
        editPhoto.layer.borderColor = UIColor.black.cgColor
        editPhoto.layer.borderWidth = 3
        
        dismiss(animated: true, completion: nil)
    }
    
    func handleChangePhoto()
    {
        guard let uid = FIRAuth.auth()?.currentUser?.uid else { return }
        
        
        //Kode til at slette forrige profilbilled, men vidst ikke noedvaendigt da det bliver gjort
        //automatisk... er dog ikke hel sikker.
//        FIRDatabase.database().reference().child("users").child(uid).child("profileImageUrl").observeSingleEvent(of: .value, with: { (snapshot) in
//            print(snapshot.value ?? "")
//            
//            guard let oldUrl = snapshot.value as? String else { return }
//            
//            FIRStorage.storage().reference().child("profile_image").child(oldUrl).delete(completion: { (error: Error?) in
//                
//                if error == nil
//                {
//                    print("Successfully deleted old profile picture")
//                }
//                else
//                {
//                    print("Failed to delete old profile picture")
//                    return
//                }
//                
//            })
//        })
        
        guard let image = self.editPhoto.imageView?.image else { return }
        
        guard let uploadData = UIImageJPEGRepresentation(image, 0.3) else { return }
        
        let filename = NSUUID().uuidString
        
        let uploadTask = FIRStorage.storage().reference().child("profile_image").child(filename).put(uploadData, metadata: nil, completion: { (metadata, err) in
            
            if let err = err
            {
                print("Failed to upload profile image:", err)
                let popUp = UIAlertController(title: nil, message: "Failed to upload profile picture, please try again", preferredStyle: .alert)
                popUp.addAction(UIAlertAction(title: "Okay", style: .default, handler: nil))
                self.present(popUp, animated: true, completion: nil)
                return
            }
            guard let profileImageUrl = metadata?.downloadURL()?.absoluteString else { return }
            
            print("Successfully uploaded profile image", profileImageUrl)
            
            let values = ["profileImageUrl": profileImageUrl]
            
            FIRDatabase.database().reference().child("users").child(uid).updateChildValues(values, withCompletionBlock: { (error: Error?, ref) in
                
                if error == nil
                {
                    let popUp = UIAlertController(title: nil, message: "You successfully updated your profile picture!", preferredStyle: .alert)
                    popUp.addAction(UIAlertAction(title: "Okay", style: .default, handler: nil))
                    self.present(popUp, animated: true, completion: nil)
                }
                else
                {
                    guard let errorCode = FIRAuthErrorCode(rawValue: error!._code) else { return }
                    if errorCode == FIRAuthErrorCode.errorCodeRequiresRecentLogin
                    {
                        self.handleAuthUser()
                    }
                }
                
            })
        })
        
        uploadTask.observe(.progress) { (snapshot) in
            
            if let completedUnitCount = snapshot.progress?.completedUnitCount
            {
                let totalUnitCount = snapshot.progress?.totalUnitCount
                let byteCountFormatter = ByteCountFormatter()
                byteCountFormatter.allowedUnits = [.useKB]
                byteCountFormatter.countStyle = .file
                self.changePhoto.setTitle(byteCountFormatter.string(fromByteCount: completedUnitCount) + " / " + byteCountFormatter.string(fromByteCount: totalUnitCount!), for: .normal)
            }
        }
        
        uploadTask.observe(.success) { (snapshot) in
            
            self.changePhoto.setTitle("Change profile picture", for: .normal)
        }
    }
    
    //Alert controller til at logge ind for at confirme
    func handleAuthUser()
    {
        let alertController = UIAlertController(title: "For security reasons, please login and then enter the new credentials again", message: nil, preferredStyle: .alert)
        
        alertController.addAction(UIAlertAction(title: "Login", style: .default, handler: { (_) in
            
            guard let emailField = alertController.textFields?[0].text else { return }
            
            guard let passField = alertController.textFields?[1].text else { return }
            
            do
            {
                FIRAuth.auth()?.signIn(withEmail: emailField, password: passField, completion: { (user, error) in
                    
                    if error == nil
                    {
                        alertController.dismiss(animated: true, completion: nil)
                        
                        if (presentController == 1)
                        {
                            self.handleChangeEmail()
                            presentController = 0
                        }
                        else if (presentController == 2)
                        {
                            self.handleChangePassword()
                            presentController = 0
                        }
                        else if (presentController == 3)
                        {
                            self.handleChangeUsername()
                            presentController = 0
                        }
                    }
                    else
                    {
                        let popUp = UIAlertController(title: nil, message: "Failed to login, please try again", preferredStyle: .alert)
                        popUp.addAction(UIAlertAction(title: "Okay", style: .default, handler: nil))
                        self.present(popUp, animated: true, completion: nil)
                    }
                    
                })
            }
            
        }))
        
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        alertController.addTextField(configurationHandler: { (textField : UITextField!) in
            textField.placeholder = "Email"
        })
        
        alertController.addTextField(configurationHandler: { (textField : UITextField!) in
            textField.placeholder = "Password"
            textField.isSecureTextEntry = true
        })
        
        present(alertController, animated: true, completion: nil)

    }
    
        //ikke faerdig
    
    func handleCancelProfile()
    {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)

        alertController.addAction(UIAlertAction(title: "... Are you sure?", style: .destructive, handler:
            { (_) in
            
                do
                {
                    self.tabBarController?.tabBar.isHidden = false
                    guard let mainTabBarController = UIApplication.shared.keyWindow?.rootViewController as? MainTabBarController else { return }
                    mainTabBarController.setupViewControllers()
                    self.dismiss(animated: true, completion: nil)
                }
            
            }))
        
            alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
            present(alertController, animated: true, completion: nil)
    }
}




