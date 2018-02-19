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

class ChatLogVC: UIViewController, UITextFieldDelegate, UIGestureRecognizerDelegate, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var uploadImageBtn: UIButton!
    @IBOutlet weak var userfirstname: UILabel!
    @IBOutlet weak var messagefield: TextFieldStyle!
    @IBOutlet weak var background: UIImageView!
    @IBOutlet weak var sendbtn: UIButton!
    @IBOutlet weak var messageCollectionView: UICollectionView?
    
    private var _fullName: String? = nil
    private var _recipientUID: String? = nil
    private var _currentUID = Auth.auth().currentUser?.uid
    
    private var collectionViewMessages = [Message]()
    var startingFrame: CGRect?
    var blackBackroundView : UIView?
    var startingImageView: UIImageView?
    
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
        self.sendbtn.isUserInteractionEnabled = false
        messagefield.addTarget(self, action: #selector(textfieldDidChange(_:)), for: .editingChanged)
        // Do any additional setup after loading the view.
    }
    
    @objc func textfieldDidChange(_ textField: UITextField) {
        if textField.text == nil || textField.text?.isEmpty == true {
            sendbtn.isUserInteractionEnabled = false
        } else {
            sendbtn.isUserInteractionEnabled = true
        }
    }
    
    func setUpKeyBoardObserver() {
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyBoardDidShow), name: NSNotification.Name.UIKeyboardDidShow, object: nil)
    }
    
    @objc func handleKeyBoardDidShow() {
        if collectionViewMessages.count > 0 {
            let indexPath = IndexPath(item: collectionViewMessages.count - 1, section: 0)
            self.messageCollectionView?.scrollToItem(at: indexPath, at: .top, animated: true)
        }
    }
    @IBAction func uploadImageBtnPressed(_ sender: Any) {
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.allowsEditing = true
        present(imagePickerController, animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        var selectedImagefromPicker: UIImage?
        
        if let editedImage = info["UIImagePickerControllerEditedImage"] as? UIImage {
            selectedImagefromPicker = editedImage
        } else if let originalImage = info["UIImagePickerControllerOriginalImage"] as? UIImage {
            selectedImagefromPicker = originalImage
        }
        
        if let selectedImage = selectedImagefromPicker {
            StorageService.instance.uploadToFirebaseStorage(usingImage: selectedImage, onComplete: { (status, error, imageurl) in
                    if status == false || error != nil {
                        print(error.debugDescription)
                    } else {
                        if let imageURL = imageurl {
                            let timeStamp: NSNumber = NSNumber(value: Int(NSDate().timeIntervalSince1970))
                            DataService.instance.sendMessagewithImageURL(image: selectedImage, imageURL: imageURL, senderuid: (Auth.auth().currentUser?.uid)!, recipientUID: self.recipientUID, time: timeStamp)
                        }
                    }
                })
            dismiss(animated: true, completion: nil)
        }
    }
    

    
    @IBAction func signoutPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func backgroundTapped() {
        view.endEditing(true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        if textField.text?.isEmpty == true || textField.text == nil {
            sendbtn.isUserInteractionEnabled = false
        } else {
            sendbtn.isUserInteractionEnabled = true
        }
        return false
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func sendbtnpressed(_ sender: Any) {
        handleSend()
    }
    
    func textFieldDidEndEditing(_ textField: UITextField, reason: UITextFieldDidEndEditingReason) {
        if textField.text == nil || textField.text?.isEmpty == true {
            sendbtn.isUserInteractionEnabled = false
        } else {
            sendbtn.isUserInteractionEnabled = true
        }
    }
    
   
    
    func observeMessagesforuserClicked() {
        
        guard let uid = Auth.auth().currentUser?.uid else {
            return
        }
        
        let userMessagesRef = DataService.instance.REF_USERMESSAGES.child(uid).child(recipientUID)
        userMessagesRef.observe(.childAdded, with: { (snapshot) in
            
            let messageID = snapshot.key
            let messageRef = DataService.instance.REF_MESS.child(messageID)
            messageRef.observeSingleEvent(of: .value, with: { (snapshot) in
                guard let dict = snapshot.value as? [String: AnyObject] else {
                    return
                }
                    
                let messageDownloaded = Message(dictionary: dict)
                self.collectionViewMessages.append(messageDownloaded)
                DispatchQueue.main.async {
                    self.messageCollectionView?.reloadData()
                    let indexPath = IndexPath(item: self.collectionViewMessages.count - 1, section: 0)
                    self.messageCollectionView?.scrollToItem(at: indexPath, at: .bottom, animated: true)
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
        view.endEditing(true)
        self.messagefield.text = nil
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return collectionViewMessages.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "messageID", for: indexPath) as! ChatMessageCVCell
        
        cell.chatLogController = self
        let _message = collectionViewMessages[indexPath.row]
        cell.textView.text = _message.messagetext
        
        setUpCell(cell: cell, message: _message)
        
        if let text = _message.messagetext {
        //modify bubbleview width
            cell.bubbleWidthAnchor?.constant = estimatedHeightForText(text: text).width + 32
            cell.textView.isHidden = false
        } else if _message.imageURL != nil {
            //fall in here if its an image as a message
            cell.bubbleWidthAnchor?.constant = 200
            cell.textView.isHidden = true
        }
        return cell
    }
    
    private func setUpCell(cell: ChatMessageCVCell, message: Message) {
        
        if let messageImageUrl = message.imageURL {
            cell.messageImageView.loadImageUsingCacheWithUrlString(messageImageUrl)
            cell.bubbleView.backgroundColor = UIColor.clear
            cell.messageImageView.isHidden = false
        } else {
            cell.messageImageView.isHidden = true
            cell.bubbleView.backgroundColor = ChatMessageCVCell.yellowColor
        }
        
        
        if message.fromUID == Auth.auth().currentUser?.uid {
            //outgoing message
            cell.bubbleView.backgroundColor = ChatMessageCVCell.yellowColor
            cell.textView.textColor = UIColor.white
            cell.bubbleViewRightAnchor?.isActive = true
            cell.bubbleViewLeftAnchor?.isActive = false
        } else {
            //incoming message
            cell.bubbleView.backgroundColor = UIColor(red: 240, green: 240, blue: 240, alpha: 1.0)
            cell.textView.textColor = UIColor.black
            cell.bubbleViewLeftAnchor?.isActive = true
            cell.bubbleViewRightAnchor?.isActive = false
            
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        var height: CGFloat = 80
        
        let _message = collectionViewMessages[indexPath.item]
        
        //get estimated height
        let text = _message.messagetext
        if(text?.isEmpty == false) {
            height = estimatedHeightForText(text: text!).height + 20
        } else if let imageWidth = _message.imageWidth?.floatValue, let imageHeight = _message.imageHeight?.floatValue {
            height = CGFloat(imageHeight / imageWidth * 200)
            
        }
        
        let width = self.view.frame.size.width
        return CGSize(width: width, height: height)
        
    }
    
    private func estimatedHeightForText(text: String) -> CGRect {
        
        let size = CGSize(width: 200, height: 1000)
        let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
        
        return NSString(string: text).boundingRect(with: size, options: options, attributes: [kCTFontAttributeName as NSAttributedStringKey: UIFont.init(name: "Avenir", size: 16) as Any], context: nil)
    }
    
    func performZoomInForImageView(startingImageView: UIImageView) {
        
        self.startingImageView = startingImageView
        self.startingImageView?.isHidden = true
        startingFrame = startingImageView.superview?.convert(startingImageView.frame, to: nil)
        
        let zoomingImageView = UIImageView(frame: startingFrame!)
        zoomingImageView.image = startingImageView.image
        zoomingImageView.isUserInteractionEnabled = true
        
        let swipeUp = UISwipeGestureRecognizer(target: self, action: #selector(handleZoomout(tapGesture:)))
        swipeUp.direction = .up
        
        let swipeDown = UISwipeGestureRecognizer(target: self, action: #selector(handleZoomout(tapGesture:)))
        swipeDown.direction = .down
        
        zoomingImageView.addGestureRecognizer(swipeUp)
        zoomingImageView.addGestureRecognizer(swipeDown)
        
        if let keyWindow = UIApplication.shared.keyWindow {
            
            blackBackroundView = UIView(frame: keyWindow.frame)
            blackBackroundView?.backgroundColor = UIColor.black
            blackBackroundView?.alpha = 0
            
            keyWindow.addSubview(blackBackroundView!)
            keyWindow.addSubview(zoomingImageView)
            
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                
                self.blackBackroundView?.alpha = 1
                self.sendbtn.alpha = 0
                self.messagefield.alpha = 0
                self.uploadImageBtn.alpha = 0
                
                // h2 / w1 = h1 / w1
                let height = (self.startingFrame?.height)! / (self.startingFrame?.width)! * keyWindow.frame.width
                
                zoomingImageView.frame = CGRect(x: 0, y: 0, width: keyWindow.frame.width, height: height)
                zoomingImageView.center = keyWindow.center
                
            }, completion: nil)
            
        }
  
    }
    
    @objc func handleZoomout(tapGesture: UISwipeGestureRecognizer) {
            if let zoomOutImageView = tapGesture.view {
                zoomOutImageView.layer.cornerRadius = 16
                zoomOutImageView.clipsToBounds = true
                UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                    
                    zoomOutImageView.frame = self.startingFrame!
                    self.blackBackroundView?.alpha = 0
                    self.sendbtn.alpha = 1
                    self.messagefield.alpha = 1
                    self.uploadImageBtn.alpha = 1
                    
                }, completion: { (completed) in
                    zoomOutImageView.removeFromSuperview()
                    self.startingImageView?.isHidden = false
                })
        }
    }

}
