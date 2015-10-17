//
//  Thread.swift
//  exodoapp
//
//  Created by Alberto on 19/9/15.
//  Copyright © 2015 Alberto. All rights reserved.
//

import Foundation

class Thread {
    
    var title: String!
    var tid: Int!
    var cid: Int!
    var slug: String!
    var creationDate: String!
    var lastPostDate: String!
    var lastPostUser: String!
    var unread: Bool!
    var postCount: Int!
    var viewCount: Int!
    var locked: Bool!
    
    init(threadDic: Dictionary<String, AnyObject>)
    {
        self.title = threadDic["title"] as? String
        self.tid = threadDic["tid"] as? Int
        self.cid = threadDic["cid"] as? Int
        self.slug = threadDic["slug"] as! String
        self.creationDate = threadDic["relativeTime"] as? String
        self.lastPostDate = threadDic["lastposttimeISO"] as? String
        self.unread = threadDic["unread"] as? Bool
        
        self.postCount = threadDic["postcount"] as? Int
        self.viewCount = threadDic["viewcount"] as? Int
        
        self.locked = threadDic["locked"] as? Bool
                
        //let kk = threadDic as! NSDictionary
        //var kk2 = kk!["user"]! as? Dictionary<String, AnyObject>
        
        if let teaser = threadDic["teaser"] as? NSDictionary{
            self.lastPostUser = teaser.objectForKey("user")?.objectForKey("username") as! String
        }
        else if let user = threadDic["user"] as? NSDictionary{
            self.lastPostUser = user.objectForKey("username") as! String
        }
    }
    
}