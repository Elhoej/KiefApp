//
//  MemberList.swift
//  KiefApp
//
//  Created by Simon Elhoej Steinmejer on 7/3/17.
//  Copyright © 2017 Simon Elhoej Steinmejer. All rights reserved.
//

import UIKit
import Firebase

class MemberList: UICollectionViewController, UICollectionViewDelegateFlowLayout, UIGestureRecognizerDelegate
{
    var mainTabBarController: MainTabBarController?
    let cellId = "cellId"
    var users = [User]()
    var timer: Timer?
    
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(false)
        self.tabBarController?.tabBar.isHidden = false
        navigationController?.isNavigationBarHidden = true
        
    }
    
    let activityIndicatorView: UIActivityIndicatorView =
    {
        let aiv = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
        aiv.translatesAutoresizingMaskIntoConstraints = false
        aiv.hidesWhenStopped = true
        
        return aiv
    }()
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
//        viewWillAppear(false)
        
        setupBackground()
        
        collectionView?.backgroundColor = UIColor.clear
        collectionView?.register(MemberCell.self, forCellWithReuseIdentifier: cellId)
        collectionView?.contentInset = UIEdgeInsetsMake(180, 3, 8, 3)
        collectionView?.scrollIndicatorInsets = UIEdgeInsetsMake(180, 0, 8, 0)
        collectionView?.alwaysBounceVertical = false
        
        let userProfile = UserProfile(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: 200))
        view.addSubview(userProfile)
        userProfile.memberList = self
        
        collectionView?.addSubview(activityIndicatorView)
        activityIndicatorView.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: 75).isActive = true
        activityIndicatorView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
        activityIndicatorView.startAnimating()
        
        let gesture = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe))
        gesture.direction = UISwipeGestureRecognizerDirection.left
        view.addGestureRecognizer(gesture)
        
        let longTap = UILongPressGestureRecognizer(target: self, action: #selector(handleZoomIn))
        longTap.minimumPressDuration = 0.5
        longTap.delaysTouchesBegan = true
        longTap.delegate = self
        collectionView?.addGestureRecognizer(longTap)
        
        fetchUser()
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    {
        return users.count
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize
    {
        let width = (view.frame.width - 12) / 3
        return CGSize(width: width, height: width)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat
    {
        return 3
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat
    {
        return 3
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> MemberCell
    {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! MemberCell
        
        let user = users[indexPath.row]
        
        if user.profileImageUrl != nil
        {
            cell.backGroundImage.loadImageUsingCacheWithUrlString(user.profileImageUrl!)
        }
        
        if let capitalizedUsername = user.username?.uppercased()
        {
            cell.usernameLabel.text = capitalizedUsername
        }
        
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath)
    {
        let user = users[indexPath.row]
        
        let memberProfile = MemberProfile()
        memberProfile.user = user
        memberProfile.memberList = self
        memberProfile.hidesBottomBarWhenPushed = true
        memberProfile.modalTransitionStyle = UIModalTransitionStyle.crossDissolve
        memberProfile.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
        
        self.tabBarController?.tabBar.isHidden = true
        self.navigationController?.present(memberProfile, animated: false, completion: nil)
    }
    
    fileprivate func fetchUser()
    {
        FIRDatabase.database().reference().child("users").observe(.childAdded, with: { (snapshot) in
            
            if let dictionary = snapshot.value as? [String: AnyObject]
            {
                let user = User(dictionary: dictionary)
                user.id = snapshot.key
                self.users.append(user)
                self.attemptReloadOfTable()
            }
        }, withCancel: nil)
    }
    
    private func attemptReloadOfTable()
    {
        self.timer?.invalidate()
        self.timer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(self.handleReloadTable), userInfo: nil, repeats: false)
    }
    
    func handleReloadTable()
    {
        DispatchQueue.main.async(execute:
            {
                self.activityIndicatorView.stopAnimating()
                self.collectionView?.reloadData()
        })
    }
    
    func handleSwipe(sender: UISwipeGestureRecognizer)
    {
        mainTabBarController?.selectedIndex += 1
    }
    
    func handleZoomIn(tapGesture: UILongPressGestureRecognizer)
    {
        if tapGesture.state == UIGestureRecognizerState.began
        {
            let p = tapGesture.location(in: self.collectionView)
            let indexPath = self.collectionView?.indexPathForItem(at: p)
            
            if let index = indexPath
            {
                let cell = self.collectionView?.cellForItem(at: index) as! MemberCell
                
                if cell.backGroundImage.image != nil
                {
                    self.performZoomInForStartingImageView(startingImageView: cell.backGroundImage)
                }
            }
        }
        
        if tapGesture.state == UIGestureRecognizerState.ended
        {
            handleZoomOut()
        }
    }
    
    var startingFrame: CGRect?
    var blackBackgroundView: UIView?
    var startingImageView: UIImageView?
    var zoomingImageView: UIImageView?
    
    func performZoomInForStartingImageView(startingImageView: UIImageView)
    {
        self.startingImageView = startingImageView
        self.startingImageView?.isHidden = true
        
        startingFrame = startingImageView.superview?.convert(startingImageView.frame, to: nil)
        
        zoomingImageView = UIImageView(frame: startingFrame!)
        zoomingImageView?.image = startingImageView.image
        
        if let keyWindow = UIApplication.shared.keyWindow
        {
            blackBackgroundView = UIView(frame: keyWindow.frame)
            blackBackgroundView?.backgroundColor = UIColor.black
            blackBackgroundView?.alpha = 0
            
            keyWindow.addSubview(blackBackgroundView!)
            keyWindow.addSubview(zoomingImageView!)
            
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                
                self.blackBackgroundView?.alpha = 0.7
                
                let height = self.startingFrame!.height / self.startingFrame!.width * keyWindow.frame.width
                
                self.zoomingImageView?.frame = CGRect(x: 0, y: 0, width: keyWindow.frame.width, height: height)
                
                self.zoomingImageView?.center = keyWindow.center
                
            }, completion: nil)
            
        }
    }
    
    func handleZoomOut()
    {
        if let zoomOutImageView = zoomingImageView
        {
            zoomOutImageView.layer.cornerRadius = 3
            zoomOutImageView.clipsToBounds = true
            
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                
                zoomOutImageView.frame = self.startingFrame!
                self.blackBackgroundView?.alpha = 0
                
            }, completion: { (completed: Bool) in
                
                zoomOutImageView.removeFromSuperview()
                self.startingImageView?.isHidden = false
            })
        }
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
