//
//  ResiziableOverlayView.swift
//  TranslateWordByCamera
//
//  Created by Inna Ankudinova on 22/08/2024.
//

import Foundation
import UIKit

class ResiziableOverlayView: UIView{
    
    private let corners = [UIView(), UIView(), UIView(), UIView()]
    private let cornerSize = 20.0
    private var startFrame: CGRect = .zero
    private var panStartPoint: CGPoint = .zero
    private var resizingCorner: UIView?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupCorners();
        setupGestureRecognition();
    }
    
    override required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupCorners()
        setupGestureRecognition();
    }
    
    private func setupCorners(){
        for corner in corners{
            corner.backgroundColor = .blue
            corner.frame.size = CGSize(width: cornerSize, height: cornerSize)
            corner.isUserInteractionEnabled = true
            addSubview(corner)
        }
        positionCorners();
    }
    
    private func positionCorners(){
        for (index, corner) in corners.enumerated(){
            let x = index % 2 == 0 ? 0.0 : bounds.width - cornerSize
            let y = index < 2 ? 0.0 : bounds.height - cornerSize
            corner.frame.origin = CGPoint(x: x, y: y)
        }
    }
    
    private func setupGestureRecognition(){
        for corner in corners{
            var recognizer = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
            corner.addGestureRecognizer(recognizer)
        }
    }
    
    @objc private func handlePan(_ gesture: UIPanGestureRecognizer){
        guard let corner = gesture.view else {return}
        let translation = gesture.translation(in: self)
        
        switch gesture.state{
        case .began:
            startFrame = frame
            panStartPoint = gesture.location(in: superview)
            resizingCorner = corner
        case .changed:
            let newWidth = max(startFrame.width + translation.x * (corner === subviews[1] || corner === subviews[3] ? 1 : -1), cornerSize)
            let newHeight = max(startFrame.height + translation.y * (corner === subviews[2] || corner === subviews[3] ? 1 : -1), cornerSize)
            let newX = corner === subviews[0] || corner === subviews[2] ? startFrame.maxX - newWidth : startFrame.minX
            let newY = corner === subviews[0] || corner === subviews[1] ? startFrame.maxY - newHeight : startFrame.minY
            frame = CGRect(x: newX, y: newY, width: newWidth, height: newHeight)
            positionCorners()
        default:
            break
        }
    }
}
