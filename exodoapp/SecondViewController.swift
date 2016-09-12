//
//  SecondViewController.swift
//  exodoapp
//
//  Created by Alberto on 18/9/15.
//  Copyright © 2015 Alberto. All rights reserved.
//

import UIKit
import CoreData

class SecondViewController: UIViewController {
    
    let LOGIN_URL = "https://exo.do/login"
    
    @IBOutlet var usernameTxt: UITextField!
    
    @IBOutlet var passwordTxt: UITextField!
    
    
    var users = [NSManagedObject]()
    
    var csrf: String!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        var cookie = SecondViewController.getCookie()
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(SecondViewController.DismissKeyboard))
        view.addGestureRecognizer(tap)
        
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    func DismissKeyboard(){
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func getCSRF()
    {
        var request = URLRequest(url: URL(string: LOGIN_URL)!)
        let session = URLSession.shared
        request.httpMethod = "GET"
        
        var csrf = ""
        
        do {
            
            let task = session.dataTask(with: request, completionHandler: {data, response, error -> Void in
                do{
                    //print("Response: \(response)")
                    //let res = response as! NSHTTPURLResponse
                    //print(data)
                    
                    let nsString = NSString(data: data!, encoding: String.Encoding.utf8.rawValue)
                    var text = nsString as! String
                    
                    var matchs = self.matches(for:"\"csrf_token\":\"([^\"]+)", in: text)
                    var csrf_str = "\"csrf_token\":\""
                    //print(matchs[0])
                    self.csrf = matchs[0].replacingOccurrences(of: csrf_str, with: "") //substring(from: 14 as Int)
                    //print(csrf)
                    self.login()
                    
                }catch{
                    print("Error:\n \(error)")
                    return
                }
                
            })
            
            task.resume()
        }catch{
            print("Error:\n")
        }
    }
    
    @IBAction func logInBtnClick(_ sender: AnyObject) {
        
        getCSRF()
        //saveCookie(usernameTxt.text!)
    }
    
    
    func login()
    {
        var request = URLRequest(url: URL(string: LOGIN_URL)!)
        let session = URLSession.shared
        request.httpMethod = "POST"
        
        let params = "username=\(usernameTxt.text!)&password=\(passwordTxt.text!)&returnTo=https://exo.do/recent"
        print(self.csrf)
        
        do {
            request.httpBody = params.data(using: String.Encoding.utf8)
            request.addValue(self.csrf, forHTTPHeaderField: "x-csrf-token")
            request.addValue("gzip, deflate", forHTTPHeaderField: "Accept-Encoding")
            request.addValue("XMLHttpRequest", forHTTPHeaderField: "X-Requested-With")
            request.addValue("application/x-www-form-urlencoded; charset=UTF-8", forHTTPHeaderField: "Content-Type")
            
            let task = session.dataTask(with: request, completionHandler: {data, response, error -> Void in
                do{
                    //print("Response: \(response)")
                    let res = response as! HTTPURLResponse
                    print(res)
                    if res.statusCode == 200{
                        if let cookie = res.allHeaderFields["Set-Cookie"]{
                            print(cookie)
                            self.saveCookie(cookie: cookie as! String)
                            exit(0)
                        }
                    }else{
                        //self.usernameTxt.text = "Invalid username/password"
                        //self.passwordTxt.text = ""
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
    
    
    class func getCookie() -> String
    {
        let defaults = UserDefaults(suiteName: "group.exodobb")
        
        if let cookie = defaults?.string(forKey: "cookie") {
            print("getCookie() -> \(cookie)")
            return cookie
        }
        else{
            return ""
        }
    }
    
    func saveCookie(cookie:String)
    {
        /*
        let defaults = UserDefaults.standard
        
        defaults.setValue(cookie, forKey: "cookie")
        
        defaults.synchronize()
         */
        
        let defaults = UserDefaults(suiteName: "group.exodobb")
        
        defaults?.setValue(cookie, forKey: "cookie")
        
        defaults?.synchronize()
    }
    
    func matches(for regex: String, in text: String) -> [String] {
        
        do {
            let regex = try NSRegularExpression(pattern: regex)
            let nsString = text as NSString
            let results = regex.matches(in: text, range: NSRange(location: 0, length: nsString.length))
            return results.map { nsString.substring(with: $0.range)}
        } catch let error as NSError {
            print("invalid regex: \(error.localizedDescription)")
            return []
        }
    }
    

}

