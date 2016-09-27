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
    
    
    func requestNotifications()
    {
        NodeBBAPI.sharedInstance.getNotifications { (err, json) in
            
            let nots = json!["notifications"] as? [Dictionary<String, AnyObject>]
            
            self.notifications = [Notification]()
            for n in nots!{
                let notif = Notification(notif: n)
                self.notifications.append(notif)
            }
            
            // Main UI Thread
            DispatchQueue.main.async(execute: { () -> Void in
                self.tableView.reloadData()
                self.refreshC.endRefreshing()
            })
            
        }
    }
    
    
    /* MARK: - Navigation
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        // "modules.chats.get",{"touid":"498","since":"recent"}
        
        let MessagesVC = segue.destination as! UserChatViewController
        if let indexPath = self.tableView.indexPath(for: sender as! UITableViewCell){
            if((indexPath as NSIndexPath).row < chats.count){
                let c = chats[(indexPath as NSIndexPath).row]
                MessagesVC.room = c
            }
        }
        
    }
    */
    
    func refreshControlStateChanged()
    {
        self.requestNotifications()
    }
    
    
    
}
