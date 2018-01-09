//
//  QRGenerateVC.swift
//  ComCard
//
//  Created by Pragun Sharma on 1/8/18.
//  Copyright © 2018 Pragun Sharma. All rights reserved.
//

import UIKit

class QRGenerateVC: UIViewController {

    @IBOutlet weak var QRImg: UIImageView!
    
    private var _fullName: String? = nil
    private var _phoneNumber: String? = nil
    private var _email: String? = nil
    private var _datarray: [String]? = nil
    
    var fullName: String {
        get {
            return _fullName!
        } set {
            _fullName = newValue
        }
    }
    
    var phoneNumber: String {
        get {
            return _phoneNumber!
        } set {
            _phoneNumber = newValue
        }
    }
    
    var email: String {
        get {
            return _email!
        } set {
            _email = newValue
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let data = self.phoneNumber.data(using: .ascii, allowLossyConversion: false)
        let filter = CIFilter(name: "CIQRCodeGenerator")
        filter?.setValue(data, forKey: "inputMessage")
        
        let ciImage = filter?.outputImage
        let transform = CGAffineTransform(scaleX: 10, y: 10)
        let transformImage = ciImage?.transformed(by: transform)
        
        let img = UIImage(ciImage: (transformImage)!)
        QRImg.image = img
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    @IBAction func saveIconPressed(_ sender: Any) {
    }
    
    @IBAction func backbtnPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
}
