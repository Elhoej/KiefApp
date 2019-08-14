//
//  LoginController.swift
//  KiefApp
//
//  Created by Simon Elhoej Steinmejer on 4/19/17.
//  Copyright © 2017 Simon Elhoej Steinmejer. All rights reserved.
//

import UIKit
import Firebase

class LoginController: UIViewController
{
    //Kief logoet
    let kiefLogo: UIImageView =
    {
        let image = UIImageView(image: #imageLiteral(resourceName: "LoginLOGO"))
        return image
    }()
    
    //Quote label til som footnote
    let bokajQuote: UILabel =
    {
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: 400, height: 30))
        label.textAlignment = .center
        
        let attributedText = NSMutableAttributedString(string: "\"Snart tid til en kief app? Det gælder om at holde det moderne\"", attributes: [NSForegroundColorAttributeName: UIColor.rgb(red: 48, green: 42, blue: 35), NSFontAttributeName: UIFont.italicSystemFont(ofSize: 13)])
        attributedText.append(NSAttributedString(string: " - Bokaj 2012", attributes: [NSForegroundColorAttributeName: UIColor.rgb(red: 48, green: 42, blue: 35), NSFontAttributeName: UIFont.preferredFont(forTextStyle: .footnote)]))
        
        label.attributedText = attributedText
        label.numberOfLines = 2
        
