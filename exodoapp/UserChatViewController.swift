//
//  UserChatViewController.swift
//  exodoapp
//
//  Created by Alberto on 24/9/15.
//  Copyright © 2015 Alberto. All rights reserved.
//

import UIKit

var messages = ["Loading.."]

class UserChatViewController: UIViewController {

    var room:Room!
    
    @IBOutlet var webView: UIWebView!
    @IBOutlet var navigationBar: UINavigationItem!
    @IBOutlet var messageTxt: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationBar.title = room.username
        requestMessages()

        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(animated: Bool) {
        showMessagesOnWebView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // Request Chats
    func requestMessages()
    {
        let msg = "\(messageNum)[\"modules.chats.get\",{\"roomId\":\"\(room.rid)\",\"since\":\"recent\"}]"
        ws.send(msg)
    }
    
    public func updateMessages(recvData:String)
    {
        //print("UPDATEMSGS: \(recvData)")
        // I have to delete last char ]"
        let cleanData = recvData.substringWithRange(Range<String.Index>(start: recvData.startIndex, end: recvData.endIndex.advancedBy(-1)))
        
        //print("CLEANED!!")
        //print(cleanData)
        
        do{
            let json = try NSJSONSerialization.JSONObjectWithData(cleanData.dataUsingEncoding(NSUTF8StringEncoding)!, options: .AllowFragments) as? [Dictionary<String, AnyObject>]
            
            // let nextStart = (json!["nextStart"] as? Int)!
            //let users = json!["users"] as? [Dictionary<String, AnyObject>]
            
            messages = []
            for m in json!{
                //print(t["tid"])
                let msg = m["content"] as! String
                //print(msg)
                messages.insert(msg, atIndex: 0)
            }
            
        }catch{
            print("ERROR")
        }
    }
    
    
    func showMessagesOnWebView(){
        var html = "<link rel=\"stylesheet\" type=\"text/css\" href=\"/stylesheet.css\">"
        
        for m in messages{
            html = "\(html) <hr> \(m)"
        }
        
        self.webView.loadHTMLString(html, baseURL: NSURL(string: "http://exo.do/")!)
    }
    
    
    // Send Message
    func sendMessage()
    {
        let myMsg = messageTxt.text!
        messageTxt.text = ""
        let msg = "\(messageNum)[\"modules.chats.send\",{\"roomId\":\"\(room.rid)\",\"message\":\"\(myMsg)\"}]"
        print(msg)
        ws.send(msg)
    }
    
    @IBAction func sendBtnClick(sender: AnyObject) {
        sendMessage()
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
