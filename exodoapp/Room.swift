//
//  User.swift
//  exodoapp
//
//  Created by Alberto on 23/9/15.
//  Copyright © 2015 Alberto. All rights reserved.
//

import UIKit

class Room{
    
    var username: String!
    var rid: String!
    var uid: Int!
    var picture: String!
    var status: String!
    var slug: String!
    var unread: Bool!
    
    init(room: Dictionary<String, AnyObject>){
        username = room["usernames"] as! String
        slug = ""
        
        if let slugg = room["slug"] as? String
        {
            slug = slugg
        }
        
        rid = room["roomId"] as! String
        picture = (room["users"] as! [AnyObject])[0]["picture"] as! String
        status = (room["users"] as! [AnyObject])[0]["status"] as! String
        
        unread = room["unread"] as! Bool
    }
    
}
