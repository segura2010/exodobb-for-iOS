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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // getQuote(post.pid)
        
        let html = "<link rel=\"stylesheet\" type=\"text/css\" href=\"/stylesheet.css\"> \(post.content!)"
        
        webView.loadHTMLString(html, baseURL:URL(string: "http://exo.do/"))
        
        replyTextView.text = "@\(post.userslug!) "
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(PostViewController.DismissKeyboard))
        view.addGestureRecognizer(tap)
        
        // Do any additional setup after loading the view.
    }
    
    func DismissKeyboard(){
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func getQuote(_ pid: Int){
        let msg = "\(messageNum)[\"posts.getRawPost\",\"\(pid)\"]"
        ws.send(msg)
    }
    
    open func updateQuote(_ recvData: String){
        let cleanData = recvData.substring(with: (recvData.startIndex ..< recvData.characters.index(recvData.endIndex, offsetBy: -1)))
        
        self.replyTextView.text = cleanData
    }
    
    
    @IBAction func replyBtnClick(_ sender: AnyObject) {
        var refreshAlert = UIAlertController(title: "Sure?", message: "Send reply?", preferredStyle: UIAlertControllerStyle.alert)
        
        refreshAlert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action: UIAlertAction!) in
            print("Handle Ok logic here")
            let msg = "\(messageNum)[\"posts.reply\",{\"tid\":\(self.post.tid!),\"content\":\"\(self.replyTextView.text!)\",\"lock\":false}]"
            print(msg)
            ws.send(msg)
        }))
        
        refreshAlert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: { (action: UIAlertAction!) in
            print("Handle Cancel Logic here")
        }))
        
        present(refreshAlert, animated: true, completion: nil)
    }
    
    @IBAction func closeBtnClick(_ sender: AnyObject) {
        self.dismiss(animated: true, completion:nil)
    }
    
}
