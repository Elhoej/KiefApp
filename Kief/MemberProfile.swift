//
//  MemberProfile.swift
//  KiefApp
//
//  Created by Simon Elhoej Steinmejer on 7/4/17.
//  Copyright © 2017 Simon Elhoej Steinmejer. All rights reserved.
//

import UIKit
import Firebase

class MemberProfile: UIViewController, UITableViewDelegate, UITableViewDataSource
{
    var user: User?
    {
        didSet
        {
            profileImageView.loadImageUsingCacheWithUrlString((user?.profileImageUrl)!)
            usernameLabel.text = user?.username
            snapchatLabel.text = user?.snapchat
            observeActivityHistory()
        }
    }
    var memberList: MemberList?
    let cellId = "cellId"
    var activities = [Activity]()
    var activitiesDictionary = [String: Activity]()
    
    let tableView: UITableView =
    {
        let tableView = UITableView()
        tableView.backgroundColor = UIColor.clear
        tableView.layer.borderWidth = 0.5
        tableView.layer.borderColor = UIColor.rgb(red: 235, green: 216, blue: 164).cgColor
        tableView.layer.masksToBounds = true
        tableView.layer.cornerRadius = 5
        tableView.preservesSuperviewLayoutMargins = false
        tableView.separatorInset = UIEdgeInsets.zero
        tableView.layoutMargins = UIEdgeInsets.zero

        
        return tableView
    }()
    
    let frostEffect: UIVisualEffectView =
    {
        let frost = UIVisualEffectView(effect: UIBlurEffect(style: .light))
        frost.autoresizingMask = .flexibleWidth
        frost.alpha = 0
        
        return frost
    }()
    
    let containerView: UIView =
    {
        let view = UIView()
        view.backgroundColor = UIColor.rgb(red: 48, green: 42, blue: 35)
        view.layer.cornerRadius = 8
        view.layer.masksToBounds = true
        view.alpha = 0
        
        return view
    }()
    
    let profileImageView: UIImageView =
    {
        let image = UIImageView()
        image.contentMode = .scaleAspectFit
        image.clipsToBounds = true
        image.layer.cornerRadius = 20
        image.layer.borderWidth = 1
        image.layer.borderColor = UIColor.white.cgColor
        image.layer.masksToBounds = true
        
        return image
    }()
    
    let profileLabel: UILabel =
    {
        let label = UILabel()
        label.text = "Profile"
        label.textColor = UIColor.white
        label.textAlignment = .center
        label.font = UIFont(name: "Graduate-Regular", size: 12)
        
        return label
    }()
    
    let snapchatImageView: UIImageView =
    {
        let image = UIImageView()
        image.image = #imageLiteral(resourceName: "snapchat").withRenderingMode(.alwaysOriginal)
        image.contentMode = .scaleToFill
        image.layer.cornerRadius = 20
        image.layer.borderWidth = 1
        image.layer.borderColor = UIColor.white.cgColor
        image.layer.masksToBounds = true
        
        return image
    }()
    
    let usernameLabel: UILabel =
    {
        let label = UILabel()
        label.textColor = UIColor.rgb(red: 235, green: 216, blue: 164)
        
        return label
    }()
    
    let snapchatLabel: UILabel =
    {
        let label = UILabel()
        label.textColor = UIColor.rgb(red: 235, green: 216, blue: 164)
        
        return label
    }()
    
    let activityHistoryLabel: UILabel =
    {
        let label = UILabel()
        label.textColor = UIColor.white
        label.text = "Activity History"
        label.font = UIFont(name: "Graduate-Regular", size: 12)
        label.textAlignment = .center
        
        return label
    }()
    
    let sendMessageButton: UIButton =
    {
        let button = UIButton(type: .system)
        button.backgroundColor = UIColor.rgb(red: 235, green: 216, blue: 164)
        button.setTitle("Send a message", for: .normal)
        button.setTitleColor(UIColor.rgb(red: 48, green: 42, blue: 35), for: .normal)
        button.layer.cornerRadius = 25
        button.layer.masksToBounds = true
        button.addTarget(self, action: #selector(handleNewMessage), for: .touchUpInside)
        
        return button
    }()
    
    let activityIndicatorView: UIActivityIndicatorView =
    {
        let aiv = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
        aiv.translatesAutoresizingMaskIntoConstraints = false
        aiv.hidesWhenStopped = true
        
        return aiv
    }()
    
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(false)
        self.tabBarController?.tabBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool)
    {
        super.viewWillAppear(false)
        self.tabBarController?.tabBar.isHidden = false
    }
    
