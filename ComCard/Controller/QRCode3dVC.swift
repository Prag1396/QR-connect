//
//  QRCode3dVC.swift
//  ComCard
//
//  Created by Pragun Sharma on 2/13/18.
//  Copyright © 2018 Pragun Sharma. All rights reserved.
//

import UIKit
import Photos
import PCLBlurEffectAlert

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
                    
                    let alert = PCLBlurEffectAlertController(title: "QRConnect", message: "The app needs access to your photos to save the QRCode", effect: UIBlurEffect(style: .light), style: .alert)
                    alert.addAction(PCLBlurEffectAlertAction(title: "OK", style: .default, handler: { (action) in
                        self.view.alpha = 1.0
                    }))
                    alert.configureAlert(alert: alert)
                    self.view.alpha = 0.7
                    alert.show()
                    
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
