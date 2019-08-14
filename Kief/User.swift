//
//  User.swift
//  KiefApp
//
//  Created by Simon Elhoej Steinmejer on 5/25/17.
//  Copyright © 2017 Simon Elhoej Steinmejer. All rights reserved.
//

import UIKit

class User: NSObject
{
    var username: String?
    var profileImageUrl: String?
    var id: String?
    var snapchat: String?
    var jokke: Bool?
    var tokommanul: Bool?
    var fcmToken: String?
    
    init(dictionary: [String: Any])
    {
        self.id = dictionary["id"] as? String ?? ""
        self.username = dictionary["username"] as? String ?? ""
        self.profileImageUrl = dictionary["profileImageUrl"] as? String ?? ""
        self.snapchat = dictionary["snapchat"] as? String ?? ""
        self.jokke = dictionary["jokke"] as? Bool
        self.tokommanul = dictionary["tokommanul"] as? Bool
        self.fcmToken = dictionary["fcmToken"] as? String
    }
}
