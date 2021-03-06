//
//  TopicViewController.swift
//  exodoapp
//
//  Created by Alberto on 19/9/15.
//  Copyright © 2015 Alberto. All rights reserved.
//

import UIKit

class TopicViewController: UIViewController, UITableViewDelegate, UITableViewDataSource{
    
    var topic: Thread!
    var actPage = 1
    var maxPage = 1
    
    var posts = [Post]()

    @IBOutlet var closeBtn: UIButton!
    
    @IBOutlet var pageTxt: UITextField!
    @IBOutlet var lastPageBtn: UIButton!
    @IBOutlet var nextPageBtn: UIButton!
    @IBOutlet var backPageBtn: UIButton!
    
    @IBOutlet var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        loadPosts()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // TableView Delegate Functions
    func tableView(_ tableView:UITableView, numberOfRowsInSection section:Int) -> Int
    {
        return posts.count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if let cell = tableView.dequeueReusableCell(withIdentifier: "PostCell", for: indexPath) as? PostCell{
            let p = posts[(indexPath as NSIndexPath).row]
            cell.configureCell(p)
            return cell
        }
        else
        {
            return UITableViewCell()
        }
    }
    // Cell custom actions!!
    @available(iOS 8.0, *)
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        var favAction: UITableViewRowAction
        if (self.posts[(indexPath as NSIndexPath).row].favourited == true){
            favAction = UITableViewRowAction(style: .normal, title: "UNFAV") { (action: UITableViewRowAction!, indexPath: IndexPath!) -> Void in
                let post = self.posts[indexPath.row]
                let pid = post.pid
                let tid = post.tid
                //print("FAV \(pid)")
                NodeBBAPI.sharedInstance.unfavPost(pid!, tid: tid!)
            }
        }else{
            favAction = UITableViewRowAction(style: .normal, title: "FAV") { (action: UITableViewRowAction!, indexPath: IndexPath!) -> Void in
                let post = self.posts[indexPath.row]
                let pid = post.pid
                let tid = post.tid
                //print("FAV \(pid)")
                NodeBBAPI.sharedInstance.favPost(pid!, tid: tid!)
            }
        }
        favAction.backgroundColor = UIColor.orange
        
        let repMoreAction = UITableViewRowAction(style: .normal, title: "+1") { (action: UITableViewRowAction!, indexPath: IndexPath!) -> Void in
            let post = self.posts[indexPath.row]
            let pid = post.pid
            let tid = post.tid
            //print("+1 \(pid)")
            NodeBBAPI.sharedInstance.upvotePost(pid!, tid: tid!)
        }
        repMoreAction.backgroundColor = UIColor.green
        
        let repMinusAction = UITableViewRowAction(style: .normal, title: "-1") { (action: UITableViewRowAction!, indexPath: IndexPath!) -> Void in
            let post = self.posts[indexPath.row]
            let pid = post.pid
            let tid = post.tid
            //print("-1 \(pid)")
            NodeBBAPI.sharedInstance.downvotePost(pid!, tid: tid!)
        }
        repMinusAction.backgroundColor = UIColor.red
        
        return [repMinusAction, repMoreAction, favAction]
        
    }
    
    func loadPosts(){
        
        NodeBBAPI.sharedInstance.getTopicPosts(topic.slug!, page: actPage) { (err, json) in
            
            if let jsonPosts = json?["posts"] as? [Dictionary<String, AnyObject>] {
                self.maxPage = (json?["pagination"] as! [String:AnyObject])["pageCount"] as! Int
                self.posts = [Post]()
                for p in jsonPosts
                {
                    let post = Post(threadDic: p)
                    self.posts.append(post)
                }
            }
            
            // Main UI Thread
            DispatchQueue.main.async(execute: { () -> Void in
                self.tableView.reloadData()
                self.pageTxt.text = "\(self.actPage) / \(self.maxPage)"
            })
            
        }
        
    }

    
    // MARK: - Navigation
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        let postView = segue.destination as! PostViewController
        if let indexPath = self.tableView.indexPath(for: sender as! UITableViewCell){
            let post = posts[(indexPath as NSIndexPath).row]
            postView.post = post
        }
        
    }
    

    @IBAction func lastPageBtnClick(_ sender: AnyObject) {
        pageTxt.text = "\(actPage) / \(maxPage)"
        actPage = maxPage
        loadPosts()
    }
    @IBAction func nextPageBtnClick(_ sender: AnyObject) {
        if(actPage < maxPage)
        {
            actPage = actPage + 1
            loadPosts()
            pageTxt.text = "\(actPage) / \(maxPage)"
        }
    }
    @IBAction func backPageBtnClick(_ sender: AnyObject) {
        if(actPage > 1)
        {
            actPage = actPage - 1
            loadPosts()
            pageTxt.text = "\(actPage) / \(maxPage)"
        }
    }

    @IBAction func closeBtnClick(_ sender: AnyObject) {
        self.dismiss(animated: true, completion:nil)
    }
}
