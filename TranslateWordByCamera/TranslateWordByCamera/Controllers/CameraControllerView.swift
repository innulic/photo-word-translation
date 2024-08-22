//
//  CameraPermissionController.swift
//  TranslateWordByCamera
//
//  Created by Inna Ankudinova on 07/07/2024.
//

import Foundation
import AVFoundation // To work with Camera
import SwiftUI
import Vision // To add text recognition

class CameraControllerView : UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate{
    var cameraSession: AVCaptureSession!
    var previewLayer: AVCaptureVideoPreviewLayer!
    var captureDevice: AVCaptureDevice!
    let textDetectionRequest = VNRecognizeTextRequest(completionHandler: nil)
    let translationController = TranslationController()
    var squareFrameView: UIView!
    var photoOutput = AVCapturePhotoOutput()
    var photoCaptureProcessor: PhotoCaptureProcessor?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        startCameraSession()
        addTextFrameOverlay()
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
            self.showFailedMessage(title: "Unknown Error", message: "Something when wrong during access permission checking")
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
        
        captureDevice = AVCaptureDevice.default(for: .video)
        guard let videoDevice = captureDevice else {
            print("Unable to access the camera")
            self.showFailedMessage(title: "Access deny", message: "Unable to access the camera")
            return
        }
        do {
            let input = try AVCaptureDeviceInput(device: videoDevice)
            cameraSession.addInput(input)
        }
        catch let error {
            let errorMessage = "Error Unable to initialize back camera:  \(error.localizedDescription)"
            print("\(errorMessage)`")
            self.showFailedMessage(title: "Access deny", message: errorMessage)
        }
        
        if cameraSession.canAddOutput(photoOutput) {
            cameraSession.addOutput(photoOutput)
        }
        
        previewLayer = AVCaptureVideoPreviewLayer(session: cameraSession)
        previewLayer.frame = view.layer.bounds
        previewLayer.videoGravity = .resizeAspectFill
        view.layer.addSublayer(previewLayer)
        
        cameraSession.startRunning()
    }
    
    func showDetectedText(_ text: String) {
        translationController.translate(text) { result in
            switch result {
            case .success(let translatedText):
                let alertController = UIAlertController(title: "", message: translatedText, preferredStyle: .alert)
                alertController.addAction(UIAlertAction(title: "OK", style: .default))
                self.present(alertController, animated: true)
            case .failure(let error):
                let alertController = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
                alertController.addAction(UIAlertAction(title: "OK", style: .default))
                self.present(alertController, animated: true)
            }
        }
    }
    
    func addTextFrameOverlay(){
        // add this to the settings
        let viewWidth = view.bounds.width;
        let viewHight = view.bounds.height;
        let frameWidth = viewWidth * 0.35
        let frameHight = viewHight * 0.1
        let frame = CGRect(x: (viewWidth - frameWidth) / 2, y: (viewHight - frameHight) / 2, width: frameWidth, height: frameHight)
        squareFrameView = ResiziableOverlayView(frame: frame);
        squareFrameView.layer.borderColor = UIColor.yellow.cgColor
        squareFrameView.layer.borderWidth = 2
        squareFrameView.isUserInteractionEnabled = true;
        
        let tapGestor = UITapGestureRecognizer(target: self, action: #selector(frameOverlayTapped));
        squareFrameView.addGestureRecognizer(tapGestor);
        
        view.addSubview(squareFrameView)
    }
    
    func showFailedMessage(title: String, message: String) {
            let ac = UIAlertController(title: title, message: message, preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            present(ac, animated: true)
    }
    
    @objc func frameOverlayTapped(){
        captureAndRecognizeText()
    }
    
    func captureAndRecognizeText(){
        captureImage{ image in
            guard let croppedImage = self.cropImageToFrame(image: image) else {return}
            self.recognizeTextInImage(croppedImage)
        }
    }
    
    func captureImage(completion: @escaping (UIImage) -> Void) {
        let settings = AVCapturePhotoSettings()
        self.photoCaptureProcessor = PhotoCaptureProcessor(completion: completion)
        photoOutput.capturePhoto(with: settings, delegate: photoCaptureProcessor!)
    }
    
    func cropImageToFrame(image: UIImage) -> UIImage?{
        guard let previewLayer = view.layer.sublayers?.first(where: { $0 is AVCaptureVideoPreviewLayer }) as? AVCaptureVideoPreviewLayer else {
                    print("Preview layer not found")
                    return nil
                }

        let metadataOutputRect = previewLayer.metadataOutputRectConverted(fromLayerRect: squareFrameView.frame)
                
                let imageWidth = CGFloat(image.cgImage!.width)
                let imageHeight = CGFloat(image.cgImage!.height)

                let cropRect = CGRect(
                    x: metadataOutputRect.origin.x * imageWidth,
                    y: metadataOutputRect.origin.y * imageHeight,
                    width: metadataOutputRect.size.width * imageWidth,
                    height: metadataOutputRect.size.height * imageHeight
                )

                print("Crop rect: \(cropRect)")

                guard let cgImage = image.cgImage?.cropping(to: cropRect) else {
                    print("Failed to crop CGImage")
                    return nil
                }

                let croppedImage = UIImage(cgImage: cgImage, scale: image.scale, orientation: image.imageOrientation)
                return croppedImage
    }
    
    func preprocessImageForOCR(image: UIImage) -> UIImage? {
        guard let ciImage = CIImage(image: image) else { return nil }
        
        // Convert to grayscale
        let grayscale = ciImage.applyingFilter("CIPhotoEffectNoir", parameters: [:])
        
        // Adjust contrast - you can adjust the inputContrast parameter as needed
        let contrastFilter = CIFilter(name: "CIColorControls", parameters: [kCIInputImageKey: grayscale, kCIInputContrastKey: NSNumber(value: 2.0)])
        
        guard let outputImage = contrastFilter?.outputImage else { return nil }
        
        let context = CIContext(options: nil)
        guard let cgImage = context.createCGImage(outputImage, from: outputImage.extent) else { return nil }
        
        return UIImage(cgImage: cgImage)
    }
    
    func recognizeTextInImage(_ image: UIImage) {
        let request = VNRecognizeTextRequest { (request, error) in
            guard let observations = request.results as? [VNRecognizedTextObservation] else { print("No text found."); return }
                let recognizedStrings = observations.compactMap { observation in
                    return observation.topCandidates(1).first?.string
                }.joined(separator: ", ")

                DispatchQueue.main.async {
                    self.showDetectedText(recognizedStrings)
                }
            }
        guard let cgImage = image.cgImage else {return}
        let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        do{
            try handler.perform([request])
        }catch{
            self.showFailedMessage(title: "Text recognition error", message: error.localizedDescription)
        }
    }
    
    func startTextDetection(){
        textDetectionRequest.recognitionLevel = .accurate
        textDetectionRequest.usesLanguageCorrection = true
    }
}

