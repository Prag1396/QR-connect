//
//  cameraControllerVC.swift
//  ComCard
//
//  Created by Pragun Sharma on 2/21/18.
//  Copyright © 2018 Pragun Sharma. All rights reserved.
//

import UIKit
import AVFoundation

class cameraControllerVC: UIViewController, AVCapturePhotoCaptureDelegate {
    
    
    @IBOutlet weak var imageCaptured: UIImageView!
    @IBOutlet weak var confirmImagebtn: UIButton!
    @IBOutlet weak var dismissbtn: UIButton!
    @IBOutlet weak var capturePhotoButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpCaptureSession()
        view.addSubview(capturePhotoButton)
        view.addSubview(dismissbtn)
        
        capturePhotoButton.addTarget(self, action: #selector(handleCapturePhoto), for: .touchUpInside)
    }
    
    

    @IBAction func confirmbtnpressed(_ sender: Any) {
        
    }
    
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        guard let imageData = photo.fileDataRepresentation() else {
            return
        }
        let previewImage = UIImage(data: imageData)
        if let pimage = previewImage {
            view.addSubview(imageCaptured)
            view.addSubview(confirmImagebtn)

            DispatchQueue.main.async {
                self.imageCaptured.image = pimage
            }
            
        }
        
        
        print(imageData)
        
    }
    
    @IBAction func dismissPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    let output = AVCapturePhotoOutput()
    fileprivate func setUpCaptureSession() {
        let captureSession = AVCaptureSession()
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
