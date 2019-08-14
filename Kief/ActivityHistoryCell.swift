//
//  ActivityHistoryCell.swift
//  KiefApp
//
//  Created by Simon Elhoej Steinmejer on 7/7/17.
//  Copyright © 2017 Simon Elhoej Steinmejer. All rights reserved.
//

import UIKit
import Firebase

class ActivityHistoryCell: UITableViewCell
{
    var activityHistory: Activity?
    {
        didSet
        {
            if activityHistory?.activity == "nn"
            {
                activityIconView.image = #imageLiteral(resourceName: "computer").withRenderingMode(.alwaysOriginal)
            }
            else if activityHistory?.activity == "shabazz"
            {
                activityIconView.image = #imageLiteral(resourceName: "kaffeMedDamp")
                activityIconView.backgroundColor = UIColor.rgb(red: 235, green: 216, blue: 164)
            }
            else
            {
                activityIconView.image = #imageLiteral(resourceName: "hammer").withRenderingMode(.alwaysOriginal)
            }
            
            if let seconds = activityHistory?.timestamp?.doubleValue
            {
                let timestampDate = Date(timeIntervalSince1970: seconds)
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "hh:mm a\n dd MMM YYYY"
                timestampLabel.text = dateFormatter.string(from: timestampDate)
            }
            
            noteView.text = activityHistory?.note

        }
    }
    
    let activityIconView: UIImageView =
    {
        let image = UIImageView()
        image.layer.cornerRadius = 15
        image.layer.masksToBounds = true
        image.backgroundColor = nil
        
        return image
    }()
    
    let timestampLabel: UILabel =
    {
        let label = UILabel()
        label.text = " "
        label.font = UIFont.systemFont(ofSize: 11)
        label.textColor = UIColor.lightGray
        label.textAlignment = .right
        label.numberOfLines = 2
        
        return label
    }()
    
    let noteView: UITextView =
    {
        let textView = UITextView()
        textView.text = " "
        textView.textColor = UIColor.rgb(red: 235, green: 216, blue: 164)
        textView.font = UIFont.systemFont(ofSize: 11)
        textView.isEditable = false
        textView.backgroundColor = UIColor.clear
        
        return textView
    }()
    
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?)
    {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
        
        backgroundColor = UIColor.clear
        
        addSubview(activityIconView)
        addSubview(timestampLabel)
        addSubview(noteView)
        
        activityIconView.anchor(top: nil, left: leftAnchor, bottom: nil, right: nil, paddingTop: 0, paddingLeft: 8, paddingRight: 0, paddingBottom: 0, width: 30, height: 30)
        activityIconView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        
        timestampLabel.anchor(top: topAnchor, left: nil, bottom: bottomAnchor, right: rightAnchor, paddingTop: 8, paddingLeft: 0, paddingRight: 12, paddingBottom: -8, width: 70, height: 0)
        
        noteView.anchor(top: topAnchor, left: activityIconView.rightAnchor, bottom: bottomAnchor, right: timestampLabel.leftAnchor, paddingTop: 0, paddingLeft: 5, paddingRight: 5, paddingBottom: -5, width: 0, height: 0)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
