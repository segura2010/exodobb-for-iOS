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
    var favourited: Bool!
    var votes: Int!
    var reputation: Int!
    
    init(threadDic: Dictionary<String, AnyObject>)
    {
        self.content = threadDic["content"] as? String
        self.tid = threadDic["tid"] as? Int
        self.pid = threadDic["pid"] as? Int
        self.relativeTime = threadDic["timestampISO"] as? String
        self.favourited = threadDic["favourited"] as? Bool
        
        // Votes and reputation are in inverse order.. XD
        self.votes = threadDic["reputation"] as? Int
        self.reputation = threadDic["votes"] as? Int
        
        //let kk = threadDic as! NSDictionary
        //var kk2 = kk!["user"]! as? Dictionary<String, AnyObject>
        
        if let user = threadDic["user"] as? NSDictionary{
            self.username = user.object(forKey: "username") as! String
            self.userslug = user.object(forKey: "userslug") as! String
            self.picture = user.object(forKey: "picture") as! String
        }
        else{
            self.username = ""
            self.userslug = ""
            self.picture = ""
        }
    }
    
}
