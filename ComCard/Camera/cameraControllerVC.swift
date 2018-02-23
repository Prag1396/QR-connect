//
//  cameraControllerVC.swift
//  ComCard
//
//  Created by Pragun Sharma on 2/21/18.
//  Copyright © 2018 Pragun Sharma. All rights reserved.
//

import UIKit
import AVFoundation
import Firebase
import FirebaseAuth

class cameraControllerVC: UIViewController, AVCapturePhotoCaptureDelegate {
    
    
    @IBOutlet weak var retakePicturebtn: UIButton!
    @IBOutlet weak var imageCaptured: UIImageView!
    @IBOutlet weak var confirmImagebtn: UIButton!
    @IBOutlet weak var dismissbtn: UIButton!
    @IBOutlet weak var capturePhotoButton: UIButton!
    
    private var _recipientID: String? = nil
    
    var recipientID: String {
        get {
            return _recipientID!
        } set {
            self._recipientID = newValue
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpCaptureSession()
        view.addSubview(capturePhotoButton)
        view.addSubview(dismissbtn)
        
        capturePhotoButton.addTarget(self, action: #selector(handleCapturePhoto), for: .touchUpInside)
    }
    
    let captureSession = AVCaptureSession()
    let output = AVCapturePhotoOutput()

    @IBAction func retakePictureButtonPressed(_ sender: Any) {
        
        if let inputs = captureSession.inputs as? [AVCaptureDeviceInput] {
            for input in inputs {
                captureSession.removeInput(input)
            }
        }
        if let outputs = captureSession.outputs as? [AVCapturePhotoOutput] {
            for output in outputs {
                captureSession.removeOutput(output)
            }
        }
        
        setUpCaptureSession()
        view.addSubview(capturePhotoButton)
        view.addSubview(dismissbtn)
    
    }

    @IBAction func confirmbtnpressed(_ sender: Any) {
        self.uploadImage()
    }
    
    func uploadImage() {
        
        guard let uid = Auth.auth().currentUser?.uid else {
            return
        }
        if let img = imageCaptured.image {
            StorageService.instance.uploadToFirebaseStorage(usingImage: img, onComplete: { (status, error, imageurl) in
                if status == false || error != nil {
                    print(error?.localizedDescription ?? String())
                    return
                }
                if let imageURL = imageurl {
                    let timetamp: NSNumber = NSNumber(value: Int(NSDate().timeIntervalSince1970))
                    DataService.instance.sendMessagewithImageURL(image: img, imageURL: imageURL, senderuid: uid, recipientUID: self.recipientID, time: timetamp)
                }
            })
        }
        self.dismiss(animated: true, completion: nil)
    }
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        guard let imageData = photo.fileDataRepresentation() else {
            return
        }
        let previewImage = UIImage(data: imageData)
        if let pimage = previewImage {
            view.addSubview(imageCaptured)
            view.addSubview(confirmImagebtn)
            view.addSubview(retakePicturebtn)

            DispatchQueue.main.async {
                self.imageCaptured.image = pimage
            }
            
        }
        captureSession.stopRunning()
        
    }
    
    @IBAction func dismissPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    fileprivate func setUpCaptureSession() {
        let captureDevice = AVCaptureDevice.default(for: AVMediaType.video)
        if let cd = captureDevice {
            do {
                let input = try AVCaptureDeviceInput(device: cd)
                if captureSession.canAddInput(input) {
                    captureSession.addInput(input)
                }

            } catch {
                print(error.localizedDescription)
            }
        }
        
        if captureSession.canAddOutput(output) {
            captureSession.addOutput(output)
        }
        
        
        let previewView = UIView(frame: view.frame)
        view.addSubview(previewView)
        
        let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.frame = previewView.frame
        previewView.layer.addSublayer(previewLayer)
        captureSession.startRunning()

       
    }
    
    @objc func handleCapturePhoto() {
        let settings = AVCapturePhotoSettings()
        guard let previewFormatType = settings.availablePreviewPhotoPixelFormatTypes.first else {
            return
                }
        settings.previewPhotoFormat = [kCVPixelBufferPixelFormatTypeKey as String: previewFormatType]
        output.capturePhoto(with: settings, delegate: self)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
