//
//  ViewController.swift
//  QR Reader
//
//  Created by Mikio Nakata on 11/29/19.
//  Copyright © 2019 Mikio Nakata. All rights reserved.
//
//

import UIKit
import AVFoundation

class ViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {
    
    // Var containing video stream taken from camera device.
    // Basically the layer that displays the camera video for us to see.
    var video = AVCaptureVideoPreviewLayer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Understand: sessions, inputs, outputs
        // session has input and output
        // - Session gets raw materials (data) from the input (the camera capture)
        // - Session produces output depending on how we ask it to (qr code read, etc.).
        
        // Creating session
        let session = AVCaptureSession()
        
        // Defining the capture device
        guard let captureDevice = AVCaptureDevice.default(for: .video) else { return }
        
        // Adding the input to the session.
        do
        {
            let input = try AVCaptureDeviceInput(device: captureDevice)
            //let output = AVCaptureMetadataOutput()
            session.addInput(input)
            //session.addOutput(output)
        }
        catch
        {
            print("Error!")
        }
        
        // Adding the output to the session.
        let output = AVCaptureMetadataOutput()
        session.addOutput(output)
        
        // Define the que where output is going to be processed.
        output.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
        
        // Define type of output we want (qr code or anything)
        output.metadataObjectTypes = [AVMetadataObject.ObjectType.qr]
        
        // Showing the session being captured to the user. (The camera screen displays)
        video = AVCaptureVideoPreviewLayer(session: session)
        // Frames (fill the whole screen)
        video.frame = view.layer.bounds
        // Now, add this layer to the view.
        view.layer.addSublayer(video)
        
        // Start the session.
        session.startRunning()
        
    }
    
    // This func is called whenever we have some output...
    // Will process the output.
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        // check if metadataObjects is not empty
        if metadataObjects != nil && metadataObjects.count != nil
        {
            // take the first element in the array, and cast it as AVMetadataMachineRea...
            if let object = metadataObjects[0] as? AVMetadataMachineReadableCodeObject
            {
                // Check if the object is type: qr
                if object.type == AVMetadataObject.ObjectType.qr
                {
                    // here, decide what to do with the recieved data.
                    // eg. set an alert, presenting the object's stringValue...
                    let alert = UIAlertController(title: "QR Code", message: object.stringValue, preferredStyle: .alert)
                    // user option 1: retake the QR code
                    alert.addAction(UIAlertAction(title: "Retake", style: .default, handler: nil))
                    // user option 2: copy the QR code to clipboard (string value of the object)
                    alert.addAction(UIAlertAction(title: "Copy", style: .default, handler: { (nil) in
                        UIPasteboard.general.string = object.stringValue
                    }))
                    
                 // presenting the alert!
                 present(alert, animated: true, completion: nil)
                }
            }
        }
    }

}

