//
//  StorageService.swift
//  ComCard
//
//  Created by Pragun Sharma on 1/8/18.
//  Copyright © 2018 Pragun Sharma. All rights reserved.
//

import Foundation
import Firebase
import FirebaseStorage

let SB_BASE = Storage.storage().reference()

class StorageService {
    static let instance = StorageService()
    private var _REFSB_BASE = SB_BASE
    private var _REFSB_CODE = SB_BASE.child("users")
    private var _REF_MESSAGESIMAGES = SB_BASE.child("messagesImages")
    
    var REFSB_BASE: StorageReference {
        return _REFSB_BASE
    }
    
    var REFSB_CODE: StorageReference {
        return _REFSB_CODE
    }
    
    var REF_MESSAGESIMAGES: StorageReference {
        return _REF_MESSAGESIMAGES
    }
    
    
    func uploadImage(withuserID userID: String, image: UIImage, onImageUploadComplete: @escaping (_ status: Bool, _ error: Error?, _ url: URL?)->()) {
        
        let storageRef = REFSB_CODE.child(userID).child("QRCode.png")
        
        if let uploadData = UIImagePNGRepresentation(image) {
            storageRef.putData(uploadData, metadata: nil, completion: { (metadata, error) in
                if (error != nil) {
                    onImageUploadComplete(false, error, nil)
                    return
                }
                let imageurl = metadata?.downloadURL()?.absoluteURL
                onImageUploadComplete(true, nil, imageurl)
            })
        }
    }
    
    func downloadImage(withURL url: URL, downloadCompleteImage: @escaping (_ status: Bool, _ error: Error?, _ data: Data?)->()) {
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            if (error != nil) {
                print(error.debugDescription)
                downloadCompleteImage(false, error, nil)
            } else {
                print("here")
                downloadCompleteImage(true, nil, data)
            }
        }.resume()
    }
    
    func uploadToFirebaseStorage(usingImage image: UIImage, onComplete: @escaping (_ status: Bool, _ error: Error?, _ imageurl: String?)->()) {
        
        guard let uid = Auth.auth().currentUser?.uid else {
            return
        }
        
        let imageName = NSUUID().uuidString
        let ref = REF_MESSAGESIMAGES.child(uid).child(imageName)
        
        if let uploadData = UIImageJPEGRepresentation(image, 0.2) {
            ref.putData(uploadData, metadata: nil, completion: { (metadata, error) in
                if error != nil {
                    print("Failed to upload image")
                    onComplete(false, error, nil)
                    return
                }
                if let imageURL = metadata?.downloadURL()?.absoluteString {
                    onComplete(true, nil, imageURL)
                }
            })
        }
        
    }
    
}
