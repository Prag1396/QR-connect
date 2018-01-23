//
//  ContacVC.swift
//  ComCard
//
//  Created by Pragun Sharma on 12/30/17.
//  Copyright © 2017 Pragun Sharma. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import MessageUI
import IQKeyboardManagerSwift
import AVFoundation

class ContacVC: UIViewController, AVCaptureMetadataOutputObjectsDelegate, MFMailComposeViewControllerDelegate, UIGestureRecognizerDelegate {

    @IBOutlet weak var infoview: UIView!
    @IBOutlet weak var mssgbtn: UIButton!
    @IBOutlet weak var fullnamelabel: UILabel!
    @IBOutlet weak var profileLetter: UILabel!
    @IBOutlet weak var background: UIImageView!
    @IBOutlet weak var border: UIImageView!
    
    var session = AVCaptureSession()
    private var _email: String? = nil
    private var _fullName: String? = nil
    private var _initialposforcall = CGPoint.zero
    private var _initialposfortext: CGPoint = CGPoint.zero
    
    var video = AVCaptureVideoPreviewLayer()
    
    var next_responder: UIResponder!

    
    var fullName: String {
        get {
            return _fullName!
        } set {
            _fullName = newValue
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
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(backgroundTapped(textField: )))
        background.addGestureRecognizer(tap)
        tap.delegate = self
        self.view.addGestureRecognizer(tap)
        

        // Do any additional setup after loading the view.
        IQKeyboardManager.sharedManager().toolbarDoneBarButtonItemText = "Continue"
        
        
        
    }
    
    @IBAction func messagebtnPressed(_ sender: Any) {
        
        performSegue(withIdentifier: "loadchat", sender: Any.self)
    }
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func cancelbtnpressed(_ sender: Any) {
        self.view.sendSubview(toBack: self.infoview)

    }
    
    @IBAction func scanQRCodepressed(_ sender: Any) {
        //Create Session
        let captureDevice = AVCaptureDevice.default(for: AVMediaType.video)
        
        do {
            let input = try AVCaptureDeviceInput(device: captureDevice!)
            session.addInput(input)
        } catch {
            print("ERROR: Input not working")
        }
        
        let output = AVCaptureMetadataOutput()
        session.addOutput(output)
        
        output.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
        output.metadataObjectTypes = [AVMetadataObject.ObjectType.qr]
        
        video = AVCaptureVideoPreviewLayer(session: session)
        video.frame = view.layer.bounds
        view.layer.addSublayer(video)
        self.view.bringSubview(toFront: border)
        session.startRunning()
        
        
    }
    
    
    
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        //If we have something
        if metadataObjects.isEmpty == false  {
            if let object = metadataObjects[0] as? AVMetadataMachineReadableCodeObject {
                if object.type == AVMetadataObject.ObjectType.qr {
                    setData(data: object.stringValue!)
                    //dismiss the sublayer
                    self.view.sendSubview(toBack: border)
                    video.removeFromSuperlayer()
                    session.stopRunning()
                    
                }
            }
            
        }
    }
    
    func setData(data: String) {
        let details = data.components(separatedBy: " ")
        self.email = details[0]
        self._fullName = details[1]
        self.fullnamelabel.text = self.fullName
        let letter: Character = self.fullName.first!
        let stringFromLetter: String = String(letter)
        self.profileLetter.text = stringFromLetter
        self.view.bringSubview(toFront: self.infoview)

    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? ChatVC {
            if(self._fullName != nil) {
                destination.fullname = self._fullName!
            }
                
        }
    }
    
    @objc func backgroundTapped(textField: UITextField) {
        view.endEditing(true)
    }
    
    
    @IBAction func backBtnPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func emailbtnpressed(_ sender: Any) {
        let composeemail = MFMailComposeViewController()
        composeemail.mailComposeDelegate = self
        composeemail.setToRecipients([self.email])
        composeemail.setSubject("QRConnect - Found Lost item")
        composeemail.setMessageBody("Hi, I am emailing you becuase I found an item that belongs to you. Hope you never lose your belongings again!", isHTML: false)
        self.present(composeemail, animated: true, completion: nil)
    }
    

}
