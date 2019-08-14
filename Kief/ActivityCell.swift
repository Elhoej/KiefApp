//
//  ActivityCell.swift
//  KiefApp
//
//  Created by Simon Elhoej Steinmejer on 6/7/17.
//  Copyright © 2017 Simon Elhoej Steinmejer. All rights reserved.
//

import UIKit

class ActivityCell: UICollectionViewCell
{
    let activityImage: UIImageView =
    {
        let image = UIImageView(image: #imageLiteral(resourceName: "LoginLOGO").withRenderingMode(.alwaysOriginal))
        
        return image
    }()
    
    let profileImageView: UIImageView =
    {
        let image = UIImageView()
        image.layer.cornerRadius = 14
        image.layer.masksToBounds = true
        image.contentMode = .scaleAspectFill
        
        return image
    }()
    
    let usernameLabel: UILabel =
    {
        let label = UILabel()
        label.text = "Username"
        label.font = UIFont.systemFont(ofSize: 13)
        label.textColor = UIColor.black
        label.backgroundColor = UIColor.clear
        
        return label
    }()
    
    let timestampLabel: UILabel =
    {
        let label = UILabel()
        label.text = "HH:MM ago"
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor = UIColor.darkGray
        label.backgroundColor = UIColor.clear
        
        return label
    }()
    
    let frostEffect: UIVisualEffectView =
    {
        let frost = UIVisualEffectView(effect: UIBlurEffect(style: .light))
        frost.autoresizingMask = .flexibleWidth
        
        return frost
    }()
    
    override init(frame: CGRect)
    {
        super.init(frame: frame)
        
        backgroundColor = UIColor.init(white: 1, alpha: 0.3)
        layer.cornerRadius = 5
        layer.masksToBounds = true
        
        addSubview(frostEffect)
        addSubview(activityImage)
        addSubview(profileImageView)
        addSubview(usernameLabel)
        addSubview(timestampLabel)
        
        frostEffect.anchor(top: self.topAnchor, left: self.leftAnchor, bottom: self.bottomAnchor, right: self.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingRight: 0, paddingBottom: 0, width: 0, height: 0)
        
        activityImage.anchor(top: nil, left: nil, bottom: nil, right: nil, paddingTop: 0, paddingLeft: 0, paddingRight: 0, paddingBottom: 0, width: 40, height: 40)
        activityImage.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        activityImage.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        
        profileImageView.anchor(top: nil, left: self.leftAnchor, bottom: nil, right: nil, paddingTop: 0, paddingLeft: 8, paddingRight: 0, paddingBottom: 0, width: 28, height: 28)
        profileImageView.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        
        usernameLabel.anchor(top: nil, left: profileImageView.rightAnchor, bottom: nil, right: activityImage.leftAnchor, paddingTop: 0, paddingLeft: 8, paddingRight: 1, paddingBottom: 0, width: 0, height: 0)
        usernameLabel.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        usernameLabel.heightAnchor.constraint(equalTo: self.heightAnchor).isActive = true
        
        timestampLabel.anchor(top: nil, left: nil, bottom: nil, right: self.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingRight: 8, paddingBottom: 0, width: 80, height: 0)
        timestampLabel.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        timestampLabel.heightAnchor.constraint(equalTo: self.heightAnchor).isActive = true

    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
