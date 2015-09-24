//
//  Post.swift
//  exodoapp
//
//  Created by Alberto on 20/9/15.
//  Copyright © 2015 Alberto. All rights reserved.
//

import Foundation

class Post {
    
    var content: String!
    var tid: Int!
    var pid: Int!
    var relativeTime: String!
    var username: String!
    var userslug: String!
    var picture: String!
    
    init(threadDic: Dictionary<String, AnyObject>)
    {
        self.content = threadDic["content"] as? String
        self.tid = threadDic["tid"] as? Int
        self.pid = threadDic["pid"] as? Int
        self.relativeTime = threadDic["relativeTime"] as? String
        
        //let kk = threadDic as! NSDictionary
        //var kk2 = kk!["user"]! as? Dictionary<String, AnyObject>
        
        if let user = threadDic["user"] as? NSDictionary{
            self.username = user.objectForKey("username") as! String
            self.userslug = user.objectForKey("userslug") as! String
            self.picture = user.objectForKey("picture") as! String
        }
        else{
            self.username = ""
            self.userslug = ""
            self.picture = ""
        }
    }
    
}