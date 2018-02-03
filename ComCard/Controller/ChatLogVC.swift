//
//  ChatLogVC.swift
//  ComCard
//
//  Created by Pragun Sharma on 1/21/18.
//  Copyright © 2018 Pragun Sharma. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase
import FirebaseAuth

class ChatLogVC: UIViewController, UITextFieldDelegate, UIGestureRecognizerDelegate, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    @IBOutlet weak var userfirstname: UILabel!
    @IBOutlet weak var messagefield: TextFieldStyle!
    @IBOutlet weak var background: UIImageView!
    @IBOutlet weak var sendbtn: UIButton!
    @IBOutlet weak var messageCollectionView: UICollectionView?
    
    private var _fullName: String? = nil
    private var _recipientUID: String? = nil
    private var _currentUID = Auth.auth().currentUser?.uid
    
    private var collectionViewMessages = [Message]()
    
    var fullname: String {
        get {
            return _fullName!
        } set {
           self._fullName = newValue
        }
    }
    
    var recipientUID: String {
        get {
            return _recipientUID!
        } set {
            self._recipientUID = newValue
            observeMessagesforuserClicked()
        }
    }
    
    override func viewDidLoad() {

        super.viewDidLoad()
        messageCollectionView?.delegate = self
        messageCollectionView?.dataSource = self
        messageCollectionView?.alwaysBounceVertical = true
        messageCollectionView?.register(ChatMessageCVCell.self, forCellWithReuseIdentifier: "messageID")
        messageCollectionView?.scrollIndicatorInsets = UIEdgeInsets(top: 0, left: 0, bottom: 50, right: 0)
        messagefield.delegate = self
        messagefield.keyboardAppearance = .dark
        let tap = UITapGestureRecognizer(target: self, action: #selector(backgroundTapped))
        background.addGestureRecognizer(tap)
        tap.delegate = self
        self.view.addGestureRecognizer(tap)
        self.userfirstname.text = self.fullname
        // Do any additional setup after loading the view.
    }
    
    @IBAction func signoutPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func backgroundTapped() {
        view.endEditing(true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        handleSend()
        textField.resignFirstResponder()
        return false
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @IBAction func sendbtnpressed(_ sender: Any) {
        handleSend()
    }
    
    func observeMessagesforuserClicked() {
        
        guard let uid = Auth.auth().currentUser?.uid else {
            return
        }
        
        let userMessagesRef = DataService.instance.REF_USERMESSAGES.child(uid)
        userMessagesRef.observe(.childAdded, with: { (snapshot) in
            
            let messageID = snapshot.key
            let messageRef = DataService.instance.REF_MESS.child(messageID)
            messageRef.observeSingleEvent(of: .value, with: { (snapshot) in
                if let dict = snapshot.value as? NSDictionary {
                    let fromID =  dict["fromID"] as? String
                    let toID = dict["toID"] as? String
                    let timeStamp = dict["time"] as? NSNumber
                    let text = dict["messagetext"] as? String
                    //potential of crashing if keys do not match
                    let messageDownloaded = Message(fromUID: fromID!, toUID: toID!, messageText: text!, timeStamp: timeStamp!)
                    if messageDownloaded.charParnterID() == self.recipientUID {
                        self.collectionViewMessages.append(messageDownloaded)                        
                        DispatchQueue.main.async {
                            self.messageCollectionView?.reloadData()
                        }
                    }

                }

            }, withCancel: nil)
            
            
        }, withCancel: nil)
        
    }
    
    func handleSend() {
        if(messagefield.text != nil) {
            let data = messagefield.text
            let timeStamp: NSNumber = NSNumber(value: Int(NSDate().timeIntervalSince1970))
            DataService.instance.uploadMessage(senderuid: (Auth.auth().currentUser?.uid)!, recipientUID: self.recipientUID, message: data!, time: timeStamp)
            
        }
        self.messagefield.text = nil
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return collectionViewMessages.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "messageID", for: indexPath) as! ChatMessageCVCell
        let _message = collectionViewMessages[indexPath.row]
        cell.textView.text = _message.messageText
        
        //modify bubbleview width
        cell.bubbleWidthAnchor?.constant = estimatedHeightForText(text: _message.messageText).width + 32
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        var height: CGFloat = 80
        //get estimated height
        let text = collectionViewMessages[indexPath.item].messageText
        if(text.isEmpty == false) {
            height = estimatedHeightForText(text: text).height + 20
        }
        
        
        return CGSize(width: view.frame.width, height: height)
        
    }
    
    private func estimatedHeightForText(text: String) -> CGRect {
        
        let size = CGSize(width: 200, height: 1000)
        let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
        
        return NSString(string: text).boundingRect(with: size, options: options, attributes: [kCTFontAttributeName as NSAttributedStringKey: UIFont.init(name: "Avenir", size: 16) as Any], context: nil)
    }

}
