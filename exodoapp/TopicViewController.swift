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
    var maxPage = 0
    
    var posts = [Post]()
    
    var BASE_URL = "http://exo.do/api/"
    var cookie: String!
    //var ws = nil

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
        
        loadPosts(actPage)

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // TableView Delegate Functions
    func tableView(tableView:UITableView, numberOfRowsInSection section:Int) -> Int
    {
        return posts.count
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        if let cell = tableView.dequeueReusableCellWithIdentifier("PostCell", forIndexPath: indexPath) as? PostCell{
            let p = posts[indexPath.row]
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
    func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]? {
        
        var favAction: UITableViewRowAction
        if (self.posts[indexPath.row].favourited == true){
            favAction = UITableViewRowAction(style: .Normal, title: "UNFAV") { (action: UITableViewRowAction!, indexPath: NSIndexPath!) -> Void in
                let post = self.posts[indexPath.row]
                let pid = post.pid
                let tid = post.tid
                //print("FAV \(pid)")
                self.unfavPost(pid, tid: tid)
            }
        }else{
            favAction = UITableViewRowAction(style: .Normal, title: "FAV") { (action: UITableViewRowAction!, indexPath: NSIndexPath!) -> Void in
                let post = self.posts[indexPath.row]
                let pid = post.pid
                let tid = post.tid
                //print("FAV \(pid)")
                self.favPost(pid, tid: tid)
            }
        }
        favAction.backgroundColor = UIColor.orangeColor()
        
        var repMoreAction = UITableViewRowAction(style: .Normal, title: "+1") { (action: UITableViewRowAction!, indexPath: NSIndexPath!) -> Void in
            let post = self.posts[indexPath.row]
            let pid = post.pid
            let tid = post.tid
            //print("+1 \(pid)")
            self.upvotePost(pid, tid: tid)
        }
        repMoreAction.backgroundColor = UIColor.greenColor()
        
        var repMinusAction = UITableViewRowAction(style: .Normal, title: "-1") { (action: UITableViewRowAction!, indexPath: NSIndexPath!) -> Void in
            let post = self.posts[indexPath.row]
            let pid = post.pid
            let tid = post.tid
            //print("-1 \(pid)")
            self.downvotePost(pid, tid: tid)
        }
        repMinusAction.backgroundColor = UIColor.redColor()
        
        return [repMinusAction, repMoreAction, favAction]
        
    }
    
    
    
    func loadPosts(page: Int){
        //print(page)
        actPage = page
        pageTxt.text = actPage as? String
        
        let url = "topic/\(topic.slug)/?page=\(actPage)".stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLFragmentAllowedCharacterSet())
        
        let request = NSMutableURLRequest(URL: NSURL(string: BASE_URL + url!)!)
        let session = NSURLSession.sharedSession()
        request.HTTPMethod = "GET"
        
        do {
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.addValue("application/json", forHTTPHeaderField: "Accept")
            request.addValue(cookie, forHTTPHeaderField: "Cookie")
            
            let task = session.dataTaskWithRequest(request, completionHandler: {data, response, error -> Void in
                do{
                    print("Response: \(response)")
                    let strData = NSString(data: data!, encoding: NSUTF8StringEncoding)
                    //print("Body: \(strData)")
                    let json = try NSJSONSerialization.JSONObjectWithData(data!, options: .MutableLeaves) as? NSDictionary
                    
                    // The JSONObjectWithData constructor didn't return an error. But, we should still
                    // check and make sure that json has a value using optional binding.
                    if let parseJSON = json
                    {
                        
                        if let posts = parseJSON["posts"] as? [Dictionary<String, AnyObject>] {
                            self.maxPage = parseJSON["pagination"]!["pageCount"] as! Int
                            self.posts = [Post]()
                            for p in posts
                            {
                                let post = Post(threadDic: p)
                                self.posts.append(post)
                            }
                        }
                        
                        // Main UI Thread
                        dispatch_async(dispatch_get_main_queue(), { () -> Void in
                            self.tableView.reloadData()
                            self.pageTxt.text = "\(self.actPage) / \(self.maxPage)"
                        })
                    }
                    else
                    {
                        // Woa, okay the json object was nil, something went worng. Maybe the server isn't running?
                        let jsonStr = NSString(data: data!, encoding: NSUTF8StringEncoding)
                        print("Error could not parse JSON: \(jsonStr)")
                    }
                }catch{
                    print("Error:\n \(error)")
                    return
                }
                
            })
            
            task.resume()
        }catch{
            print("Error:\n \(error)")
            return
        }
    }
    
    func favPost(pid: Int, tid:Int){
        let msg = "\(messageNum)[\"posts.favourite\",{\"pid\":\"\(pid)\",\"room_id\":\"topic_\(tid)\"}]"
        ws.send(msg)
    }
    func unfavPost(pid: Int, tid:Int){
        let msg = "\(messageNum)[\"posts.unfavourite\",{\"pid\":\"\(pid)\",\"room_id\":\"topic_\(tid)\"}]"
        ws.send(msg)
    }
    
    func upvotePost(pid: Int, tid:Int){
        let msg = "\(messageNum)[\"posts.upvote\",{\"pid\":\"\(pid)\",\"room_id\":\"topic_\(tid)\"}]"
        ws.send(msg)
    }
    func downvotePost(pid: Int, tid:Int){
        let msg = "\(messageNum)[\"posts.downvote\",{\"pid\":\"\(pid)\",\"room_id\":\"topic_\(tid)\"}]"
        ws.send(msg)
    }
    

    
    // MARK: - Navigation
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        var postView = segue.destinationViewController as! PostViewController
        if let indexPath = self.tableView.indexPathForCell(sender as! UITableViewCell){
            let post = posts[indexPath.row]
            postView.post = post
        }
        
    }
    

    @IBAction func lastPageBtnClick(sender: AnyObject) {
        pageTxt.text = "\(actPage) / \(maxPage)"
        actPage = maxPage
        loadPosts(maxPage)
    }
    @IBAction func nextPageBtnClick(sender: AnyObject) {
        if(actPage < maxPage)
        {
            actPage = actPage + 1
            loadPosts(actPage)
            pageTxt.text = "\(actPage) / \(maxPage)"
        }
    }
    @IBAction func backPageBtnClick(sender: AnyObject) {
        if(actPage > 1)
        {
            actPage = actPage - 1
            loadPosts(actPage)
            pageTxt.text = "\(actPage) / \(maxPage)"
        }
    }

    @IBAction func closeBtnClick(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion:nil)
    }
}
