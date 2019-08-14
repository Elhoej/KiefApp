//
//  CogwheelView.swift
//  KiefApp
//
//  Created by Simon Elhoej Steinmejer on 7/3/17.
//  Copyright © 2017 Simon Elhoej Steinmejer. All rights reserved.
//

import UIKit
import Firebase

class CogwheelView: UIView
{
    var userProfile: UserProfile?
    var memberList: MemberList?
    
    let logOutButton: UIButton =
    {
        let button = UIButton(type: .system)
        button.setTitle("Log Out", for: .normal)
        button.backgroundColor = UIColor.rgb(red: 235, green: 216, blue: 164)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        button.layer.cornerRadius = 5
        button.setTitleColor(UIColor.rgb(red: 48, green: 42, blue: 35), for: .normal)
        button.addTarget(self, action: #selector(handleLogOut), for: .touchUpInside)
        button.alpha = 0
        
        return button
    }()
    
    let editProfileButton: UIButton =
    {
        let button = UIButton(type: .system)
        button.setTitle("Edit Profile", for: .normal)
        button.backgroundColor = UIColor.rgb(red: 235, green: 216, blue: 164)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        button.layer.cornerRadius = 5
        button.setTitleColor(UIColor.rgb(red: 48, green: 42, blue: 35), for: .normal)
        button.addTarget(self, action: #selector(handleEditProfile), for: .touchUpInside)
        button.alpha = 0
        
        return button
    }()
    
    let closeButton: UIButton =
    {
        let button = UIButton(type: .system)
        button.setTitle("X", for: .normal)
        button.setTitleColor(UIColor.red, for: .normal)
        button.titleLabel?.textAlignment = .center
        button.addTarget(self, action: #selector(handleClose), for: .touchUpInside)
        button.alpha = 0
        
        return button
    }()
    
    let versionLabel: UILabel =
    {
        let label = UILabel()
        label.text = "v1.0.3"
        label.font = UIFont.systemFont(ofSize: 11)
        label.textColor = UIColor.rgb(red: 235, green: 216, blue: 164)
        label.textAlignment = .right
        label.alpha = 0
        
        return label
    }()
    
    override init(frame: CGRect)
    {
        super.init(frame: frame)
        
        backgroundColor = UIColor.rgb(red: 48, green: 42, blue: 35)
        tag = 1
        layer.cornerRadius = 5
        layer.masksToBounds = true
        
        addSubview(closeButton)
        addSubview(versionLabel)
        addSubview(editProfileButton)
        addSubview(logOutButton)
        
        closeButton.anchor(top: topAnchor, left: leftAnchor, bottom: nil, right: nil, paddingTop: 4, paddingLeft: 4, paddingRight: 0, paddingBottom: 0, width: 24, height: 24)
        
        versionLabel.anchor(top: nil, left: closeButton.rightAnchor, bottom: nil, right: rightAnchor, paddingTop: 0, paddingLeft: 5, paddingRight: 12, paddingBottom: 0, width: 0, height: 20)
        versionLabel.centerYAnchor.constraint(equalTo: closeButton.centerYAnchor).isActive = true
        
        editProfileButton.anchor(top: nil, left: leftAnchor, bottom: logOutButton.topAnchor, right: rightAnchor, paddingTop: 0, paddingLeft: 10, paddingRight: 10, paddingBottom: -10, width: 0, height: 50)
        logOutButton.anchor(top: nil, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, paddingTop: 0, paddingLeft: 10, paddingRight: 10, paddingBottom: -10, width: 0, height: 50)
    }
    
    func handleClose()
    {
        userProfile?.closeAnimation(cogwheelView: self)
    }
    
    func handleEditProfile()
    {
        let editProfileController = EditProfile()
        editProfileController.hidesBottomBarWhenPushed = true
        memberList?.navigationController?.pushViewController(editProfileController, animated: true)
    }
    
    func handleLogOut()
    {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        alertController.addAction(UIAlertAction(title: "Log Out", style: .destructive, handler: { (_) in
            
            do
            {
                try FIRAuth.auth()?.signOut() //proever at logge ud
                
                FIRMessaging.messaging().unsubscribe(fromTopic: "/topics/Kief")
                
                self.removeFromSuperview()
                let loginController = LoginController()
                let navController = UINavigationController(rootViewController: loginController)
                self.memberList?.present(navController, animated: true, completion: nil)
            }
            catch let signOutErr
            {
                print("Failed to sign out", signOutErr)
            }
            
            
        }))
        
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        self.memberList?.present(alertController, animated: true, completion: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
