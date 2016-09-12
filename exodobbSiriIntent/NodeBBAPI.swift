//
//  NodeBBAPI.swift
//  exodoapp
//
//  Created by Alberto on 12/9/16.
//  Copyright © 2016 Alberto. All rights reserved.
//

import Foundation

// For callbacks
typealias ServiceResponse = (NSError?, [String:AnyObject]?) -> Void
typealias ServiceBoolResponse = (NSError?, Bool) -> Void

class NodeBBAPI {
    static let sharedInstance = NodeBBAPI()
    
    let BASE_URL = "https://exo.do/api/"
    
    let WS_SERVER = "wss://exo.do/socket.io/?EIO=3&transport=websocket"
    var ws:WebSocket
    var messageNum = 421
    
    init() {
        ws = WebSocket(WS_SERVER)
    }
    
    func get(_ url:String, cookie:String, onCompletion:ServiceResponse)
    {
        let finalUrl = "\(BASE_URL)\(url)"
        var request = URLRequest(url: URL(string: finalUrl)!)
        let session = URLSession.shared
        request.httpMethod = "GET"
        
        do {
            request.addValue(cookie, forHTTPHeaderField: "Cookie")
            request.addValue("gzip, deflate", forHTTPHeaderField: "Accept-Encoding")
            request.addValue("XMLHttpRequest", forHTTPHeaderField: "X-Requested-With")
            
            let task = session.dataTask(with: request, completionHandler: {data, response, error -> Void in
                do{
                    //print("Response: \(response)")
                    let res = response as! HTTPURLResponse
                    //print(res)
                    
                    let strData = NSString(data: data!, encoding: String.Encoding.utf8.rawValue)
                    //print("Body: \(strData)")
                    let json = try JSONSerialization.jsonObject(with: data!, options: .mutableLeaves) as? [String:AnyObject]
                    
                    if res.statusCode == 200{
                        onCompletion(nil, json)
                    }else{
                        onCompletion(NSError(domain: "get", code: 999, userInfo: nil), nil)
                    }
                }catch{
                    print("Error:\n \(error)")
                    onCompletion(NSError(domain: "get", code: 998, userInfo: nil), nil)
                }
                
            })
            
            task.resume()
        }catch{
            print("Error:\n \(error)")
            return
        }
    }
    
    func searchTopicByTitle(_ term:String, cookie:String, onCompletion:ServiceResponse)
    {
        let path = "search/\(term)?in=titles".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        
        get(path!, cookie: cookie, onCompletion: onCompletion)
    }
    
    
    func initWSEvents(){
        
        ws = WebSocket(WS_SERVER)
        ws.event.open = {
            print("opened")
        }
        ws.event.close = { code, reason, clean in
            print(reason)
            print("close")
            self.ws = WebSocket(self.WS_SERVER)
            self.initWSEvents()
        }
        ws.event.error = { error in
            print("error \(error)")
        }
        ws.event.message = { message in
            if let text = message as? String {
                
            }
        }
    }
 
    func sendPost(_ message:String, tid:String)
    {
        let msg = "\(messageNum)[\"posts.reply\",{\"tid\":\(tid),\"content\":\"\(message)\",\"lock\":false}]"
        ws.send(msg)
    }
 
    
    func getCookie() -> String
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
 
}

