//
//  MainTabBarController.swift
//  KiefApp
//
//  Created by Simon Elhoej Steinmejer on 4/16/17.
//  Copyright © 2017 Simon Elhoej Steinmejer. All rights reserved.
//

import UIKit
import Firebase

class MainTabBarController: UITabBarController
{
    var messages = [Message]()
    var badgeCount: Int = 0
    let launchedBefore = UserDefaults.standard.bool(forKey: "launchedBefore")
    var version: String = "v1.0.3"
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        tabBar.backgroundImage = UIImage.image(with: UIColor.rgb(red: 48, green: 42, blue: 35))
        
        if !launchedBefore
        {
            DispatchQueue.main.async
                {
                    let loginController = LoginController()
                    let navController = UINavigationController(rootViewController: loginController)
                    self.present(navController, animated: true, completion: nil)
                    UserDefaults.standard.set(true, forKey: "launchedBefore")
            }
            return
        }
        
        if FIRAuth.auth()?.currentUser == nil
        {
            DispatchQueue.main.async
            {
                let loginController = LoginController()
                let navController = UINavigationController(rootViewController: loginController)
                self.present(navController, animated: true, completion: nil)
            }
            return
        }
        
        observeMessages()
        
        setupViewControllers()
        
        retrieveFcmToken()
    
        checkForUpdate()
    }
    
    func checkForUpdate()
    {
        FIRDatabase.database().reference().child("version").observeSingleEvent(of: .value, with: { (snapshot) in
            
            if let serverVersion = snapshot.value as? String
            {
                if self.version != serverVersion
                {
                    let popUp = UIAlertController(title: nil, message: "There is a new version available, you will be redirected to download it.", preferredStyle: .alert)
                    popUp.addAction(UIAlertAction(title: "Okay", style: .default, handler:
                        { (_) in
                            
                            do
                            {
                                let url = URL(string: "http://www.kief.dk/app")!
                                if #available(iOS 10.0, *)
                                {
                                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                                } else
                                {
                                    UIApplication.shared.openURL(url)
                                }
                                self.dismiss(animated: true, completion: nil)
                            }
                    }))
                    
                    self.present(popUp, animated: true, completion: nil)
                }
                
            }
            
        }, withCancel: nil)
    }
    
    func retrieveFcmToken()
    {
        guard let uid = FIRAuth.auth()?.currentUser?.uid else { return }
        FIRDatabase.database().reference().child("users").child(uid).child("fcmToken").observeSingleEvent(of: .value, with: { (snapshot) in
            
            if let fcm = snapshot.value as? String
            {
                if fcm == "0"
                {
                    if let token = FIRInstanceID.instanceID().token()
                    {
                    FIRDatabase.database().reference().child("users").child(uid).updateChildValues(["fcmToken": token])
                    }
                }
            }
            
        }, withCancel: nil)
        
        if let token = FIRInstanceID.instanceID().token()
        {
            FIRDatabase.database().reference().child("users").child(uid).updateChildValues(["fcmToken": token])
        }
    }
    
    func observeMessages()
    {
        guard let uid = FIRAuth.auth()?.currentUser?.uid else { return }
        
        let ref = FIRDatabase.database().reference().child("user-messages").child(uid)

        ref.observe(.childAdded, with: { (snapshot) in
            
            let userId = snapshot.key
            
            FIRDatabase.database().reference().child("user-messages").child(uid).child(userId).observe(.childAdded, with: { (snapshot) in
                
                let messageId = snapshot.key
                
                self.fetchMessageWithMessageId(messageId: messageId)
                
            }, withCancel: nil)
            
        }, withCancel: nil)
        
    }
    
    private func fetchMessageWithMessageId(messageId: String)
    {
        let messageReference = FIRDatabase.database().reference().child("messages").child(messageId)
        
        messageReference.observeSingleEvent(of: .value, with: { (snapshot) in
            
            if let dictionary = snapshot.value as? [String: AnyObject]
            {
                let message = Message(dictionary: dictionary)
                
                if message.fromId != FIRAuth.auth()?.currentUser?.uid
                {
                    if message.didRead == "0"
                    {
                        self.badgeCount += 1
                        self.tabBar.items?[2].badgeValue = String(self.badgeCount)
                    }
                }
            }
            
        }, withCancel: nil)
    }

    
    func setupViewControllers()
    {
        
        let chatController = ChatController()
        let chatNavController = UINavigationController(rootViewController: chatController)
        chatController.mainTabBarController = self
        
        chatNavController.tabBarItem.image = #imageLiteral(resourceName: "tapbarChat")
        chatNavController.tabBarItem.selectedImage = #imageLiteral(resourceName: "tapbarChat")
//        chatNavController.tabBarItem.badgeValue = nil

        let statusPageController = StatusController(collectionViewLayout: UICollectionViewFlowLayout())
        let statusPageNavController = UINavigationController(rootViewController: statusPageController)
        statusPageController.mainTabBarController = self
        
        statusPageNavController.tabBarItem.image = #imageLiteral(resourceName: "megafon")
        statusPageNavController.tabBarItem.selectedImage = #imageLiteral(resourceName: "megafon")
        
        //userProfile
        let memberListController = MemberList(collectionViewLayout: UICollectionViewFlowLayout())
        let userProfileNavController = UINavigationController(rootViewController: memberListController)
        memberListController.mainTabBarController = self
        
        userProfileNavController.tabBarItem.image = #imageLiteral(resourceName: "tapbarProfile")
        userProfileNavController.tabBarItem.selectedImage = #imageLiteral(resourceName: "tapbarProfile")
        
        let forumController = ForumController()
        let forumNavController = UINavigationController(rootViewController: forumController)
        forumController.mainTabBarController = self
        
        forumNavController.tabBarItem.image = #imageLiteral(resourceName: "tapbarForum")
        forumNavController.tabBarItem.selectedImage = #imageLiteral(resourceName: "tapbarForum")
        
        tabBar.tintColor = UIColor.rgb(red: 235, green: 216, blue: 164)
        
        viewControllers = [userProfileNavController, statusPageNavController, chatNavController, forumNavController]
        
        guard let items = tabBar.items else { return }
        
        for item in items
        {
            //nedenstaaende values er padding fra top, venstre, bund og hoejre.
            //hvis du aendre top padding, skal du huske at minuse bund padding med samme value
            item.imageInsets = UIEdgeInsets(top: 5, left: 0, bottom: -5, right: 0)
        }
    }
}









