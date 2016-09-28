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

// Global..
let WS_SERVER = "wss://exo.do/socket.io/?EIO=3&transport=websocket"
var ws = WebSocket(WS_SERVER)
var messageNum = 421

class NodeBBAPI {
    static let sharedInstance = NodeBBAPI()
    
    let BASE_URL = "https://exo.do/api/"
    var COOKIE:String
    
    init() {
        COOKIE = ""
    }
    
    func get(_ url:String, cookie:String, onCompletion:@escaping ServiceResponse)
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
    
    
    // REST API Methods
    func searchTopicByTitle(_ term:String, cookie:String, onCompletion:@escaping ServiceResponse)
    {
        let path = "search/\(term)?in=titles".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        
        get(path!, cookie: cookie, onCompletion: onCompletion)
    }
    
    func getRecentTopics(_ page:Int, onCompletion:@escaping ServiceResponse)
    {
        let path = "recent?page=\(page)"
        
        get(path, cookie: COOKIE, onCompletion: onCompletion)
    }
    
    func getTopicPosts(_ slug:String, page:Int, onCompletion:@escaping ServiceResponse)
    {
        let path = "topic/\(slug)/?page=\(page)".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        
        get(path!, cookie: COOKIE, onCompletion: onCompletion)
    }
    
    func getChats(onCompletion:@escaping ServiceResponse)
    {
        let path = "chats"
        
        get(path, cookie: COOKIE, onCompletion: onCompletion)
    }
    
    func getChatRoom(_ roomId:String, onCompletion:@escaping ServiceResponse)
    {
        let path = "chats/\(roomId)"
        
        get(path, cookie: COOKIE, onCompletion: onCompletion)
    }
    
    func getUser(_ userSlug:String, onCompletion:@escaping ServiceResponse)
    {
        let path = "user/\(userSlug)"
        
        get(path, cookie: COOKIE, onCompletion: onCompletion)
    }
    
    func getNotifications(onCompletion:@escaping ServiceResponse)
    {
        let path = "notifications"
        
        get(path, cookie: COOKIE, onCompletion: onCompletion)
    }
    
    
    
    
    // WEBSOCKET API Methods
    func initWSEvents(){
        
        ws.event.open = {
            print("opened")
            self.Ping()
        }
        ws.event.close = { code, reason, clean in
            print(reason)
            print("close")
            ws = WebSocket(WS_SERVER)
            self.initWSEvents()
        }
        ws.event.error = { error in
            print("error \(error)")
        }
        ws.event.message = { message in
            if let text = message as? String {
                //print("recv: \(text)")
            }
        }
    }
 
    func Ping(){
        ws.send("2") // Send ping..
        var delta: Int64 = 10 * Int64(NSEC_PER_SEC)
        var time = DispatchTime.now() + Double(delta) / Double(NSEC_PER_SEC)
        DispatchQueue.main.asyncAfter(deadline: time, execute: {
            self.Ping()
        })
    }
    
    func sendPost(_ message:String, tid:Int)
    {
        let msg = "\(messageNum)[\"posts.reply\",{\"tid\":\(tid),\"content\":\"\(message)\",\"lock\":false}]"
        ws.send(msg)
    }
    func sendPost(_ message:String, tid:String)
    {
        let msg = "\(messageNum)[\"posts.reply\",{\"tid\":\(tid),\"content\":\"\(message)\",\"lock\":false}]"
        ws.send(msg)
    }
    
    func sendChatMessage(_ message:String, roomId: String){
        let msg = "\(messageNum)[\"modules.chats.send\",{\"roomId\":\"\(roomId)\",\"message\":\"\(message)\"}]"
        ws.send(msg)
    }
 
    func markTopicAsRead(_ id:Int)
    {
        let msg = "\(messageNum)[\"topics.markAsRead\",[\(id)]]"
        ws.send(msg)
    }
    
    func markAllTopicsAsRead()
    {
        let msg = "\(messageNum)[\"topics.markAllRead\"]"
        ws.send(msg)
    }
    
    func markChatAsRead(_ roomId:String)
    {
        let msg = "\(messageNum)[\"modules.chats.markRead\",[\(roomId)]]"
        ws.send(msg)
    }
    
    func markAllNotificationsAsRead()
    {
        let msg = "\(messageNum)[\"notifications.markAllRead\"]"
        ws.send(msg)
    }
    
    func favPost(_ pid: Int, tid:Int){
        let msg = "\(messageNum)[\"posts.favourite\",{\"pid\":\"\(pid)\",\"room_id\":\"topic_\(tid)\"}]"
        ws.send(msg)
    }
    func unfavPost(_ pid: Int, tid:Int){
        let msg = "\(messageNum)[\"posts.unfavourite\",{\"pid\":\"\(pid)\",\"room_id\":\"topic_\(tid)\"}]"
        ws.send(msg)
    }
    
    func upvotePost(_ pid: Int, tid:Int){
        let msg = "\(messageNum)[\"posts.upvote\",{\"pid\":\"\(pid)\",\"room_id\":\"topic_\(tid)\"}]"
        ws.send(msg)
    }
    func downvotePost(_ pid: Int, tid:Int){
        let msg = "\(messageNum)[\"posts.downvote\",{\"pid\":\"\(pid)\",\"room_id\":\"topic_\(tid)\"}]"
        ws.send(msg)
    }
    
    func getQuote(_ pid: Int){ // TODO: Check if we can do it with HTTP REST API
        let msg = "\(messageNum)[\"posts.getRawPost\",\"\(pid)\"]"
        ws.send(msg)
    }
    
    // UTILS
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
    
    func useCookie()
    {
        COOKIE = self.getCookie()
    }
 
}

