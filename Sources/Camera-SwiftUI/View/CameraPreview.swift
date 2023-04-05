//
//  CameraPreview.swift
//  Campus
//
//  Created by Rolando Rodriguez on 12/17/19.
//  Copyright © 2019 Rolando Rodriguez. All rights reserved.
//

import UIKit
import AVFoundation
import SwiftUI

public struct CameraPreview: UIViewRepresentable {
    public class VideoPreviewView: UIView {
        public override class var layerClass: AnyClass {
            AVCaptureVideoPreviewLayer.self
        }
        
        var videoPreviewLayer: AVCaptureVideoPreviewLayer {
            return layer as! AVCaptureVideoPreviewLayer
        }
        
        let focusView: UIView = {
            let focusView = UIView(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
            focusView.layer.borderColor = UIColor.white.cgColor
            focusView.layer.borderWidth = 1.5
            focusView.layer.cornerRadius = 25
            focusView.layer.opacity = 0
            focusView.backgroundColor = .clear
            return focusView
        }()
        
        @objc func focusAndExposeTap(gestureRecognizer: UITapGestureRecognizer) {
            let layerPoint = gestureRecognizer.location(in: gestureRecognizer.view)
            let devicePoint = videoPreviewLayer.captureDevicePointConverted(fromLayerPoint: layerPoint)
            
            self.focusView.layer.frame = CGRect(origin: layerPoint, size: CGSize(width: 50, height: 50))
            
            
            NotificationCenter.default.post(.init(name: .init("UserDidRequestNewFocusPoint"), object: nil, userInfo: ["devicePoint": devicePoint] as [AnyHashable: Any]))
            
            UIView.animate(withDuration: 0.3, animations: {
                self.focusView.layer.opacity = 1
            }) { (completed) in
                if completed {
                    UIView.animate(withDuration: 0.3) {
                        self.focusView.layer.opacity = 0
                    }
                }
            }
        }
        
        public override func layoutSubviews() {
            super.layoutSubviews()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                self.videoPreviewLayer.frame = self.bounds
                self.videoPreviewLayer.connection?.videoOrientation = UIDevice.current.orientation.videoOrientation
            }
        }
    }
    
    public let session: AVCaptureSession
    
    public init(session: AVCaptureSession) {
        self.session = session
    }
    
    public func makeUIView(context: Context) -> VideoPreviewView {
        let viewFinder = VideoPreviewView()
        viewFinder.backgroundColor = .black
        viewFinder.videoPreviewLayer.cornerRadius = 0
        viewFinder.videoPreviewLayer.session = session
        viewFinder.videoPreviewLayer.connection?.videoOrientation = UIDevice.current.orientation.videoOrientation
        return viewFinder
    }
    
    public func updateUIView(_ uiView: VideoPreviewView, context: Context) {
    }
}

struct CameraPreview_Previews: PreviewProvider {
    static var previews: some View {
        CameraPreview(session: AVCaptureSession())
            .frame(height: 300)
    }
}

extension UIDeviceOrientation {
    var videoOrientation: AVCaptureVideoOrientation {
        
        switch (self) {
        case .portrait:
            return .portrait
        case .landscapeRight:
            return .landscapeLeft
        case .landscapeLeft:
            return .landscapeRight
        default:
            return .portrait
        }
        
    }
}
