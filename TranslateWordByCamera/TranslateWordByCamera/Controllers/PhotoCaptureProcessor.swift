//
//  PhotoCaptureProcessor.swift
//  TranslateWordByCamera
//
//  Created by Inna Ankudinova on 02/08/2024.
//

import Foundation
import AVFoundation
import SwiftUI

class PhotoCaptureProcessor: NSObject, AVCapturePhotoCaptureDelegate {
    let completion: (UIImage) -> Void

    init(completion: @escaping (UIImage) -> Void) {
        self.completion = completion
    }

    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        if let error = error {
                print("Error capturing photo: \(error.localizedDescription)")
                return
            }
        if let imageData = photo.fileDataRepresentation(), let image = UIImage(data: imageData) {
            completion(image)
        }
    }
}
