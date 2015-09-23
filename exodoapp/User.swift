//
//  User.swift
//  exodoapp
//
//  Created by Alberto on 23/9/15.
//  Copyright © 2015 Alberto. All rights reserved.
//

import UIKit

class User{
    
    var username: String!
    var slug: String!
    var uid: Int!
    var picture: String!
    var status: String!
    
    init(user: Dictionary<String, AnyObject>){
        username = user["username"] as! String
        slug = ""
        
        if let slugg = user["slug"] as? String
        {
            slug = slugg
        }
        
        uid = user["uid"] as! Int
        picture = user["picture"] as! String
        status = user["status"] as! String
    }
    
}
