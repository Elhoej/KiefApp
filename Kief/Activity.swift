//
//  Activity.swift
//  KiefApp
//
//  Created by Simon Elhoej Steinmejer on 6/6/17.
//  Copyright © 2017 Simon Elhoej Steinmejer. All rights reserved.
//

import UIKit

class Activity: NSObject
{
    var id: String?
    var timestamp: NSNumber?
    var activity: String?
    var note: String?
    
    init(dictionary: [String: Any])
    {
        self.id = dictionary["id"] as? String
        self.timestamp = dictionary["timestamp"] as? NSNumber
        self.activity = dictionary["activity"] as? String
        self.note = dictionary["note"] as? String
    }
}
