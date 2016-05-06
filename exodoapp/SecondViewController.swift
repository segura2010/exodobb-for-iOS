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
    
    let LOGIN_URL = "http://exo.do/login"
    
    @IBOutlet var usernameTxt: UITextField!
    
    @IBOutlet var passwordTxt: UITextField!
    
    
    var users = [NSManagedObject]()
    
    var csrf: String!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        var cookie = SecondViewController.getCookie()
        
        var tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "DismissKeyboard")
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
    
    
    func saveCookie(name: String) {
        //1
        let appDelegate =
        UIApplication.sharedApplication().delegate as! AppDelegate
        
        let managedContext: NSManagedObjectContext = appDelegate.managedObjectContext!
        
        //2
        let entity =  NSEntityDescription.entityForName("User", inManagedObjectContext: managedContext)
        
        let user = NSManagedObject(entity: entity!, insertIntoManagedObjectContext:managedContext)
        
        //3
        user.setValue(name, forKey: "cookie")
        
        //4
        do{
            try managedContext.save()
        }catch{
            print("Could not save..")
        }  
        //5
        //people.append(person)
        SecondViewController.getCookie()
    }
    
    
    class func getCookie() -> String
    {
        //1
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        
        let managedContext = appDelegate.managedObjectContext!
        
        //2
        let fetchRequest = NSFetchRequest(entityName:"User")
        
        var cookie = ""
        //3
        do{
            let fetchedResults = try managedContext.executeFetchRequest(fetchRequest) as? [NSManagedObject]
            if let results = fetchedResults {
                //print(results)
                if results.count > 0 {
                    cookie = (results.last?.valueForKey("cookie"))! as! String
                }
            } else {
                print("Could not fetch")
            }
        }catch{
            print("Error getCookie")
        }
        
        return cookie
    }

    
    func getCSRF()
    {
        let request = NSMutableURLRequest(URL: NSURL(string: LOGIN_URL)!)
        let session = NSURLSession.sharedSession()
        request.HTTPMethod = "GET"
        
        var csrf = ""
        
        do {
            //request.HTTPBody = params.dataUsingEncoding(NSUTF8StringEncoding)
            //request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            //request.addValue("application/json", forHTTPHeaderField: "Accept")
            
            let task = session.dataTaskWithRequest(request, completionHandler: {data, response, error -> Void in
                do{
                    //print("Response: \(response)")
                    //let res = response as! NSHTTPURLResponse
                    //print(data)
                    
                    
                    //var rgx = "\\\"csrf_token\\\":\\\".*\\\""
                    //let regex = try NSRegularExpression(pattern: "[0-9]", options: NSRegularExpressionOptions.CaseInsensitive)
                    
                    let nsString = NSString(data: data!, encoding: NSUTF8StringEncoding)
                    var text = nsString as! String
                    
                    //print(text)
                    //let results = regex.matchesInString(text, options: NSMatchingOptions.Anchored, range: NSMakeRange(0, text.characters.count)) as! [NSTextCheckingResult]
                    //print("Results: \(results.count)")
                    /*
                    for m in results{
                        let str = nsString!.substringWithRange(m.range)
                        print(str)
                    }*/
                    
                    // Example: "csrf_token":""
                    var ini = text.rangeOfString("csrf_token")
                    //print("Contains: \(ini)")
                    csrf = text.substringFromIndex((ini?.indices.last?.advancedBy(4))!)
                    //print(csrf)
                    var fin = csrf.rangeOfString("\"")
                    self.csrf = csrf.substringToIndex((fin?.indices.first)!)
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
    
    @IBAction func logInBtnClick(sender: AnyObject) {
        
        getCSRF()
        //saveCookie(usernameTxt.text!)
    }
    
    
    func login()
    {
        let request = NSMutableURLRequest(URL: NSURL(string: LOGIN_URL)!)
        let session = NSURLSession.sharedSession()
        request.HTTPMethod = "POST"
        
        let params = "username=\(usernameTxt.text!)&password=\(passwordTxt.text!)&returnTo=http://exo.do/recent"
        print(self.csrf)
        
        do {
            request.HTTPBody = params.dataUsingEncoding(NSUTF8StringEncoding)
            request.addValue(self.csrf, forHTTPHeaderField: "x-csrf-token")
            request.addValue("gzip, deflate", forHTTPHeaderField: "Accept-Encoding")
            request.addValue("XMLHttpRequest", forHTTPHeaderField: "X-Requested-With")
            request.addValue("application/x-www-form-urlencoded; charset=UTF-8", forHTTPHeaderField: "Content-Type")
            
            let task = session.dataTaskWithRequest(request, completionHandler: {data, response, error -> Void in
                do{
                    //print("Response: \(response)")
                    let res = response as! NSHTTPURLResponse
                    print(res)
                    if res.statusCode == 200{
                        if let cookie = res.allHeaderFields["Set-Cookie"]{
                            print(cookie)
                            self.saveCookie(cookie as! String)
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
    

}

