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
    
 
    var messageArray = [Message]()
    var messagesDict = [String: Message]()
    var timer: Timer?
    
    @IBOutlet weak var chatTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        chatTableView.delegate = self
        chatTableView.dataSource = self
        chatTableView.tableFooterView = UIView()
        
        messageArray.removeAll()
        messagesDict.removeAll()
        chatTableView.reloadData()

        observeUserMessages()
        
        chatTableView.allowsMultipleSelectionDuringEditing = true
        

        // Do any additional setup after loading the view.
    }
    
    func observeUserMessages() {
        
        guard let uid = Auth.auth().currentUser?.uid else {
            return
        }
        
        let ref = DataService.instance.REF_USERMESSAGES.child(uid)
        ref.observe(.childAdded, with: { (snapshot) in
            
            let userID = snapshot.key
            
            DataService.instance.REF_USERMESSAGES.child(uid).child(userID).observe(.childAdded, with: { (snapshot) in
                
                let messageID = snapshot.key
                self.fetchMessageWithMessageID(messageID: messageID)

                
            }, withCancel: nil)
                
                
            }, withCancel: nil)
        
        ref.observe(.childRemoved, with: { (snapshot) in
            
            self.messagesDict.removeValue(forKey: snapshot.key)
            self.attemptReload()
            
        }, withCancel: nil)
            
    }
    
    private func fetchMessageWithMessageID(messageID: String) {
        let messagesReference = DataService.instance.REF_MESS.child(messageID)
        messagesReference.observeSingleEvent(of: .value, with: { (snapshot) in
            
            if let dict = snapshot.value as? [String: AnyObject] {

                let messageObj = Message(dictionary: dict)
                
                if let chatPartnerID = messageObj.charParnterID()  {
                    self.messagesDict[chatPartnerID] = messageObj
                    
                }
                
                self.attemptReload()
                
            }
        }, withCancel: nil)
    }
    
    private func attemptReload() {
        self.timer?.invalidate()
        self.timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(self.handleReloadTable), userInfo: nil, repeats: false)
    }
    
    @objc func handleReloadTable() {
        
        self.messageArray = Array(self.messagesDict.values)
        self.messageArray.sort(by: { (message1, message2) -> Bool in
            return (message1.timeStamp?.intValue)! > (message2.timeStamp?.intValue)!
        })
        //this will crash because of background thread, so lets call this on dispatch_async main thread
        DispatchQueue.main.async(execute: {
            self.chatTableView.reloadData()
        })
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
        cell.selectionStyle = .none
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let message = messageArray[indexPath.row]
        guard let chatPartnerID = message.charParnterID() else {
            return
        }
        
        let ref = DataService.instance.REF_USERS.child(chatPartnerID)
        ref.observeSingleEvent(of: .value, with: { (snapshot) in
            let recipientID = snapshot.key
            if let dict = snapshot.value as? NSDictionary {
                if let name = dict["FirstName"] as? String {
                    self.showChatLogController(name: name, recipientID: recipientID)
                }
            }
            
        }, withCancel: nil)
        
    }
    
    func tableView(_ tableView: UITableView, didHighlightRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        cell?.contentView.backgroundColor = UIColor.lightGray
    }
    
    func tableView(_ tableView: UITableView, didUnhighlightRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        cell?.contentView.backgroundColor = UIColor.clear
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
        //Perform Delete logic here
        guard let uid = Auth.auth().currentUser?.uid else {
            return
        }
        
        let message = messageArray[indexPath.row]
        
        if let chatPartnerID = message.charParnterID() {
            DataService.instance.REF_USERMESSAGES.child(uid).child(chatPartnerID).removeValue(completionBlock: { (error, ref) in
                
                if error != nil {
                    print(error.debugDescription)
                    return
                }
                //Update table after removing messages
                self.messagesDict.removeValue(forKey: chatPartnerID)
                self.attemptReload()
            })
        }
        
        
    }
    
    func showChatLogController(name: String, recipientID: String) {
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "ChatLogVC") as! ChatLogVC
        controller.fullname = name
        controller.recipientUID = recipientID
        self.present(controller, animated: true, completion: nil)
    }
    
    
    
}
