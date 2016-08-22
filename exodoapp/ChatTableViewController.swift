//
//  ChatTableViewController.swift
//  exodoapp
//
//  Created by Alberto on 23/9/15.
//  Copyright © 2015 Alberto. All rights reserved.
//

import UIKit

var chats = [Room]()

class ChatTableViewController: UITableViewController {
    
    var refreshC = UIRefreshControl()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
        // Init refresh control
        refreshC.tintColor = UIColor.clearColor()
        refreshC.backgroundColor = UIColor.clearColor()
        refreshC.addTarget(self, action: "refreshControlStateChanged", forControlEvents: .ValueChanged)
        
        loadRefreshControl()
        
        self.tableView.addSubview(refreshC)
        
    }
    
    
    func loadRefreshControl()
    {
        var refreshVW = NSBundle.mainBundle().loadNibNamed("RefreshControlView", owner: self, options: nil)
        
        var customView = refreshVW[0] as! UIView
        customView.frame = refreshC.bounds
        
        var customLabel = customView.viewWithTag(1) as! UILabel
        customLabel.textColor = UIColor.whiteColor()
        customView.backgroundColor = UIColor.orangeColor()
        
        
        refreshC.addSubview(customView)
        
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return chats.count
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCellWithIdentifier("UserChatCell", forIndexPath: indexPath) as? UserChatCell{
            let c = chats[indexPath.row]
            cell.configureCell(c)
            return cell
        }
        else
        {
            return UserChatCell()
        }
    }
    
    
    // Request Chats
    func requestChats()
    {
        let msg = "\(messageNum)[\"modules.chats.getRecentChats\",{\"after\":0}]"
        ws.send(msg)
    }
    
    public func updateChats(recvData:String)
    {
        //print("UPDATECHATS: \(recvData)")
        // I have to delete last char ]"
        let cleanData = recvData.substringWithRange(Range<String.Index>(start: recvData.startIndex, end: recvData.endIndex.advancedBy(-1)))
        
        //print("CLEANED!!")
        //print(cleanData)
        
        do{
            let json = try NSJSONSerialization.JSONObjectWithData(cleanData.dataUsingEncoding(NSUTF8StringEncoding)!, options: .AllowFragments) as? Dictionary<String, AnyObject>
            
            // let nextStart = (json!["nextStart"] as? Int)!
            let users = json!["rooms"] as? [Dictionary<String, AnyObject>]
            
            chats = [Room]()
            for u in users!{
                //print(t["tid"])
                let room = Room(room: u)
                //print(user.username)
                chats.append(room)
            }
            
            // Main UI Thread
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self.tableView.reloadData()
                self.refreshC.endRefreshing()
            })
            
        }catch{
            print("ERROR")
        }
    }
    

    @IBAction func refreshBtnClick(sender: AnyObject) {
        self.tableView.reloadData()
        requestChats()
    }
    
    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        // "modules.chats.get",{"touid":"498","since":"recent"}
        
        var MessagesVC = segue.destinationViewController as! UserChatViewController
        if let indexPath = self.tableView.indexPathForCell(sender as! UITableViewCell){
            if(indexPath.row < chats.count){
                let c = chats[indexPath.row]
                MessagesVC.room = c
            }
        }
        
    }
    
    
    func refreshControlStateChanged()
    {
        print("changed")
        self.requestChats()
    }
    
    

}
