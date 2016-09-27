//
//  FirstViewController.swift
//  exodoapp
//
//  Created by Alberto on 18/9/15.
//  Copyright © 2015 Alberto. All rights reserved.
//

import UIKit
//import SwiftWebSocket


let WS_SERVER = "wss://exo.do/socket.io/?EIO=3&transport=websocket"
var ws = WebSocket("wss://exo.do/socket.io/?EIO=3&transport=websocket")
var messageNum = 421
 

class FirstViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet var indicator: UIActivityIndicatorView!
    @IBOutlet var refreshBtn: UIButton!
    @IBOutlet var loadMoreBtn: UIButton!
    
    @IBOutlet var tableView: UITableView!
    var topics = [Thread]()
    var isRefreshing = false
    var nextStart = 10
    var actPage = 1
    
    let URL_BASE_API = "https://exo.do/api/"
    var cookie = ""
    
    //var messageNum = 421
    //var ws = WebSocket("ws://ws.exo.do/socket.io/?EIO=3&transport=websocket") //"ws://localhost:4567/socket.io/?EIO=3&transport=websocket")
    
    
    // Refresh control
    var refreshControl = UIRefreshControl()
    

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        // USING NEW API
        NodeBBAPI.sharedInstance.useCookie()
        //NodeBBAPI.sharedInstance.initWSEvents()
        // END USING NEW API
        
        // Init refresh control
        refreshControl.tintColor = UIColor.clear
        refreshControl.backgroundColor = UIColor.clear
        refreshControl.addTarget(self, action: #selector(FirstViewController.refreshControlStateChanged), for: .valueChanged)
        
        loadRefreshControl()
        
        self.tableView.addSubview(refreshControl)
        
        tableView.delegate = self
        tableView.dataSource = self
        
        indicator.hidesWhenStopped = true
        
        /*
        cookie = SecondViewController.getCookie()
        
        initWSEvents()
         */
    }
    
    
    func loadRefreshControl()
    {
        var refreshVW = Bundle.main.loadNibNamed("RefreshControlView", owner: self, options: nil)
        
        let customView = refreshVW?[0] as! UIView
        customView.frame = refreshControl.bounds
        
        let customLabel = customView.viewWithTag(1) as! UILabel
        customLabel.textColor = UIColor.white
        customView.backgroundColor = UIColor.orange
        
        /*
        UIView.setAnimationsEnabled(true)
        UIView.animateWithDuration(0.5, delay: 0, options: [.Autoreverse, .CurveLinear, .Repeat], animations: {
            
            customView.backgroundColor = UIColor.orangeColor()
            customView.backgroundColor = UIColor.whiteColor()
            
        }, completion: nil)
         */
        
        
        self.refreshControl.addSubview(customView)
        
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    // TableView Delegate Functions
    func tableView(_ tableView:UITableView, numberOfRowsInSection section:Int) -> Int
    {
        return topics.count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if let cell = tableView.dequeueReusableCell(withIdentifier: "TopicCell", for: indexPath) as? ThreadCell{
            let topic = topics[(indexPath as NSIndexPath).row]
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
        //ws.cookie = SecondViewController.getCookie()
        /*
        let send : ()->() = {
            let msg = "\(++messageNum): \(NSDate().description)"
            print("send: \(msg)")
            self.ws.send(msg)
        }
        */
        ws.event.open = {
            print("opened")
            self.requestUpdateThreads(0)
            // Prepare Ping
            self.Ping()
            self.requestChats()
        }
        ws.event.close = { code, reason, clean in
            print(reason)
            print("close")
            ws = WebSocket(WS_SERVER)
            self.initWSEvents()
        }
        ws.event.error = { error in
            print("error \(error)")
        }
        ws.event.message = { message in
            if let text = message as? String {
                //print("recv: \(text)")
                
                var ierror: NSError?
                // "^([0-9]+\\[null,)"
                var data = ""
                do{
                    var regex = try NSRegularExpression(pattern: "^([0-9]+\\[null,)", options: NSRegularExpression.Options.caseInsensitive)
                    data = regex.stringByReplacingMatches(in: text, options: NSRegularExpression.MatchingOptions.anchored, range: NSMakeRange(0, text.characters.count), withTemplate: "")
                    
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
                    if(self.isRefreshing)
                    {
                        self.isRefreshing = false
                        self.topics = [Thread]()
                    }
                    //self.updateThreads(data)
                    self.refreshControl.endRefreshing()
                }
                else if(data.hasPrefix("{\"privileges\":") || data.hasPrefix("{\"posts\":"))
                {   // Posts for topic received
                    //self.updateThreads(data)
                }
                else if(data.hasPrefix("{\"rooms\":"))
                {   // Chats received
                    // Get chats view controller, and call update function
                    let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                    var ChatsVC = mainStoryboard.instantiateViewController(withIdentifier: "ChatVC") as! ChatTableViewController
                    //ChatsVC.updateChats(data)
                }
                else if(data.hasPrefix("[{\"content\""))
                {   // Chats received
                    // Get chats view controller, and call update function
                    let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                    var MessagesVC = mainStoryboard.instantiateViewController(withIdentifier: "UserChatVC") as! UserChatViewController
                    //MessagesVC.updateMessages(data)
                }
                /* else if(data.hasPrefix("\"")){
                    let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                    var postVC = mainStoryboard.instantiateViewControllerWithIdentifier("PostVC") as! PostViewController
                    postVC.updateQuote(data)
                }*/
                
            }
        }
    }
    
    
    func requestUpdateThreads(_ page:Int)
    {
        self.indicator.startAnimating()
        /*
        let msg = "\(messageNum)[\"topics.loadMoreFromSet\",{\"after\":\"\(start)\",\"set\":\"topics:recent\"}]"
        ws.send(msg)
        */
        
        NodeBBAPI.sharedInstance.getRecentTopics(page) { (err, json) in
            self.nextStart = (json!["nextStart"] as? Int)!
            let jsonTopics = json!["topics"] as? [Dictionary<String, AnyObject>]
            
            if self.actPage == 1
            {
                self.topics = [Thread]()
            }
            
            for t in jsonTopics!{
                //print(t["tid"])
                let topic = Thread(threadDic: t)
                //print(topic.title)
                self.topics.append(topic)
            }
            
            // Main UI Thread
            DispatchQueue.main.async(execute: { () -> Void in
                self.tableView.reloadData()
                self.indicator.stopAnimating()
                self.refreshControl.endRefreshing()
            })
        }
        
    }
    
    
    // Buttons Actions
    @IBAction func refreshBtnClick(_ sender: AnyObject) {
        actPage = 1
        requestUpdateThreads(actPage)
    }
    
    @IBAction func loadMoreBtnClick(_ sender: AnyObject) {
        actPage = actPage + 1
        requestUpdateThreads(actPage)
    }
    
    @IBAction func readAllBtnClick(_ sender: AnyObject) {
        //NodeBBAPI.sharedInstance.markAllTopicsAsRead()
        actPage = actPage + 1
        requestUpdateThreads(actPage)
    }
    
    // Table details
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        let topicView = segue.destination as! TopicViewController
        if let indexPath = self.tableView.indexPath(for: sender as! UITableViewCell){
            if((indexPath as NSIndexPath).row < topics.count){
                let topic = topics[(indexPath as NSIndexPath).row]
                topicView.topic = topic
                topicView.cookie = self.cookie
                
                //NodeBBAPI.sharedInstance.markTopicAsRead(topic.tid)
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
        var time = DispatchTime.now() + Double(delta) / Double(NSEC_PER_SEC)
        DispatchQueue.main.asyncAfter(deadline: time, execute: {
            self.Ping()
        })
    }
    
    
    func refreshControlStateChanged()
    {
        print("changed")
        isRefreshing = true
        actPage = 1
        self.requestUpdateThreads(actPage)
    }

}

