//
//  MemberCell.swift
//  KiefApp
//
//  Created by Simon Elhoej Steinmejer on 7/3/17.
//  Copyright © 2017 Simon Elhoej Steinmejer. All rights reserved.
//

import UIKit
import Firebase

class MemberCell: UICollectionViewCell
{
    let backGroundImage: UIImageView =
    {
        let image = UIImageView()
        image.contentMode = .scaleAspectFill
        image.clipsToBounds = true
        image.layer.cornerRadius = 3
        image.layer.masksToBounds = true
        
        return image
    }()
    
    let usernameLabel: UILabel =
    {
        let label = UILabel()
        label.text = " "
        label.textAlignment = .center
        label.textColor = UIColor.white
        label.backgroundColor = UIColor.init(red: 0/255, green: 0/255, blue: 0/255, alpha: 0.3)
        label.font = UIFont(name: "Graduate-Regular", size: 12)
        
        return label
    }()
    
    let topLine: UIView =
    {
        let view = UIView()
        view.backgroundColor = UIColor.white
        
        return view
    }()
    
    let botLine: UIView =
    {
        let view = UIView()
        view.backgroundColor = UIColor.white
        
        return view
    }()
    
    override init(frame: CGRect)
    {
        super.init(frame: frame)
        
        backgroundColor = UIColor.init(red: 220/255, green: 220/255, blue: 220/255, alpha: 0.3)
        layer.cornerRadius = 3
        layer.masksToBounds = true
        
        addSubview(backGroundImage)
        backGroundImage.addSubview(usernameLabel)
        backGroundImage.addSubview(topLine)
        backGroundImage.addSubview(botLine)
        
        backGroundImage.anchor(top: topAnchor, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, paddingTop: 0.5, paddingLeft: 0.5, paddingRight: 0.5, paddingBottom: 0.5, width: 0, height: 0)
        
        usernameLabel.anchor(top: nil, left: backGroundImage.leftAnchor, bottom: nil, right: backGroundImage.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingRight: 0, paddingBottom: 0, width: 0, height: 20)
        usernameLabel.centerYAnchor.constraint(equalTo: backGroundImage.centerYAnchor).isActive = true
        
        topLine.anchor(top: usernameLabel.topAnchor, left: backGroundImage.leftAnchor, bottom: nil, right: backGroundImage.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingRight: 0, paddingBottom: 0, width: 0, height: 0.5)
        
        botLine.anchor(top: nil, left: backGroundImage.leftAnchor, bottom: usernameLabel.bottomAnchor, right: backGroundImage.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingRight: 0, paddingBottom: 0, width: 0, height: 0.5)
        
    }
    
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
