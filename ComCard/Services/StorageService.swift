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
    
    var REFSB_BASE: StorageReference {
        return _REFSB_BASE
    }
    
    var REFSB_CODE: StorageReference {
        return _REFSB_CODE
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
}
