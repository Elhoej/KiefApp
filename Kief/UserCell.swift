//
//  UserCell.swift
//  KiefApp
//
//  Created by Simon Elhoej Steinmejer on 5/28/17.
//  Copyright © 2017 Simon Elhoej Steinmejer. All rights reserved.
//

import UIKit
import Firebase

class UserCell: UITableViewCell
{
    var message: Message?
    {
        didSet
        {
            setupNameAndProfileImage()
            
            detailTextLabel?.text = message?.text
            
            if message?.text != nil && (message?.text?.characters.count)! > 35
            {
                let shortenedString = message?.text?.substring(to: 35)
                
                detailTextLabel?.text = shortenedString! + "....."
            }
            else if message?.imageUrl != nil && message?.videoUrl == nil
            {
                detailTextLabel?.text = "Sent an image"
            }
            else if message?.videoUrl != nil
            {
                detailTextLabel?.text = "Sent a video"
            }
            
            if let seconds = message?.timestamp?.doubleValue
            {
                let timestampDate = Date(timeIntervalSince1970: seconds)
                let currentTime = Int(Date().timeIntervalSince1970)
                let dateFormatter = DateFormatter()
                
                if currentTime - (message?.timestamp?.intValue)! > 86400 && currentTime - (message?.timestamp?.intValue)! < 518400
                {
                    dateFormatter.dateFormat = "EEE hh:mm a"
                    timeLabel.text = dateFormatter.string(from: timestampDate)
                }
                else if currentTime - (message?.timestamp?.intValue)! > 518400
                {
                    dateFormatter.dateFormat = "dd MMM YYYY"
                    timeLabel.text = dateFormatter.string(from: timestampDate)
                }
                else
                {
                    dateFormatter.dateFormat = "hh:mm a"
                    timeLabel.text = dateFormatter.string(from: timestampDate)
                }
            }
            
            guard let uid = FIRAuth.auth()?.currentUser?.uid else { return }
            
            if message?.toId == uid
            {
                if message?.didRead == "0"
                {
                    unreadMessageIndicator.isHidden = false
                }
            }
        }
    }
    
    fileprivate func setupNameAndProfileImage()
    {
    
        if let id = message?.chatPartnerId()
        {
            let ref = FIRDatabase.database().reference().child("users").child(id)
            ref.observeSingleEvent(of: .value, with: { (snapshot) in
                
                if let dictionary = snapshot.value as? [String: AnyObject]
                {
                    self.textLabel?.text = dictionary["username"] as? String
                    
                    if let profileImageUrl = dictionary["profileImageUrl"] as? String
                    {
                        self.profileImageView.loadImageUsingCacheWithUrlString(profileImageUrl)
                    }
                }
                
            }, withCancel: nil)
        }
    }

    
    override func layoutSubviews()
    {
        super.layoutSubviews()
        
        textLabel?.frame = CGRect(x: 64, y: textLabel!.frame.origin.y - 2, width: textLabel!.frame.width, height: textLabel!.frame.height)
        
        detailTextLabel?.frame = CGRect(x: 64, y: detailTextLabel!.frame.origin.y + 2, width: detailTextLabel!.frame.width, height: detailTextLabel!.frame.height)
    }
    
    let profileImageView: UIImageView =
    {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.layer.cornerRadius = 24
        imageView.layer.masksToBounds = true
        imageView.contentMode = .scaleAspectFill
        
        return imageView
    }()
    
    let timeLabel: UILabel =
    {
        let label = UILabel()
        label.text = " "
        label.font = UIFont.systemFont(ofSize: 13)
        label.textColor = UIColor.darkGray
        label.textAlignment = .right
        
        return label
    }()
    
    let unreadMessageIndicator: UIView =
    {
        let view = UIView()
        view.backgroundColor = UIColor.rgb(red: 22, green: 190, blue: 249)
        view.layer.cornerRadius = 8
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.white.cgColor
        view.layer.masksToBounds = true
        view.isHidden = true
        
        return view
    }()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?)
    {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
        
        addSubview(profileImageView)
        addSubview(timeLabel)
        addSubview(unreadMessageIndicator)
        
        profileImageView.anchor(top: nil, left: self.leftAnchor, bottom: nil, right: nil, paddingTop: 0, paddingLeft: 8, paddingRight: 0, paddingBottom: 0, width: 48, height: 48)
        
        profileImageView.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        
        timeLabel.anchor(top: self.topAnchor, left: nil, bottom: nil, right: self.rightAnchor, paddingTop: 18, paddingLeft: 0, paddingRight: 15, paddingBottom: 0, width: 100, height: 0)
        timeLabel.heightAnchor.constraint(equalTo: (textLabel?.heightAnchor)!).isActive = true
        
        unreadMessageIndicator.anchor(top: profileImageView.topAnchor, left: nil, bottom: nil, right: profileImageView.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingRight: 0, paddingBottom: 0, width: 16, height: 16)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }


}
