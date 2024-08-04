//
//  CameraViewControllerWrapper.swift
//  TranslateWordByCamera
//
//  Created by Inna Ankudinova on 07/07/2024.
//

import Foundation
import SwiftUI
import UIKit

struct CameraPermissionControllerWrapper: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> CameraControllerView {
        return CameraControllerView()
    }

    func updateUIViewController(_ uiViewController: CameraControllerView, context: Context) {
        // Update the view controller if needed
    }
}
