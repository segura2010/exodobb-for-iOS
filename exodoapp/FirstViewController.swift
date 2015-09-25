//
//  FirstViewController.swift
//  exodoapp
//
//  Created by Alberto on 18/9/15.
//  Copyright © 2015 Alberto. All rights reserved.
//

import UIKit
//import SwiftWebSocket

var ws = WebSocket("ws://ws.exo.do/socket.io/?EIO=3&transport=websocket")
var messageNum = 421

class FirstViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet var indicator: UIActivityIndicatorView!
    @IBOutlet var refreshBtn: UIButton!
    @IBOutlet var loadMoreBtn: UIButton!
    
    @IBOutlet var tableView: UITableView!
    var topics = [Thread]()
    var nextStart = 10
    
    let URL_BASE_API = "http://exo.do/api/"
    var cookie = ""
    
    //var messageNum = 421
    //var ws = WebSocket("ws://ws.exo.do/socket.io/?EIO=3&transport=websocket") //"ws://localhost:4567/socket.io/?EIO=3&transport=websocket")

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        
        indicator.hidesWhenStopped = true
        
        cookie = SecondViewController.getCookie()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        initWSEvents()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    // TableView Delegate Functions
    func tableView(tableView:UITableView, numberOfRowsInSection section:Int) -> Int
    {
        return topics.count
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        if let cell = tableView.dequeueReusableCellWithIdentifier("TopicCell", forIndexPath: indexPath) as? ThreadCell{
            let topic = topics[indexPath.row]
            cell.configureCell(topic)
            return cell
        }
        else
        {
            return UITableViewCell()
        }
    }
    
    
    func initWSEvents(){
        //var messageNum = 421
        //ws.cookie = "express.sid=s%3ARcOxAKcpMiM9vurdvs29uBIznGJEJv9x.HK0oLZ4yslsdHeEsqfeYn9TdGxdjZgTfoz8Sw%2BkqYvM"
        /*
        let send : ()->() = {
            let msg = "\(++messageNum): \(NSDate().description)"
            print("send: \(msg)")
            self.ws.send(msg)
        }
        */
        ws.event.open = {
            print("opened")
        }
        ws.event.close = { code, reason, clean in
            print("close")
            ws = WebSocket("ws://ws.exo.do/socket.io/?EIO=3&transport=websocket")
            self.initWSEvents()
        }
        ws.event.error = { error in
            print("error \(error)")
        }
        ws.event.message = { message in
            if let text = message as? String {
                print("recv: \(text)")
                
                var ierror: NSError?
                // "^([0-9]+\\[null,)"
                var data = ""
                do{
                    var regex = try NSRegularExpression(pattern: "^([0-9]+\\[null,)", options: NSRegularExpressionOptions.CaseInsensitive)
                    data = regex.stringByReplacingMatchesInString(text, options: NSMatchingOptions.Anchored, range: NSMakeRange(0, text.characters.count), withTemplate: "")
                    
                }catch{}
                
                if(data.hasSuffix("connect\"]"))
                {
                    print("isConnect!!")
                    
                    self.requestUpdateThreads(0)
                    self.requestChats()
                    
                    let msg = "\(messageNum)[\"meta.rooms.enter\",{\"enter\":\"recent_topics\",\"username\":\"\",\"userslug\":\"\",\"picture\":\"\",\"status\":\"online\"}]"
                    ws.send(msg)
                    
                    // Prepare Ping
                    self.Ping()
                }
                else if(data.hasPrefix("{\"topics\":"))
                {   // Topics received
                    self.updateThreads(data)
                }
                else if(data.hasPrefix("{\"privileges\":") || data.hasPrefix("{\"posts\":"))
                {   // Posts for topic received
                    self.updateThreads(data)
                }
                else if(data.hasPrefix("{\"users\":"))
                {   // Chats received
                    // Get chats view controller, and call update function
                    let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                    var ChatsVC = mainStoryboard.instantiateViewControllerWithIdentifier("ChatVC") as! ChatTableViewController
                    ChatsVC.updateChats(data)
                }
                else if(data.hasPrefix("[{\"_key\""))
                {   // Chats received
                    // Get chats view controller, and call update function
                    let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                    var MessagesVC = mainStoryboard.instantiateViewControllerWithIdentifier("UserChatVC") as! UserChatViewController
                    MessagesVC.updateMessages(data)
                }
                
            }
        }
    }
    
    
    func requestUpdateThreads(start:Int)
    {
        self.indicator.startAnimating()
        let msg = "\(messageNum)[\"topics.loadMoreFromSet\",{\"after\":\"\(start)\",\"set\":\"topics:recent\"}]"
        ws.send(msg)
    }
    
    func updateThreads(recvData:String)
    {
        // I have to delete: 432[null,{\"topics\":"
        let cleanData = recvData.substringWithRange(Range<String.Index>(start: recvData.startIndex, end: recvData.endIndex.advancedBy(-1)))
        
        //print("CLEANED!!")
        //print(cleanData)
        
        do{
            let json = try NSJSONSerialization.JSONObjectWithData(cleanData.dataUsingEncoding(NSUTF8StringEncoding)!, options: .AllowFragments) as? Dictionary<String, AnyObject>
            
            nextStart = (json!["nextStart"] as? Int)!
            let topics = json!["topics"] as? [Dictionary<String, AnyObject>]
            
            for t in topics!{
                //print(t["tid"])
                let topic = Thread(threadDic: t)
                //print(topic.title)
                self.topics.append(topic)
            }
            
            // Main UI Thread
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self.tableView.reloadData()
                self.indicator.stopAnimating()
            })
            
        }catch{
            print("ERROR")
        }
    }
    
    func markAsRead(id:Int)
    {
        let msg = "\(messageNum)[\"topics.markAsRead\",[\(id)]]"
        ws.send(msg)
    }
    
    
    // Buttons Actions
    @IBAction func refreshBtnClick(sender: AnyObject) {
        topics = [Thread]()
        requestUpdateThreads(0)
    }
    
    @IBAction func loadMoreBtnClick(sender: AnyObject) {
        self.indicator.startAnimating()
        requestUpdateThreads(nextStart)
    }
    
    @IBAction func readAllBtnClick(sender: AnyObject) {
        indicator.startAnimating()
        let msg = "\(messageNum)[\"topics.markAllRead\"]"
        ws.send(msg)
        topics = [Thread]()
        requestUpdateThreads(0)
    }
    
    // Table details
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        var topicView = segue.destinationViewController as! TopicViewController
        if let indexPath = self.tableView.indexPathForCell(sender as! UITableViewCell){
            if(indexPath.row < topics.count){
                let topic = topics[indexPath.row]
                topicView.topic = topic
                topicView.cookie = self.cookie
                markAsRead(topic.tid)
            }
        }
        
    }
    
    // Request Chats
    func requestChats()
    {
        let msg = "\(messageNum)[\"modules.chats.getRecentChats\",{\"after\":0}]"
        ws.send(msg)
    }
    
    
    // WebSockets Ping
    func Ping(){
        //print("Ping..")
        ws.send("2") // Send ping..
        var delta: Int64 = 10 * Int64(NSEC_PER_SEC)
        var time = dispatch_time(DISPATCH_TIME_NOW, delta)
        dispatch_after(time, dispatch_get_main_queue(), {
            self.Ping()
        })
    }

}