    override func viewDidAppear(_ animated: Bool)
    {
        super.viewDidAppear(true)
        containerView.center.x -= self.view.frame.width + 100
        
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
            
            self.frostEffect.alpha = 1
            self.containerView.alpha = 1
            self.containerView.center.x += self.view.frame.width + 100
            
        }, completion: nil)
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        view.addSubview(frostEffect)
        
        view.backgroundColor = UIColor.clear
        
        view.addSubview(containerView)
        
        tableView.addSubview(activityIndicatorView)
        activityIndicatorView.centerYAnchor.constraint(equalTo: tableView.centerYAnchor).isActive = true
        activityIndicatorView.centerXAnchor.constraint(equalTo: tableView.centerXAnchor).isActive = true
        activityIndicatorView.startAnimating()
        
        setupUIConstraints()
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(ActivityHistoryCell.self, forCellReuseIdentifier: cellId)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        view.addGestureRecognizer(tapGesture)
        
    }
    
    func observeActivityHistory()
    {
//        guard let uid = FIRAuth.auth()?.currentUser?.uid else { return }
        let ref = FIRDatabase.database().reference().child("activityHistory").child((user?.id)!)
        
        attemptReloadOfTable()
        
        ref.observe(.childAdded, with: { (snapshot) in
            
            if let dictionary = snapshot.value as? [String: AnyObject]
            {
                let activity = Activity(dictionary: dictionary)
                self.activitiesDictionary[String(describing: activity.timestamp)] = activity
                self.attemptReloadOfTable()
            }
            
        }, withCancel: nil)
    }
    
    private func attemptReloadOfTable()
    {
        
        self.timer?.invalidate()
        self.timer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(self.handleReloadTable), userInfo: nil, repeats: false)
    }
    
    var timer: Timer?
    
    func handleReloadTable()
    {
        self.activities = Array(self.activitiesDictionary.values)
        
        self.activities.sort { (activity1, activity2) -> Bool in
            
            return (activity1.timestamp?.int32Value)! > (activity2.timestamp?.int32Value)!
        }
        
        DispatchQueue.main.async(execute:
            {
                self.activityIndicatorView.stopAnimating()
                self.tableView.reloadData()
        })
    }

    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return activities.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! ActivityHistoryCell
        
        let activity = self.activities[indexPath.row]
        cell.activityHistory = activity
        
        return cell
    }
    
    func handleTap(sender: UITapGestureRecognizer)
    {
        self.memberList?.tabBarController?.tabBar.isHidden = false
        dismiss(animated: true, completion: nil)
    }
    
    func handleNewMessage()
    {
        self.memberList?.tabBarController?.tabBar.isHidden = false
        dismiss(animated: true)
        {
            let chatLogController = ChatLogController(collectionViewLayout: UICollectionViewFlowLayout())
            chatLogController.user = self.user
            self.memberList?.navigationController?.pushViewController(chatLogController, animated: true)
        }
    }
    
    func setupUIConstraints()
    {
        containerView.addSubview(profileImageView)
        containerView.addSubview(profileLabel)
        containerView.addSubview(usernameLabel)
        containerView.addSubview(snapchatLabel)
        containerView.addSubview(snapchatImageView)
        containerView.addSubview(sendMessageButton)
        containerView.addSubview(tableView)
        containerView.addSubview(activityHistoryLabel)
        
        frostEffect.anchor(top: view.topAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingRight: 0, paddingBottom: 30, width: 0, height: 0)
        containerView.anchor(top: nil, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 0, paddingLeft: 20, paddingRight: 20, paddingBottom: 0, width: 0, height: 370)
        containerView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        
        profileImageView.anchor(top: containerView.topAnchor, left: containerView.leftAnchor, bottom: nil, right: nil, paddingTop: 50, paddingLeft: 15, paddingRight: 0, paddingBottom: 0, width: 40, height: 40)
        
        profileLabel.anchor(top: containerView.topAnchor, left: nil, bottom: nil, right: nil, paddingTop: 10, paddingLeft: 0, paddingRight: 0, paddingBottom: 0, width: 200, height: 30)
        profileLabel.centerXAnchor.constraint(equalTo: containerView.centerXAnchor).isActive = true
        
        usernameLabel.anchor(top: nil, left: profileImageView.rightAnchor, bottom: nil, right: containerView.rightAnchor, paddingTop: 10, paddingLeft: 6, paddingRight: 10, paddingBottom: 0, width: 0, height: 20)
        usernameLabel.centerYAnchor.constraint(equalTo: profileImageView.centerYAnchor).isActive = true
        
        snapchatImageView.anchor(top: profileImageView.bottomAnchor, left: containerView.leftAnchor, bottom: nil, right: nil, paddingTop: 15, paddingLeft: 15, paddingRight: 0, paddingBottom: 0, width: 40, height: 40)
        
        snapchatLabel.anchor(top: nil, left: snapchatImageView.rightAnchor, bottom: nil, right: containerView.rightAnchor, paddingTop: 0, paddingLeft: 6, paddingRight: 10, paddingBottom: 0, width: 0, height: 20)
        snapchatLabel.centerYAnchor.constraint(equalTo: snapchatImageView.centerYAnchor).isActive = true
        
        activityHistoryLabel.anchor(top: snapchatImageView.bottomAnchor, left: containerView.leftAnchor, bottom: nil, right: containerView.rightAnchor, paddingTop: 10, paddingLeft: 10, paddingRight: 10, paddingBottom: 0, width: 0, height: 15)
        
        tableView.anchor(top: activityHistoryLabel.bottomAnchor, left: containerView.leftAnchor, bottom: sendMessageButton.topAnchor, right: containerView.rightAnchor, paddingTop: 10, paddingLeft: 15, paddingRight: 15, paddingBottom: -10, width: 0, height: 0)
        
        sendMessageButton.anchor(top: nil, left: containerView.leftAnchor, bottom: containerView.bottomAnchor, right: containerView.rightAnchor, paddingTop: 0, paddingLeft: 20, paddingRight: 20, paddingBottom: -10, width: 0, height: 50)
        
    }
    
    
}
