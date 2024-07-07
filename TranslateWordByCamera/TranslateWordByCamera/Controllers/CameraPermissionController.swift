//
//  CameraPermissionController.swift
//  TranslateWordByCamera
//
//  Created by Inna Ankudinova on 07/07/2024.
//

import Foundation
import AVFoundation
import SwiftUI

class CameraControllerView : UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate{
    var cameraSession: AVCaptureSession!
    var previewLayer: AVCaptureVideoPreviewLayer!
    var captureDevice: AVCaptureDevice!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        startCameraSession()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if cameraSession?.isRunning == false {
            cameraSession.startRunning()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if cameraSession?.isRunning == true {
            cameraSession.stopRunning()
        }
    }
    
    func requestCameraPermission(){
        let cameraAuthStatus = AVCaptureDevice.authorizationStatus(for: .video);
        
        switch cameraAuthStatus{
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video){ granted in
                if (granted){
                    print("Camera access granted")
                    self.startCameraSession()
                } else{
                    print("Camera access denied")
                    self.showCameraPermissionDenyAlert()
                }
            }
        case .restricted, .denied:
            print("Camera access was previously denied / restriced")
            self.showCameraPermissionDenyAlert()
        case .authorized:
            print("Camera access was already granted")
            startCameraSession()
        @unknown default:
            fatalError("Uknown authorization status")
        }
    }
    
    func showCameraPermissionDenyAlert(){
        let alert = UIAlertController(title: "Permission is required to access camera",
                                      message: "Please enable access to the camera in Setting",
                                      preferredStyle: .alert);
        alert.addAction(UIAlertAction(title: "Open Settings", style: .default){ _ in
            if let appSettings = URL(string: UIApplication.openSettingsURLString){
                UIApplication.shared.open(appSettings)
            }
        })
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    func startCameraSession(){
        cameraSession = AVCaptureSession()
        cameraSession.sessionPreset = .photo
        
        captureDevice = AVCaptureDevice.default(for: .video)
        guard let videoDevice = captureDevice else {
            print("Unable to access the camera")
            return
        }
        do {
            let input = try AVCaptureDeviceInput(device: videoDevice)
            cameraSession.addInput(input)
        }
        catch let error {
            print("Error Unable to initialize back camera:  \(error.localizedDescription)")
        }
        let videoOutput = AVCaptureVideoDataOutput()
        videoOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "videoQueue"))
        cameraSession.addOutput(videoOutput)
        
        previewLayer = AVCaptureVideoPreviewLayer(session: cameraSession)
        previewLayer.frame = view.frame
        view.layer.addSublayer(previewLayer)
        
        cameraSession.startRunning()
    }
}

