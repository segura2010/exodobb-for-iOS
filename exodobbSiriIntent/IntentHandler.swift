//
//  IntentHandler.swift
//  exodobbSiriIntent
//
//  Created by Alberto on 10/9/16.
//  Copyright © 2016 Alberto. All rights reserved.
//

import Intents

// As an example, this class is set up to handle Message intents.
// You will want to replace this or add other intents as appropriate.
// The intents you wish to handle must be declared in the extension's Info.plist.

// You can test your example integration by saying things to Siri like:
// "Send a message using <myApp>"
// "<myApp> John saying hello"
// "Search for messages in <myApp>"

class IntentHandler: INExtension, INSendMessageIntentHandling, INSearchForMessagesIntentHandling, INSetMessageAttributeIntentHandling {
    
    
    var message = ""
    var thread = ""
    var threadId = ""
    
    
    override func handler(for intent: INIntent) -> Any {
        // This is the default implementation.  If you want different objects to handle different intents,
        // you can override this and return the handler you want for that particular intent.
        
        print("COOKIE: \(getCookie())")
        
        return self
    }
    
    // MARK: - INSendMessageIntentHandling
    
    // Implement resolution methods to provide additional information about your intent (optional).
    func resolveRecipients(forSendMessage intent: INSendMessageIntent, with completion: @escaping ([INPersonResolutionResult]) -> Void) {
        if let recipients = intent.recipients {
            
            // If no recipients were provided we'll need to prompt for a value.
            if recipients.count == 0 {
                completion([INPersonResolutionResult.needsValue()])
                return
            }
            
            var resolutionResults = [INPersonResolutionResult]()
            print(recipients)
            for recipient in recipients {
                var matchingContacts = [INPerson]() // Implement your contact matching logic here to create an array of matching contacts
                
                // Here we must search the topic
                // Search endpoint https://exo.do/api/search/keyword?in=titles
                print("\(recipient.spokenPhrase)")
                print("IDENTIFIER: \(recipient.contactIdentifier)")
                print("DIS: \(recipient.displayName)")
                print("REC: \(recipient)")
                
                NodeBBAPI.sharedInstance.searchTopicByTitle(recipient.spokenPhrase!, cookie: getCookie()){(error:NSError?, responseObject:[String:AnyObject]?) in
                    
                    if(error != nil)
                    {
                        resolutionResults += [INPersonResolutionResult.unsupported()]
                        completion(resolutionResults)
                        return print("error")
                    }
                    
                    var person = recipient
                    
                    //print(responseObject)
                    if let posts = responseObject?["posts"] as? [[String:AnyObject]]
                    {
                        /* We should give the user the option to chose the topic, but now it creates an infinite loop in Siri..
                        for p in posts
                        {
                            let title = p["topic"]?["title"]
                            let tid = "\(p["topic"]?["tid"])"
                            //print("\(p["topic"]?["title"])")
                            var person = INPerson(handle: tid, displayName: title as! String?, contactIdentifier: tid)
                            matchingContacts.append(person)
                        }
                        */
                        
                        // So we use the first one
                        let title = posts[0]["topic"]?["title"]
                        let tid = "\(posts[0]["topic"]!["tid"]!)"
                        print("Selected: \(title)")
                        person = INPerson(handle: tid, displayName: title as! String?, contactIdentifier: tid)
                        matchingContacts.append(person)
                    }
                    
                    switch matchingContacts.count {
                    case 2  ... Int.max:
                        // We need Siri's help to ask user to pick one from the matches.
                        resolutionResults += [INPersonResolutionResult.disambiguation(with: matchingContacts)]
                        
                    case 1:
                        // We have exactly one matching contact
                        resolutionResults += [INPersonResolutionResult.success(with: person)]
                        
                    case 0:
                        // We have no contacts matching the description provided
                        resolutionResults += [INPersonResolutionResult.unsupported()]
                        
                    default:
                        break
                        
                    }
                    
                    completion(resolutionResults)
                    
                }
            }
        }
    }
    
    func resolveContent(forSendMessage intent: INSendMessageIntent, with completion: @escaping (INStringResolutionResult) -> Void) {
        if let text = intent.content, !text.isEmpty {
            message = text
            
            completion(INStringResolutionResult.success(with: text))
        } else {
            completion(INStringResolutionResult.needsValue())
        }
    }
    
    // Once resolution is completed, perform validation on the intent and provide confirmation (optional).
    
    func confirm(sendMessage intent: INSendMessageIntent, completion: @escaping (INSendMessageIntentResponse) -> Void) {
        // Verify user is authenticated and your app is ready to send a message.
        
        NodeBBAPI.sharedInstance.initWSEvents()
        
        let userActivity = NSUserActivity(activityType: NSStringFromClass(INSendMessageIntent.self))
        let response = INSendMessageIntentResponse(code: .ready, userActivity: userActivity)
        completion(response)
    }
    
    // Handle the completed intent (required).
    func handle(sendMessage intent: INSendMessageIntent, completion: @escaping (INSendMessageIntentResponse) -> Void) {
        // Implement your application logic to send a message here.
        
        message = intent.content!
        let tid = intent.recipients?[0].contactIdentifier
        //let tid = intent.recipients?[0].contactIdentifier
        print("SENDING: \(message) to TID: \(tid)")
        
        NodeBBAPI.sharedInstance.sendPost(message, tid:tid!)
        
        let userActivity = NSUserActivity(activityType: NSStringFromClass(INSendMessageIntent.self))
        let response = INSendMessageIntentResponse(code: .success, userActivity: userActivity)
        completion(response)
    }
    
    // Implement handlers for each intent you wish to handle.  As an example for messages, you may wish to also handle searchForMessages and setMessageAttributes.
    
    // MARK: - INSearchForMessagesIntentHandling
    func handle(searchForMessages intent: INSearchForMessagesIntent, completion: @escaping (INSearchForMessagesIntentResponse) -> Void) {
        // Implement your application logic to find a message that matches the information in the intent.
        
        let userActivity = NSUserActivity(activityType: NSStringFromClass(INSearchForMessagesIntent.self))
        let response = INSearchForMessagesIntentResponse(code: .success, userActivity: userActivity)
        // Initialize with found message's attributes
        response.messages = [INMessage(
            identifier: "identifier",
            content: "I am so excited about SiriKit!",
            dateSent: Date(),
            sender: INPerson(personHandle: INPersonHandle(value: "sarah@example.com", type: .emailAddress), nameComponents: nil, displayName: "Sarah", image: nil,  contactIdentifier: nil, customIdentifier: nil),
            recipients: [INPerson(personHandle: INPersonHandle(value: "+1-415-555-5555", type: .phoneNumber), nameComponents: nil, displayName: "John", image: nil,  contactIdentifier: nil, customIdentifier: nil)]
            )]
        completion(response)
    }
    
    // MARK: - INSetMessageAttributeIntentHandling
    
    func handle(setMessageAttribute intent: INSetMessageAttributeIntent, completion: @escaping (INSetMessageAttributeIntentResponse) -> Void) {
        // Implement your application logic to set the message attribute here.
        
        let userActivity = NSUserActivity(activityType: NSStringFromClass(INSetMessageAttributeIntent.self))
        let response = INSetMessageAttributeIntentResponse(code: .success, userActivity: userActivity)
        completion(response)
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

