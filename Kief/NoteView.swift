//
//  NoteView.swift
//  KiefApp
//
//  Created by Simon Elhoej Steinmejer on 6/19/17.
//  Copyright © 2017 Simon Elhoej Steinmejer. All rights reserved.
//

import UIKit

class NoteView: UIView
{
    let noteView: UITextView =
    {
        let note = UITextView()
        note.text = "Failed to fetch note"
        note.textColor = UIColor.rgb(red: 235, green: 216, blue: 164)
        note.textAlignment = .center
        note.font = UIFont.systemFont(ofSize: 14)
        note.isEditable = false
        note.backgroundColor = UIColor.clear
        
        return note
    }()
    
    override init(frame: CGRect)
    {
        super.init(frame: frame)
        
        backgroundColor = UIColor.rgb(red: 48, green: 42, blue: 35)
        layer.cornerRadius = 8
        layer.borderWidth = 0.5
        layer.borderColor = UIColor.rgb(red: 235, green: 216, blue: 164).cgColor
        layer.masksToBounds = true
        isHidden = true
        alpha = 0
        tag = 1
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleCloseAnimation)))
        
        addSubview(noteView)
        
        noteView.anchor(top: topAnchor, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingRight: 0, paddingBottom: 0, width: 0, height: 0)
    }
    
    func handleCloseAnimation()
    {
        if let viewWithTag = self.viewWithTag(1)
        {
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                
                viewWithTag.alpha = 0
                viewWithTag.frame = CGRect(origin: self.center, size: CGSize(width: 0, height: 0))
                
                
            }, completion: { (completed: Bool) in
                
                viewWithTag.removeFromSuperview()

            })
        }
    }

    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
