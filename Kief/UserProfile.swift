//
//  UserProfile.swift
//  KiefApp
//
//  Created by Simon Elhoej Steinmejer on 4/24/17.
//  Copyright © 2017 Simon Elhoej Steinmejer. All rights reserved.
//

import UIKit
import Firebase

class UserProfile: UIView
{
    var mainTabBarController: MainTabBarController?
    var memberList: MemberList?
    
    var user: User?
    {
        didSet
        {
            setupProfileImage()
            usernameLabel.text = user?.username
            emailLabel.text = FIRAuth.auth()?.currentUser?.email
        }
    }
    
    fileprivate func fetchUser()
    {
        guard let uid = FIRAuth.auth()?.currentUser?.uid else { return }
        
        FIRDatabase.database().reference().child("users").child(uid).observeSingleEvent(of: .value, with: { (snapshot) in
            print(snapshot.value ?? "")
            
            guard let dictionary = snapshot.value as? [String: Any] else { return }
            
            self.user = User(dictionary: dictionary)
            
        }) { (err) in
            print("Failed to fetch user:", err)
        }
    }
    
    
    let profileImageView: UIImageView =
    {
        let iv = UIImageView()
        
        return iv
    }()
    
    let usernameLabel: UILabel =
    {
        let label = UILabel()
        label.text = "username"
        label.textAlignment = .center
        label.font = UIFont.boldSystemFont(ofSize: 14)
        return label
    }()
    
    let usernameLabelPlaceholder: UILabel =
    {
        let label = UILabel()
        label.text = "username"
        label.textAlignment = .center
        label.font = UIFont.boldSystemFont(ofSize: 11)
        label.textColor = UIColor.init(red: 48/255, green: 42/255, blue: 35/255, alpha: 0.5)
        return label
    }()
    
    let emailLabel: UILabel =
    {
        let label = UILabel()
        label.text = "email"
        label.textAlignment = .center
        label.font = UIFont.boldSystemFont(ofSize: 14)
        return label
    }()
    
    let emailLabelPlaceholder: UILabel =
    {
        let label = UILabel()
        label.text = "email"
        label.textAlignment = .center
        label.font = UIFont.boldSystemFont(ofSize: 11)
        label.textColor = UIColor.init(red: 48/255, green: 42/255, blue: 35/255, alpha: 0.5)
        return label
    }()
    
    let cogwheelButton: UIButton =
    {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "gear").withRenderingMode(.alwaysOriginal), for: .normal)
        button.addTarget(self, action: #selector(handleCogwheel), for: .touchUpInside)
        
        return button
    }()
    
    let memberListLabel: UILabel =
    {
        let label = UILabel()
        label.text = "MEMBER LIST"
        label.textAlignment = .center
        label.font = UIFont(name: "Graduate-Regular", size: 14)
        label.textColor = UIColor.rgb(red: 48, green: 42, blue: 35)
        
        return label
    }()

    override init(frame: CGRect)
    {
        super.init(frame: frame)
        
        setupBackground()
        
        fetchUser()
        setupProfileImage()
        addSubview(profileImageView)
        profileImageView.anchor(top: topAnchor, left: leftAnchor, bottom: nil, right: nil, paddingTop: 40, paddingLeft: 20, paddingRight: 0, paddingBottom: 0, width: 120, height: 120)
        profileImageView.layer.cornerRadius = 120 / 2
        profileImageView.layer.borderWidth = 1
        profileImageView.layer.borderColor = UIColor.black.cgColor
        profileImageView.clipsToBounds = true
        
        setupHeader()
    }
    
    func setupBackground()
    {
        UIGraphicsBeginImageContext(self.frame.size)
        UIImage(named: "headerBaggrund")?.draw(in: self.bounds)
        let image: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        backgroundColor = UIColor(patternImage: image)
    }
    
    func handleCogwheel()
    {
        let cogwheelView = CogwheelView(frame: CGRect(x: cogwheelButton.center.x - 20, y: cogwheelButton.center.y, width: 0, height: 0))
        cogwheelView.userProfile = self
        cogwheelView.memberList = memberList
    
        if let viewWithTag = self.viewWithTag(1)
        {
            closeAnimation(cogwheelView: viewWithTag as! CogwheelView)
            return
        }
        
        addSubview(cogwheelView)
        cogwheelViewOpenAnimation(cogwheelView: cogwheelView)
    }
    
    func cogwheelViewOpenAnimation(cogwheelView: CogwheelView)
    {
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseIn, animations: {
            
            cogwheelView.frame = CGRect(x: self.cogwheelButton.center.x - 220, y: self.cogwheelButton.center.y, width: 200, height: 150)

            
        }, completion: nil)

        UIView.animate(withDuration: 0.1, delay: 0.2, options: .curveLinear, animations: {
            
            cogwheelView.logOutButton.alpha = 1
            cogwheelView.editProfileButton.alpha = 1
            cogwheelView.closeButton.alpha = 1
            cogwheelView.versionLabel.alpha = 1
            
        }, completion: nil)
    }
    
    func closeAnimation(cogwheelView: CogwheelView)
    {
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
            
            cogwheelView.frame = CGRect(x: self.cogwheelButton.center.x - 20, y: self.cogwheelButton.center.y, width: 0, height: 0)
            cogwheelView.logOutButton.alpha = 0
            cogwheelView.editProfileButton.alpha = 0
            cogwheelView.closeButton.alpha = 0
            cogwheelView.versionLabel.alpha = 0
            
        }, completion: { (completed: Bool) in
            
            cogwheelView.removeFromSuperview()
        })
    }
    
    func handleSwipe(sender: UISwipeGestureRecognizer)
    {
        mainTabBarController?.selectedIndex += 1
    }
    
    fileprivate func setupProfileImage()
    {
        if let profileImageUrl = user?.profileImageUrl
        {
            self.profileImageView.loadImageUsingCacheWithUrlString(profileImageUrl)
        }
    }
    
    fileprivate func setupHeader()
    {
        let stackViewUsername = UIStackView(arrangedSubviews: [usernameLabelPlaceholder, usernameLabel])
        
        stackViewUsername.distribution = .fillEqually
        stackViewUsername.axis = .vertical
        stackViewUsername.spacing = 1
        
        addSubview(stackViewUsername)
        
        stackViewUsername.anchor(top: topAnchor, left: nil, bottom: nil, right: rightAnchor, paddingTop: 57, paddingLeft: 0, paddingRight: 20, paddingBottom: 0, width: 150, height: 40)
        
        let stackViewEmail = UIStackView(arrangedSubviews: [emailLabelPlaceholder, emailLabel])
        
        stackViewEmail.distribution = .fillEqually
        stackViewEmail.axis = .vertical
        stackViewEmail.spacing = 1
        
        addSubview(stackViewEmail)
        
        stackViewEmail.anchor(top: stackViewUsername.bottomAnchor, left: nil, bottom: nil, right: rightAnchor, paddingTop: 5, paddingLeft: 0, paddingRight: 20, paddingBottom: 0, width: 150, height: 40)
        
        addSubview(cogwheelButton)
        
        cogwheelButton.anchor(top: topAnchor, left: nil, bottom: nil, right: rightAnchor, paddingTop: 22, paddingLeft: 0, paddingRight: 10, paddingBottom: -4, width: 30, height: 30)
        
        addSubview(memberListLabel)
        
        memberListLabel.anchor(top: nil, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingRight: 0, paddingBottom: 0, width: 0, height: 30)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

















