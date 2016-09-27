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
        
        let style = "<link rel=\"stylesheet\" type=\"text/css\" href=\"/stylesheet.css\">"
        let scripts = "<script> var spoilers = document.getElementsByClassName('ns-spoiler'); for(var s in spoilers){ spoilers[s].onclick = function(){ this.setAttribute('data-open', 'true') } } </script>"
        let html = "\(style) \(post.content!) \(scripts)"
        
        webView.loadHTMLString(html, baseURL:URL(string: "https://exo.do/"))
        
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
    
    func updateQuote(_ recvData: String){
        let cleanData = recvData.substring(with: (recvData.startIndex ..< recvData.characters.index(recvData.endIndex, offsetBy: -1)))
        
        self.replyTextView.text = cleanData
    }
    
    
    @IBAction func replyBtnClick(_ sender: AnyObject) {
        var refreshAlert = UIAlertController(title: "Sure?", message: "Send reply?", preferredStyle: UIAlertControllerStyle.alert)
        
        refreshAlert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action: UIAlertAction!) in
            NodeBBAPI.sharedInstance.sendPost(self.replyTextView.text!, tid: self.post.tid!)
        }))
        
        refreshAlert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: { (action: UIAlertAction!) in
        }))
        
        present(refreshAlert, animated: true, completion: nil)
    }
    
    @IBAction func closeBtnClick(_ sender: AnyObject) {
        self.dismiss(animated: true, completion:nil)
    }
    
}
