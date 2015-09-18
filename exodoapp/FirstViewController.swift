//
//  FirstViewController.swift
//  exodoapp
//
//  Created by Alberto on 18/9/15.
//  Copyright © 2015 Alberto. All rights reserved.
//

import UIKit
//import SwiftWebSocket

class FirstViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        echoTest()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func echoTest(){
        var messageNum = 421
        let ws = WebSocket("ws://localhost:4567/socket.io/?EIO=3&transport=websocket")
        //ws.cookie = "express.sid=s%3ARcOxAKcpMiM9vurdvs29uBIznGJEJv9x.HK0oLZ4yslsdHeEsqfeYn9TdGxdjZgTfoz8Sw%2BkqYvM"
        let send : ()->() = {
            let msg = "\(++messageNum): \(NSDate().description)"
            print("send: \(msg)")
            ws.send(msg)
        }
        ws.event.open = {
            print("opened")
        }
        ws.event.close = { code, reason, clean in
            print("close")
        }
        ws.event.error = { error in
            print("error \(error)")
        }
        ws.event.message = { message in
            if let text = message as? String {
                print("recv: \(text)")
                
                
                if(text.hasSuffix("connect\"]"))
                {
                    print("isConnect!!")
                    
                    var msg = "\(++messageNum)[\"plugins.mentions.listGroups\"]"
                    print(msg)
                    ws.send(msg)
                    
                    msg = "\(++messageNum)[\"posts.reply\",{\"tid\":8,\"content\":\"Si???\",\"lock\":false}]"
                    
                    //['meta.rooms.enter',{'enter':'recent_topics','username':'','userslug':'','picture':'https://s.gravatar.com/avatar/3dfcda0d406efd7bace71150ccbd949f?size=128&default=identicon&rating=pg','status':'online'}]"
                    ws.send(msg)
                    
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

}

