//
//  QRCode3dVC.swift
//  ComCard
//
//  Created by Pragun Sharma on 2/13/18.
//  Copyright © 2018 Pragun Sharma. All rights reserved.
//

import UIKit
import Photos


class QRCode3dVC: UIViewController {

    @IBOutlet weak var qrcode3d: imageStyle!
    var _imageData: UIImage? = nil
    
    var imageData: UIImage {
        get {
            return _imageData!
        } set {
            _imageData = newValue
        }
    }
    
    
    override var previewActionItems: [UIPreviewActionItem] {
        let item1 = UIPreviewAction(title: "Save Image", style: .default) { (action, controller) in
            self.saveImage(image: self.imageData)
        }
        
        let item2 = UIPreviewAction(title: "Copy Image", style: .default) { (action, controller) in
            self.copyImage(image: self.imageData)
        }
        return [item1, item2]
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    func copyImage(image: UIImage) {
        UIPasteboard.general.image = image
    }
    
    func saveImage(image: UIImage) {
        
        let photos = PHPhotoLibrary.authorizationStatus()
        if photos == .notDetermined {
            
            PHPhotoLibrary.requestAuthorization({ (status) in
                if status == .authorized {
                    UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
                } else {
                    let alertview = UIAlertController(title: "QRConnect", message: "The app needs access to your photos to save the QRCode", preferredStyle: .alert)
                    alertview.addAction((UIAlertAction(title: "OK", style: .default, handler: nil)))
                    self.present(alertview, animated: true, completion: nil)
                    
                }
            })
        }
        else if photos == .authorized {
            UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
        }
        else  {
            PHPhotoLibrary.requestAuthorization({ (status) in
                if status == .authorized {
                    UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
                }
            })
        }
    }
    
    @IBAction func backbtnpressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
