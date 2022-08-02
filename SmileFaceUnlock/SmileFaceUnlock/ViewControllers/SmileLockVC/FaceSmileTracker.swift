//
//  FaceSmileTracker.swift
//  FaceSmileTracker
//
//  Created by Muhammad Afham on 7/31/22.
//  Copyright © 2022 Muhammad Afham. All rights reserved.
//

import Foundation
import ARKit
import Lottie

protocol FaceSmileTrackerDelegate: AnyObject {
    func faceSmileTracker(_ tracker: FaceSmileTracker, needsFaceUpdate state: FaceSmileTracker.FaceState)
    func faceSmileTracker(_ tracker: FaceSmileTracker, failedWithError error: NSError)
}

class FaceSmileTracker: NSObject {
    
    // MARK: - Delegate
    private weak var delegate: FaceSmileTrackerDelegate?
    
    // MARK: - Dependencies
    private var referenceVC: UIViewController!
    
    // MARK: - Properties
    private let trackingView = ARSCNView()
    
    init(vc: UIViewController & FaceSmileTrackerDelegate) {
        self.referenceVC = vc
        self.delegate = vc
    }
    
    func startTracking() {
        // Check to make sure AR face tracking is supported
        guard ARFaceTrackingConfiguration.isSupported else {
            // If face tracking isn't available throw error and exit
            self.delegate?.faceSmileTracker(self, failedWithError: FaceSmileTrackerError.DeviceNotSupportAR as NSError)
            return
        }
        
        // Request camera permission
        AVCaptureDevice.requestAccess(for: AVMediaType.video) { granted in
            if (granted) {
                // If access is granted, setup the main view
                DispatchQueue.main.sync {
                    self.setupSmileTracker()
                }
            } else {
                // If access is not granted, throw error and exit
                self.delegate?.faceSmileTracker(self, failedWithError: FaceSmileTrackerError.CameraAccessNotGranted as NSError)
            }
        }
    }
    
    
    func setupSmileTracker() {
        // Configure and start face tracking session
        let configuration = ARFaceTrackingConfiguration()
        configuration.isLightEstimationEnabled = true
        
        // Run ARSession and set delegate to self
        trackingView.session.run(configuration, options: [.resetTracking,.removeExistingAnchors])
        trackingView.delegate = self
        
        // Add trackingView so that it will run
        referenceVC.view.addSubview(trackingView)
    }
}

// MARK: - Delegate
extension FaceSmileTracker: ARSCNViewDelegate {
    
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        // Cast anchor as ARFaceAnchor
        guard let faceAnchor = anchor as? ARFaceAnchor else { return }
        
        // Pull left/right smile coefficients from blendShapes
        let leftMouthSmileValue = faceAnchor.blendShapes[.mouthSmileLeft] as! CGFloat
        let rightMouthSmileValue = faceAnchor.blendShapes[.mouthSmileRight] as! CGFloat

        let smileValue = (leftMouthSmileValue + rightMouthSmileValue)/2.0
        let faceState = FaceState.init(smileValue: smileValue)

        DispatchQueue.main.async {
            // Update ui
            self.delegate?.faceSmileTracker(self, needsFaceUpdate: faceState)
        }
    }
    
}

extension FaceSmileTracker {
    
    enum FaceState{
        case idle, normal, smiling
        
        init(smileValue: Double) {
            
            switch smileValue {
            case _ where smileValue > 0.5:
                self = .smiling
            case _ where smileValue > 0.2:
                self = .normal
            default:
                self = .idle
            }
        }
    }

    // MARK: - Errors
    enum FaceSmileTrackerError: Error, CustomStringConvertible {
        case DeviceNotSupportAR
        case CameraAccessNotGranted
        
        var description: String {
            switch self {
                
            case .DeviceNotSupportAR:
                return "ARKit is not supported on this device"
            case .CameraAccessNotGranted:
                return "This app needs Camera Access to function. You can grant access in Settings."
            }
            
        }
    }
}
