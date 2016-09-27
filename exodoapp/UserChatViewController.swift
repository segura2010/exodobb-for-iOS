//
//  UserChatViewController.swift
//  exodoapp
//
//  Created by Alberto on 24/9/15.
//  Copyright © 2015 Alberto. All rights reserved.
//

import UIKit


class UserChatViewController: UIViewController {

    var room:Room!
    
    @IBOutlet var webView: UIWebView!
    @IBOutlet var navigationBar: UINavigationItem!
    @IBOutlet var messageTxt: UITextField!
    
    var messages = ["Error!"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationBar.title = room.username
        requestMessages()

        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        showMessagesOnWebView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // Request Chats
    func requestMessages()
    {
        NodeBBAPI.sharedInstance.getChatRoom(room.rid) { (err, json) in
            
            self.messages = []
            if let msgs = json?["messages"] as? [Dictionary<String, AnyObject>]
            {
                for m in msgs{
                    //print(t["tid"])
                    let msg = m["content"] as! String
                    //print(msg)
                    self.messages.insert(msg, at: 0)
                }
            }
            
            // Main UI Thread
            DispatchQueue.main.async(execute: { () -> Void in
                self.showMessagesOnWebView()
            })
            
        }
    }
    
    
    func showMessagesOnWebView(){
        var html = "<link rel=\"stylesheet\" type=\"text/css\" href=\"/stylesheet.css\">"
        
        for m in messages{
            html = "\(html) <hr> \(m)"
        }
        
        self.webView.loadHTMLString(html, baseURL: URL(string: "http://exo.do/")!)
    }
    
    
    // Send Message
    func sendMessage()
    {
        let myMsg = messageTxt.text!
        messageTxt.text = ""
        NodeBBAPI.sharedInstance.sendChatMessage(myMsg, roomId: room.rid)
    }
    
    @IBAction func sendBtnClick(_ sender: AnyObject) {
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
