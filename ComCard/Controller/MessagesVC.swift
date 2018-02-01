//
//  MessagesVC.swift
//  ComCard
//
//  Created by Pragun Sharma on 1/28/18.
//  Copyright © 2018 Pragun Sharma. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseDatabase

class MessagesVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    private var _senderID: String? = nil
    private var _recipientID: String? = nil
    private var _timeStamp: NSNumber? = nil
    private var _messageText: String? = nil
    var messageArray = [Message]()
    var messagesDict = [String: Message]()
    
    @IBOutlet weak var chatTableView: UITableView!
    
    var senderID: String {
        get {
        return _senderID!
        } set {
            _senderID = newValue
        }
    }
    
    var recipientID: String {
        get {
        return _recipientID!
        } set {
            _recipientID = newValue
        }
    }
    
    var timestamp: NSNumber {
        get {
        return _timeStamp!
        } set {
            _timeStamp = newValue
        }
    }
    
    var messageText: String {
        get {
        return _messageText!
        } set {
            _messageText = newValue
        }
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
        chatTableView.delegate = self
        chatTableView.dataSource = self
        chatTableView.tableFooterView = UIView()
        
        observeUserMessages()
        
        // Do any additional setup after loading the view.
    }
    
    func observeUserMessages() {
        
        guard let uid = Auth.auth().currentUser?.uid else {
            return
        }
        
        let ref = DataService.instance.REF_USERMESSAGES.child(uid)
        ref.observe(.childAdded, with: { (snapshot) in
            
            let messageID = snapshot.key
            let messagesReference = DataService.instance.REF_MESS.child(messageID)
            messagesReference.observeSingleEvent(of: .value, with: { (snapshot) in
                
                if let dict = snapshot.value as? NSDictionary {
                    self.senderID = (dict["fromID"] as? String)!
                    self.recipientID = (dict["toID"] as? String)!
                    self.timestamp = (dict["time"] as? NSNumber)!
                    self.messageText = (dict["messagetext"] as? String)!
                    let messageObj = Message(fromUID: self.senderID, toUID: self.recipientID, messageText: self.messageText, timeStamp: self.timestamp)
                    self.messagesDict[messageObj.toID] = messageObj
                    self.messageArray = Array(self.messagesDict.values)
                    self.messageArray.sort(by: { (message1, message2) -> Bool in
                        return message1.timeStamp.intValue > message2.timeStamp.intValue
                    })
                    
                    DispatchQueue.main.async {
                        self.chatTableView.reloadData()
                    }
                }
            }, withCancel: nil)
            
        }, withCancel: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func backbtnpressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messageArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "chatprofilecell") as! MessageCell
        let messagetodisplay = messageArray[indexPath.row]
        cell.messagetodisplay = messagetodisplay
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let message = messageArray[indexPath.row]
        guard let chatPartnerID = message.charParnterID() else {
            return
        }
        
        let ref = DataService.instance.REF_USERS.child(chatPartnerID)
        ref.observeSingleEvent(of: .value, with: { (snapshot) in
            
            guard let dictionary = snapshot.value as? NSDictionary else {
                return
            }
           
            
            
        }, withCancel: nil)
        
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func showChatLogController(foruser user: User) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "ChatLogVC") as! ChatLogVC
        self.present(controller, animated: true, completion: nil)
    }
    
    
    
}
