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
//    private let borders = [UIView(), UIView(), UIView(), UIView()]
    private let cornerSize = 50.0
    private var startFrame: CGRect = .zero
    private var panStartPoint: CGPoint = .zero
    private var resizingCorner: UIView?
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupCornersAndBorders();
        setupGestureRecognition();
    }
    
    override required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupCornersAndBorders()
        setupGestureRecognition();
    }
    
    private func setupCornersAndBorders(){
        for corner in corners{
            corner.frame.size = CGSize(width: cornerSize, height: cornerSize)
            corner.isUserInteractionEnabled = true
            addSubview(corner)
        }
        positionCornersAndBorders();
    }
    
    private func positionCornersAndBorders(){
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
        let pinch = UIPinchGestureRecognizer(target: self, action: #selector(handlePinch(_:)))
        addGestureRecognizer(pinch)
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
            positionCornersAndBorders()
        default:
            break
        }
    }
    
    @objc private func handlePinch(_ gesture: UIPinchGestureRecognizer) {
            guard gesture.view != nil else { return }
            
            switch gesture.state {
            case .began, .changed:
                let scale = gesture.scale
                let newWidth = bounds.width * scale
                let newHeight = bounds.height * scale
                let newX = frame.origin.x - (newWidth - bounds.width) / 2
                let newY = frame.origin.y - (newHeight - bounds.height) / 2
                
                if newWidth >= cornerSize * 2 && newHeight >= cornerSize * 2 {
                    frame = CGRect(x: newX, y: newY, width: newWidth, height: newHeight)
                    positionCornersAndBorders()
                }
                gesture.scale = 1
            default:
                break
            }
        }
}
