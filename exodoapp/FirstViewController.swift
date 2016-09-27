//
//  FirstViewController.swift
//  exodoapp
//
//  Created by Alberto on 18/9/15.
//  Copyright © 2015 Alberto. All rights reserved.
//

import UIKit


class FirstViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet var indicator: UIActivityIndicatorView!
    @IBOutlet var refreshBtn: UIButton!
    @IBOutlet var loadMoreBtn: UIButton!
    
    @IBOutlet var tableView: UITableView!
    var topics = [Thread]()
    var isRefreshing = false
    var nextStart = 10
    var actPage = 1
    
    
    // Refresh control
    var refreshControl = UIRefreshControl()
    

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        // USING NEW API
        NodeBBAPI.sharedInstance.useCookie()
        NodeBBAPI.sharedInstance.initWSEvents()
        // END USING NEW API
        
        requestUpdateThreads(actPage)
        
        // Init refresh control
        refreshControl.tintColor = UIColor.clear
        refreshControl.backgroundColor = UIColor.clear
        refreshControl.addTarget(self, action: #selector(FirstViewController.refreshControlStateChanged), for: .valueChanged)
        
        loadRefreshControl()
        
        self.tableView.addSubview(refreshControl)
        
        tableView.delegate = self
        tableView.dataSource = self
        
        indicator.hidesWhenStopped = true
        
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
    
    
    func requestUpdateThreads(_ page:Int)
    {
        self.indicator.startAnimating()
        
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
        NodeBBAPI.sharedInstance.markAllTopicsAsRead()
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
                
                //NodeBBAPI.sharedInstance.markTopicAsRead(topic.tid)
            }
        }
        
    }
    
    func refreshControlStateChanged()
    {
        print("changed")
        isRefreshing = true
        actPage = 1
        self.requestUpdateThreads(actPage)
    }

}