        return label
    }()
    
    let emailTextField: UITextField =
    {
        let tf = UITextField()
        tf.placeholder = "Email"
        tf.placeHolderTextColor = UIColor(red: 235/255, green: 216/255, blue: 164/255, alpha: 0.3)
        tf.textColor = UIColor.rgb(red: 235, green: 216, blue: 164)
        tf.backgroundColor = UIColor.rgb(red: 48, green: 42, blue: 35)
        tf.borderStyle = .roundedRect
        tf.font = UIFont.systemFont(ofSize: 14)
        tf.keyboardType = .emailAddress
        tf.addTarget(self, action: #selector(handleTextInputChange), for: .editingChanged)
        
        return tf
    }()
    
    let passwordTextField: UITextField =
    {
        let tf = UITextField()
        tf.placeholder = "Password"
        tf.placeHolderTextColor = UIColor(red: 235/255, green: 216/255, blue: 164/255, alpha: 0.3)
        tf.textColor = UIColor.rgb(red: 235, green: 216, blue: 164)
        tf.isSecureTextEntry = true
        tf.backgroundColor = UIColor.rgb(red: 48, green: 42, blue: 35)
        tf.borderStyle = .roundedRect
        tf.font = UIFont.systemFont(ofSize: 14)
        tf.addTarget(self, action: #selector(handleTextInputChange), for: .editingChanged)
        
        return tf
    }()
    
    let logInButton: UIButton =
    {
        let button = UIButton(type: .system)
        button.setTitle("Log In", for: .normal)
        button.backgroundColor = UIColor(red: 235/255, green: 216/255, blue: 164/255, alpha: 0.5)
        button.layer.cornerRadius = 5
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        button.setTitleColor(UIColor.rgb(red: 48, green: 42, blue: 35), for: .normal)
        button.isEnabled = false
        button.addTarget(self, action: #selector(handleLogIn), for: .touchUpInside)
        
        return button
    }()
    
    func handleTextInputChange()
    {
        let isFormValid = emailTextField.text?.characters.count ?? 4 > 4 && passwordTextField.text?.characters.count ?? 3 > 3
        
        if isFormValid
        {
            logInButton.isEnabled = true
            logInButton.backgroundColor = UIColor.rgb(red: 235, green: 216, blue: 164)
        }
        else
        {
            logInButton.isEnabled = false
            logInButton.backgroundColor = UIColor(red: 235/255, green: 216/255, blue: 164/255, alpha: 0.5)
        }
    }
    
    func handleLogIn()
    {
        guard let email = emailTextField.text else { return }
        guard let password = passwordTextField.text else { return }
        
        FIRAuth.auth()?.signIn(withEmail: email, password: password, completion: { (user, err) in
            
            if let err = err
            {
                guard let errorCode = FIRAuthErrorCode(rawValue: err._code) else { return }
                
                if errorCode == FIRAuthErrorCode.errorCodeWrongPassword
                {
                    print("Wrong password:", err)
                    let popUp = UIAlertController(title: nil, message: "You have entered a wrong password", preferredStyle: .alert)
                    popUp.addAction(UIAlertAction(title: "Okay", style: .default, handler: nil))
                    self.present(popUp, animated: true, completion: nil)
                    return
                }
                else
                {
                    print("Failed to sign in with email:", err)
                    let popUp = UIAlertController(title: nil, message: "Something unexpected happened... Please try again!", preferredStyle: .alert)
                    popUp.addAction(UIAlertAction(title: "Okay", style: .default, handler: nil))
                    self.present(popUp, animated: true, completion: nil)
                    return
                }
            }
            
            FIRMessaging.messaging().subscribe(toTopic: "/topics/Kief")
            
            print("Successfully logged in with user:", user?.uid ?? "")
            
            //Resetter alle view controllers naar man logger ind
            //kalder mainTabBarController som rootcontroller, as MainTabBarController
            guard let mainTabBarController = UIApplication.shared.keyWindow?.rootViewController as? MainTabBarController else { return }
            
            //Loader setupViewControllers() igen for at resette
            mainTabBarController.setupViewControllers()
            
            self.dismiss(animated: true, completion: nil)
        })
    }
    
    let signUpButton: UIButton =
    {
        let button = UIButton(type: .system)
        button.setTitle("Dont have an account?   Sign Up.", for: .normal)
        button.addTarget(self, action: #selector(handleShowSignUp), for: .touchUpInside)
        
        return button
    }()
    
    func handleShowSignUp()
    {
        let signUpController = SignUpController()
        
        navigationController?.pushViewController(signUpController, animated: true)
    }
    
    fileprivate func setupStackView()
    {
        let stackView = UIStackView(arrangedSubviews: [emailTextField, passwordTextField, logInButton])
        
        stackView.distribution = .fillEqually
        stackView.axis = .vertical
        stackView.spacing = 10
        
        view.addSubview(stackView)
        
        stackView.anchor(top: kiefLogo.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 20, paddingLeft: 20, paddingRight: 20, paddingBottom: 0, width: 0, height: 150)
    }
    
    var kiefLogoTopAnchor: NSLayoutConstraint?
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        navigationController?.isNavigationBarHidden = true
        
        self.hideKeyboardWhenTappedAround()
        
        setupKeyboardObservers()
        
        setupBackground()
        
        view.addSubview(kiefLogo) //loader kief logo
        
        view.addSubview(bokajQuote) //loader quote
        
        setupStackView()
        
        view.addSubview(signUpButton)
        signUpButton.anchor(top: logInButton.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingRight: 0, paddingBottom: 0, width: 0, height: 50)
        
        //Kief logos position

        kiefLogo.anchor(top: nil, left: nil, bottom: nil, right: nil, paddingTop: 0, paddingLeft: 0, paddingRight: 0, paddingBottom: 0, width: 180, height: 180)
        kiefLogo.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        kiefLogoTopAnchor = kiefLogo.topAnchor.constraint(equalTo: view.topAnchor, constant: 40)
        kiefLogoTopAnchor?.isActive = true

        
        //Bokajs quote position
        bokajQuote.anchor(top: nil, left: nil, bottom: view.bottomAnchor, right: nil, paddingTop: 0, paddingLeft: 0, paddingRight: 0, paddingBottom: -20, width: 300, height: 50)
        bokajQuote.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
    }
    
    func setupKeyboardObservers()
    {
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    func handleKeyboardWillShow(_ notification: Notification)
    {
        let keyboardDuration = (notification.userInfo?[UIKeyboardAnimationDurationUserInfoKey] as AnyObject).doubleValue
        
        kiefLogoTopAnchor?.constant = -100
        UIView.animate(withDuration: keyboardDuration!, animations:
            {
                self.view.layoutIfNeeded()
        })
    }
    
    func handleKeyboardWillHide(_ notification: Notification)
    {
        //        let keyboardFrame = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as AnyObject).cgRectValue
        let keyboardDuration = (notification.userInfo?[UIKeyboardAnimationDurationUserInfoKey] as AnyObject).doubleValue
        
        kiefLogoTopAnchor?.constant = 40
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
    
    
}
