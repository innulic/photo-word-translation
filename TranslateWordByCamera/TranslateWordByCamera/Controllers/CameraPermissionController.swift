//
//  CameraPermissionController.swift
//  TranslateWordByCamera
//
//  Created by Inna Ankudinova on 07/07/2024.
//

import Foundation
import AVFoundation
import SwiftUI
import Vision

class CameraControllerView : UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate{
    var cameraSession: AVCaptureSession!
    var previewLayer: AVCaptureVideoPreviewLayer!
    var captureDevice: AVCaptureDevice!
    let textDetectionRequest = VNRecognizeTextRequest(completionHandler: nil)
    let translationController = TranslationController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        startCameraSession()
        // TODO add control to start text recognition
        startTextDetection()
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
                                      message: "Please enable access to the camera in Settings",
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
    
    func startTextDetection(){
        textDetectionRequest.recognitionLevel = .accurate
        textDetectionRequest.usesLanguageCorrection = true
    }
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
            guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
            
            var requestOptions:[VNImageOption : Any] = [:]
            
            let imageRequestHandler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, orientation: .up, options: requestOptions)
            
            do {
                try imageRequestHandler.perform([textDetectionRequest])
                guard let observations = textDetectionRequest.results as? [VNRecognizedTextObservation] else { return }
                let detectedText = observations.compactMap { observation in
                    return observation.topCandidates(1).first?.string
                }.joined(separator: ", ")
                
                DispatchQueue.main.async {
                    self.showDetectedText(detectedText)
                }
            } catch let error {
                print(error)
            }
        }
    func showDetectedText(_ text: String) {
        let alertController = UIAlertController(title: "Detected Text", message: text, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default))
        present(alertController, animated: true)
        translationController.translate(text) { result in
            switch result {
            case .success(let translatedText):
                let alertController = UIAlertController(title: "Translated Text", message: translatedText, preferredStyle: .alert)
                alertController.addAction(UIAlertAction(title: "OK", style: .default))
                self.present(alertController, animated: true)
            case .failure(let error):
                let alertController = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
                alertController.addAction(UIAlertAction(title: "OK", style: .default))
                self.present(alertController, animated: true)
            }
        }
    }
}

