//
//  UserChatMessageTableViewController.swift
//  exodoapp
//
//  Created by Alberto on 23/9/15.
//  Copyright © 2015 Alberto. All rights reserved.
//

import UIKit

var messages = ["Hola", "XD"]

class UserChatMessageTableViewController: UITableViewController {
    
    var user: User!

    override func viewDidLoad() {
        super.viewDidLoad()

        print("MESSAGES!!!")
        requestMessages()
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
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
        return messages.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCellWithIdentifier("UserChatMessageCell", forIndexPath: indexPath) as? UserChatMessageCellTableViewCell{
            let c = messages[indexPath.row]
            cell.configureCell(c)
            return cell
        }
        else
        {
            return UserChatMessageCellTableViewCell()
        }
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

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    
    
    // Request Chats
    func requestMessages()
    {
        let msg = "\(messageNum)[\"modules.chats.getRecentChats\",{\"after\":0}]"
        ws.send(msg)
    }
    
    public func updateMessages(recvData:String)
    {
        print("UPDATEMSGS: \(recvData)")
        // I have to delete last char ]"
        let cleanData = recvData.substringWithRange(Range<String.Index>(start: recvData.startIndex, end: recvData.endIndex.advancedBy(-1)))
        
        //print("CLEANED!!")
        //print(cleanData)
        
        do{
            let json = try NSJSONSerialization.JSONObjectWithData(cleanData.dataUsingEncoding(NSUTF8StringEncoding)!, options: .AllowFragments) as? [Dictionary<String, AnyObject>]
            
            // let nextStart = (json!["nextStart"] as? Int)!
            //let users = json!["users"] as? [Dictionary<String, AnyObject>]
            
            for m in json!{
                //print(t["tid"])
                let msg = m["content"] as! String
                print(msg)
                messages.append(msg)
            }
            
            // Main UI Thread
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self.tableView.reloadData()
            })
            
        }catch{
            print("ERROR")
        }
    }
    

}
