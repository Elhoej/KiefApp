//
//  ViewController.swift
//  KiefApp
//
//  Created by Simon Elhoej Steinmejer on 4/15/17.
//  Copyright © 2017 Simon Elhoej Steinmejer. All rights reserved.
//

import UIKit
import Firebase

class SignUpController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate
{
    let signInButton: UIButton =
    {
        let button = UIButton(type: .system)
        button.setTitle("Already have an account?   Sign In.", for: .normal)
        button.addTarget(self, action: #selector(handleViewSignIn), for: .touchUpInside)
        
        return button
    }()
    
    func handleViewSignIn()
    {
        let signInController = LoginController()
        navigationController?.pushViewController(signInController, animated: true)
    }
    
    //Vaelg billed knap
    let plusPhotoButton: UIButton =
    {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "plus_photo_grey").withRenderingMode(.alwaysOriginal), for: .normal)
        button.layer.masksToBounds = false
        button.isEnabled = false
        button.addTarget(self, action: #selector(handlePlusPhoto), for: .touchUpInside)
        
        return button
    }()
    
    func handlePlusPhoto()
    {
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.allowsEditing = true

        present(imagePickerController, animated: true, completion: nil)
    }
    
    //Funktion til at vaelge et billed
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any])
    {
        if let editedImage = info["UIImagePickerControllerEditedImage"] as? UIImage
        {
            plusPhotoButton.setImage(editedImage.withRenderingMode(.alwaysOriginal), for: .normal)
        }
        else if let originalImage = info["UIImagePickerControllerOriginalImage"] as? UIImage
        {
            plusPhotoButton.setImage(originalImage.withRenderingMode(.alwaysOriginal), for: .normal)
        }
        //goer billedet rundt med en radius der svarer til halvdelen af billedets bredte
        plusPhotoButton.layer.cornerRadius = plusPhotoButton.frame.width / 2
        plusPhotoButton.layer.masksToBounds = true
        //laver et sort omrids
        plusPhotoButton.layer.borderColor = UIColor.black.cgColor
        plusPhotoButton.layer.borderWidth = 3
    
        dismiss(animated: true, completion: nil)
    }
    
    
    let emailTextField: UITextField =
    {
        let tf = UITextField() //constructor
        tf.placeholder = "Email" //laver placeholder text
        tf.placeHolderTextColor = UIColor(red: 235/255, green: 216/255, blue: 164/255, alpha: 0.3)
        tf.textColor = UIColor.rgb(red: 235, green: 216, blue: 164)
        tf.backgroundColor = UIColor.rgb(red: 48, green: 42, blue: 35) //laver background color
        tf.borderStyle = .roundedRect //laver rounded borders
        tf.font = UIFont.systemFont(ofSize: 14) //aendre font for texten
        tf.keyboardType = .emailAddress
        tf.addTarget(self, action: #selector(handleTextInputChange), for: .editingChanged) //action for color change
        
        return tf
    }()
    
    let usernameTextField: UITextField =
    {
        let tf = UITextField()
        tf.placeholder = "Username"
        tf.placeHolderTextColor = UIColor(red: 235/255, green: 216/255, blue: 164/255, alpha: 0.3)
        tf.textColor = UIColor.rgb(red: 235, green: 216, blue: 164)
        tf.backgroundColor = UIColor.rgb(red: 48, green: 42, blue: 35)
        tf.borderStyle = .roundedRect
        tf.font = UIFont.systemFont(ofSize: 14)
        tf.addTarget(self, action: #selector(handleTextInputChange), for: .editingChanged)

        return tf
    }()
    
    let passwordTextField: UITextField =
    {
        let tf = UITextField()
        tf.placeholder = "Password"
        tf.isSecureTextEntry = true
        tf.placeHolderTextColor = UIColor(red: 235/255, green: 216/255, blue: 164/255, alpha: 0.3)
        tf.textColor = UIColor.rgb(red: 235, green: 216, blue: 164)
        tf.backgroundColor = UIColor.rgb(red: 48, green: 42, blue: 35)
        tf.borderStyle = .roundedRect
        tf.font = UIFont.systemFont(ofSize: 14)
        
        //Kalder handeTextInputChange naar der er sket en aendring i en textfield.
        tf.addTarget(self, action: #selector(handleTextInputChange), for: .editingChanged)
        
        return tf
    }()
    
    let snapchatTextField: UITextField =
    {
        let tf = UITextField()
        tf.placeholder = "Snapchat username"
        tf.placeHolderTextColor = UIColor(red: 235/255, green: 216/255, blue: 164/255, alpha: 0.3)
        tf.textColor = UIColor.rgb(red: 235, green: 216, blue: 164)
        tf.backgroundColor = UIColor.rgb(red: 48, green: 42, blue: 35)
        tf.borderStyle = .roundedRect
        tf.font = UIFont.systemFont(ofSize: 14)
        
        return tf
    }()
    
    //Funktion til at skifte singupknappens farve og aktivere den
    func handleTextInputChange()
    {
        let isFormValid = emailTextField.text?.characters.count ?? 4 > 4 && usernameTextField.text?.characters.count ?? 0 > 0 && passwordTextField.text?.characters.count ?? 3 > 3
        
        if isFormValid
        {
            plusPhotoButton.setImage(#imageLiteral(resourceName: "plus_photo").withRenderingMode(.alwaysOriginal), for: .normal)
            plusPhotoButton.layer.shadowOffset = CGSize(width: 1, height: 1)
            plusPhotoButton.layer.shadowRadius = 2
            plusPhotoButton.layer.shadowColor = UIColor.black.cgColor
            plusPhotoButton.layer.shadowOpacity = 1
            plusPhotoButton.isEnabled = true
            signUpButton.isEnabled = true
            signUpButton.backgroundColor = UIColor.rgb(red: 235, green: 216, blue: 164)
        }
        else
        {
            plusPhotoButton.setImage(#imageLiteral(resourceName: "plus_photo_grey").withRenderingMode(.alwaysOriginal), for: .normal)
            plusPhotoButton.layer.shadowOffset = CGSize(width: 0, height: 0)
            plusPhotoButton.layer.shadowRadius = 0
            plusPhotoButton.layer.shadowOpacity = 0
            plusPhotoButton.isEnabled = false
            signUpButton.isEnabled = false
            signUpButton.backgroundColor = UIColor(red: 235/255, green: 216/255, blue: 164/255, alpha: 0.5)
        }
    }
    
    let signUpButton: UIButton =
    {
        let button = UIButton(type: .system)
        button.setTitle("Sign Up", for: .normal)
        button.backgroundColor = UIColor(red: 235/255, green: 216/255, blue: 164/255, alpha: 0.5)
        button.layer.cornerRadius = 5
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        button.setTitleColor(UIColor.rgb(red: 48, green: 42, blue: 35), for: .normal)
        
        //Action til naar brugeren trykker paa signup knappen
        button.addTarget(self, action: #selector(handleSignUp), for: .touchUpInside)
        
        button.isEnabled = false //disabler knappen indtil textfields er udfyldte
        
        return button
    }()
    
    //Funktion til at logge ind.
    func handleSignUp()
    {
        //sikre at brugeren indtaster noget i alle textfields
        guard let email = emailTextField.text, email.characters.count > 4 else { return }
        guard let username = usernameTextField.text, username.characters.count > 1 else { return }
        guard let password = passwordTextField.text, password.characters.count > 3 else { return }
        guard let snapchat = snapchatTextField.text, snapchat.characters.count > 1 else { return }
        
        //Laver en ny bruger med strings fra textfields
        FIRAuth.auth()?.createUser(withEmail: email, password: password, completion: { (user: FIRUser?, error: Error?) in
            
            if let err = error
            {
                print("Failed to create user:", err)
                let popUp = UIAlertController(title: nil, message: "Something unexpected happened... Please try again!", preferredStyle: .alert)
                popUp.addAction(UIAlertAction(title: "Okay", style: .default, handler: nil))
                self.present(popUp, animated: true, completion: nil)
                return
            }
            print("Successfully created user:", user?.uid ?? "")
            
            guard let image = self.plusPhotoButton.imageView?.image else { return }
            
            guard let uploadData = UIImageJPEGRepresentation(image, 0.3) else { return }
            
            //Gemmer profil billed som profile_image
            let filename = NSUUID().uuidString
            let uploadTask = FIRStorage.storage().reference().child("profile_image").child(filename).put(uploadData, metadata: nil, completion: { (metadata, err) in
                
                if let err = err
                {
                    print("Failed to upload profile image:", err)
                    let popUp = UIAlertController(title: nil, message: "Couldn't upload profile image, please check your connection", preferredStyle: .alert)
                    popUp.addAction(UIAlertAction(title: "Okay", style: .default, handler: nil))
                    self.present(popUp, animated: true, completion: nil)
                    return
                }
                guard let profileImageUrl = metadata?.downloadURL()?.absoluteString else { return }
                
                print("Successfully uploaded profile image", profileImageUrl)
                
                //Gemmer username i database
                guard let uid = user?.uid else { return }
                
                let token = FIRInstanceID.instanceID().token()
                
                let dictionaryValues = ["username": username, "profileImageUrl": profileImageUrl, "snapchat": snapchat, "jokke": false, "tokommanul": false, "unreadMessages": 0, "fcmToken": token ?? "0"] as [String : Any]
                let values = [uid: dictionaryValues]
                
                FIRDatabase.database().reference().child("users").updateChildValues(values, withCompletionBlock: { (err, ref) in
                    
                    if let err = err
                    {
                        print("Failed to save user info into db:", err)
                        return
                    }
                    
                    print("Successfully saved user info into db")
                    
                    FIRMessaging.messaging().subscribe(toTopic: "/topics/Kief")
                    
                    let popUp = UIAlertController(title: nil, message: "You have successfully created your account", preferredStyle: .alert)
                    popUp.addAction(UIAlertAction(title: "Muy bien!", style: .default, handler:
                    { (_) in
                        
                        do
                        {
                            guard let mainTabBarController = UIApplication.shared.keyWindow?.rootViewController as? MainTabBarController else { return }
                            
                            mainTabBarController.setupViewControllers()
                            
                            self.dismiss(animated: true, completion: nil)
                        }
                    }))
                    
                    self.present(popUp, animated: true, completion: nil)
                })
            })
            
            uploadTask.observe(.progress) { (snapshot) in
                
                if let completedUnitCount = snapshot.progress?.completedUnitCount
                {
                    let totalUnitCount = snapshot.progress?.totalUnitCount
                    let byteCountFormatter = ByteCountFormatter()
                    byteCountFormatter.allowedUnits = [.useKB]
                    byteCountFormatter.countStyle = .file
                    self.signUpButton.setTitle(byteCountFormatter.string(fromByteCount: completedUnitCount) + " / " + byteCountFormatter.string(fromByteCount: totalUnitCount!), for: .normal)
                }
            }
            
            uploadTask.observe(.success) { (snapshot) in
                
                self.signUpButton.setTitle("Sign Up", for: .normal)
            }
            
        })
    }
    
    //Swifts version of Main()
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        setupBackground()
        
        setupKeyboardObservers()
        
        self.hideKeyboardWhenTappedAround()
    
        view.addSubview(plusPhotoButton) //Loader billed knappen
        setupInputFields() //Loader textfields og signup knap

        uiConstraints() //resten af constraints f.eks center X & Y axis constraints
        //altid load addSubview foer du loader constraints
    }
    
    func setupKeyboardObservers()
    {
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    func handleKeyboardWillShow(_ notification: Notification)
    {
        let keyboardDuration = (notification.userInfo?[UIKeyboardAnimationDurationUserInfoKey] as AnyObject).doubleValue
        
        plusPhotoButtonTopViewAnchor?.constant = -100
        UIView.animate(withDuration: keyboardDuration!, animations:
        {
            self.view.layoutIfNeeded()
        })
    }

    func handleKeyboardWillHide(_ notification: Notification)
    {
//        let keyboardFrame = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as AnyObject).cgRectValue
        let keyboardDuration = (notification.userInfo?[UIKeyboardAnimationDurationUserInfoKey] as AnyObject).doubleValue
        
        plusPhotoButtonTopViewAnchor?.constant = 40
        UIView.animate(withDuration: keyboardDuration!, animations:
        {
            self.view.layoutIfNeeded()
        })
    }
    
    override func viewDidDisappear(_ animated: Bool)
    {
        super.viewDidDisappear(animated)
        
        NotificationCenter.default.removeObserver(self)
    }
    
    func setupBackground()
    {
        UIGraphicsBeginImageContext(self.view.frame.size)
        UIImage(named: "baggrund")?.draw(in: self.view.bounds)
        let image: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        view.backgroundColor = UIColor(patternImage: image)
    }
    
    var plusPhotoButtonTopViewAnchor: NSLayoutConstraint?
    
    //Stackview for textfields og signup button
    fileprivate func setupInputFields()
    {

        let stackView = UIStackView(arrangedSubviews: [emailTextField, usernameTextField, snapchatTextField ,passwordTextField, signUpButton, signInButton])

        stackView.distribution = .fillEqually
        stackView.axis = .vertical
        stackView.spacing = 10
            
        view.addSubview(stackView)
        
        stackView.anchor(top: plusPhotoButton.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 30, paddingLeft: 40, paddingRight: 40, paddingBottom: 0, width: 0, height: 290)
    }

     fileprivate func uiConstraints()
    {
        //Vaelg billed knaps position
        plusPhotoButton.anchor(top: nil, left: nil, bottom: nil, right: nil, paddingTop: 40, paddingLeft: 0, paddingRight: 0, paddingBottom: 0, width: 140, height: 140)
        plusPhotoButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        plusPhotoButtonTopViewAnchor = plusPhotoButton.topAnchor.constraint(equalTo: view.topAnchor, constant: 40)
        plusPhotoButtonTopViewAnchor?.isActive = true
    }
}





















