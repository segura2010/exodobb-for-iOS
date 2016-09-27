//
//  Notification.swift
//  exodoapp
//
//  Created by Alberto on 27/9/16.
//  Copyright © 2016 Alberto. All rights reserved.
//

import UIKit

class Notification{
    
    var bodyShort: String!
    var bodyLong: String!
    var nid:String!
    var slug:String!
    var datetime:String!
    
    init(notif: Dictionary<String, AnyObject>){
        
        bodyShort = notif["bodyShort"] as! String
        bodyLong = notif["bodyLong"] as? String
        nid = notif["nid"] as! String
        slug = notif["path"] as! String
        datetime = notif["datetimeISO"] as! String
        
    }
    
}
