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
    var read:Bool!
    
    // If it is a reply or mention
    var tid:Int!
    var pid:Int!
    
    init(notif: Dictionary<String, AnyObject>){
        
        bodyShort = notif["bodyShort"] as! String
        bodyLong = notif["bodyLong"] as? String
        nid = notif["nid"] as! String
        slug = notif["path"] as! String
        datetime = notif["datetimeISO"] as! String
        read = notif["read"] as! Bool
        
        if let topicId = notif["tid"] as? Int{
            tid = topicId
        }
        if let postId = notif["pid"] as? Int{
            pid = postId
        }
        
    }
    
}
