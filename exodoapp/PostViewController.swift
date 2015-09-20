//
//  PostViewController.swift
//  exodoapp
//
//  Created by Alberto on 20/9/15.
//  Copyright © 2015 Alberto. All rights reserved.
//

import UIKit

class PostViewController: UIViewController {
    
    @IBOutlet var webView: UIWebView!
    
    @IBOutlet var replyTextView: UITextView!
    @IBOutlet var replyBtn: UIButton!
    
    @IBOutlet var closeBtn: UIButton!
    
    var post: Post!
    
    
    var cookie = "express.sid=s%3A__-ac0uagDGV9Bvke068pPaIUrCDw5pK.Mo0UrV%2FKBZCEgmAbkx91E0X%2Bkh9fiYa0%2B9xvD%2BcGwS0;"
    
    var messageNum = 421
    var ws = WebSocket("ws://ws.exo.do/socket.io/?EIO=3&transport=websocket")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        var html = "<link rel=\"stylesheet\" type=\"text/css\" href=\"/stylesheet.css\"> \(post.content)"
        
        webView.loadHTMLString(html, baseURL:NSURL(string: "http://exo.do/"))
        
        replyTextView.text = "@\(post.userslug) "
        
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func initWSEvents(){
        ws.event.open = {
            print("opened")
        }
        ws.event.close = { code, reason, clean in
            print("close")
            self.replyTextView.editable = false
        }
        ws.event.error = { error in
            print("error \(error)")
            self.replyTextView.editable = false
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
                    
                    self.replyTextView.editable = true
                    
                    //let msg = "\(++self.messageNum)[\"meta.rooms.enter\",{\"enter\":\"recent_topics\",\"username\":\"\",\"userslug\":\"\",\"picture\":\"\",\"status\":\"online\"}]"
                    //self.ws.send(msg)
                    
                }
                else if(data.hasPrefix("{\"topics\":"))
                {   // Topics received
                    //self.updateThreads(data)
                }
                
                /*
                if messageNum == 10 {
                ws.close()
                } else {
                send()
                }
                */
                
            }
        }
    }
    
    
    
    @IBAction func replyBtnClick(sender: AnyObject) {
        var refreshAlert = UIAlertController(title: "Sure?", message: "Send reply?", preferredStyle: UIAlertControllerStyle.Alert)
        
        refreshAlert.addAction(UIAlertAction(title: "Ok", style: .Default, handler: { (action: UIAlertAction!) in
            print("Handle Ok logic here")
            let msg = "\(++self.messageNum)[\"posts.reply\",{\"tid\":\(self.post.tid),\"content\":\"\(self.replyTextView.text)\",\"lock\":false}]"
            print(msg)
            self.ws.send(msg)
        }))
        
        refreshAlert.addAction(UIAlertAction(title: "Cancel", style: .Default, handler: { (action: UIAlertAction!) in
            print("Handle Cancel Logic here")
        }))
        
        presentViewController(refreshAlert, animated: true, completion: nil)
    }
    
    @IBAction func closeBtnClick(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion:nil)
    }
    
}
