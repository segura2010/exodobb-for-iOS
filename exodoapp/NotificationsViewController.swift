//
//  NotificationsViewController.swift
//  exodoapp
//
//  Created by Alberto on 27/9/16.
//  Copyright © 2016 Alberto. All rights reserved.
//

import UIKit

class NotificationsViewController: UITableViewController {
    
    var refreshC = UIRefreshControl()
    
    var notifications = [Notification]()
    var notRead = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
        requestNotifications()
        
        // Init refresh control
        refreshC.tintColor = UIColor.clear
        refreshC.backgroundColor = UIColor.clear
        refreshC.addTarget(self, action: #selector(NotificationsViewController.refreshControlStateChanged), for: .valueChanged)
        
        loadRefreshControl()
        
        self.tableView.addSubview(refreshC)
        
    }
    
    
    func loadRefreshControl()
    {
        var refreshVW = Bundle.main.loadNibNamed("RefreshControlView", owner: self, options: nil)
        
        let customView = refreshVW?[0] as! UIView
        customView.frame = refreshC.bounds
        
        let customLabel = customView.viewWithTag(1) as! UILabel
        customLabel.textColor = UIColor.white
        customView.backgroundColor = UIColor.orange
        
        
        refreshC.addSubview(customView)
        
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return notifications.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "NotificationCell", for: indexPath) as? NotificationCell{
            let c = notifications[(indexPath as NSIndexPath).row]
            cell.configureCell(c)
            return cell
        }
        else
        {
            return NotificationCell()
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let notif = notifications[(indexPath as NSIndexPath).row]
        if notif.pid != nil{
            
            let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
            let postView = storyboard.instantiateViewController(withIdentifier: "PostVC") as! PostViewController
            
            var postJson = [String:AnyObject]()
            postJson["content"] = notif.bodyLong as AnyObject?
            postJson["tid"] = notif.tid as AnyObject?
            postJson["pid"] = notif.pid as AnyObject?
            postJson["timestampISO"] = "" as AnyObject?
            postJson["favourited"] = false as AnyObject?
            postJson["reputation"] = 0 as AnyObject?
            postJson["votes"] = 0 as AnyObject?
            postJson["deleted"] = false as AnyObject?
            
            
            var post = Post(threadDic: postJson)
            
            let parseNotif = notif.bodyShort.characters.split(separator: ",").map(String.init)
            
            // remove first space
            let index = parseNotif[1].index(parseNotif[1].startIndex, offsetBy: 1)
            post.userslug = parseNotif[1].substring(from: index)
            
            postView.post = post
            navigationController?.pushViewController(postView, animated: true)
            
        }
        
    }
    
    
    func requestNotifications()
    {
        self.notRead = 0
        NodeBBAPI.sharedInstance.getNotifications { (err, json) in
            
            let nots = json!["notifications"] as? [Dictionary<String, AnyObject>]
            
            self.notifications = [Notification]()
            for n in nots!{
                let notif = Notification(notif: n)
                self.notifications.append(notif)
                
                if !notif.read
                {
                    self.notRead = self.notRead + 1
                }
            }
            
            // Main UI Thread
            DispatchQueue.main.async(execute: { () -> Void in
                self.tableView.reloadData()
                self.refreshC.endRefreshing()
                if self.notRead > 0
                {
                    self.tabBarController?.tabBar.items?[2].badgeValue = "\(self.notRead)"
                }
                else
                {
                    self.tabBarController?.tabBar.items?[2].badgeValue = nil
                }
            })
            
        }
    }
    
    /* MARK: - Navigation
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
     
        
    }*/
    
    
    func refreshControlStateChanged()
    {
        self.requestNotifications()
    }
    
    
    
}
