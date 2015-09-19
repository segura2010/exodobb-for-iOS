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
    
    init(threadDic: Dictionary<String, AnyObject>)
    {
        self.title = threadDic["title"] as? String
        self.tid = threadDic["tid"] as? Int
        self.cid = threadDic["cid"] as? Int
        self.slug = threadDic["slug"] as? String
        self.creationDate = threadDic["relativeTime"] as? String
        self.lastPostDate = threadDic["lastposttimeISO"] as? String
        
        let kk = threadDic as! NSDictionary
        //var kk2 = kk!["user"]! as? Dictionary<String, AnyObject>
        //print(kk)
        self.lastPostUser = kk.objectForKey("teaser")!.objectForKey("user")!.objectForKey("username") as! String
    }
    
}