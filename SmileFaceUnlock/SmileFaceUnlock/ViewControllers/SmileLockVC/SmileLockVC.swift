//
//  ViewController.swift
//  SmileTracker
//
//  Created by Muhammad Afham, Jake on 31/07/22.
//  Copyright © 2022 Muhammad Afham. All rights reserved.
//

import UIKit
import Lottie
import ARKit

class SmileLockVC: UIViewController {
    
    // MARK: - IBOutlets
    @IBOutlet weak var viewUnlockAnimation: AnimationView!
    @IBOutlet weak var constraintUnlockViewWidth: NSLayoutConstraint!
    @IBOutlet weak var viewSmilingAnimation: AnimationView!
    @IBOutlet weak var labelUnlock: UILabel!
    
    // MARK: - Dependencies
    lazy var faceSmileTracker: FaceSmileTracker = .init(vc: self)
    
    // MARK: - Properties
    private var isUnlocked: Bool = false
    
    // MARK: - Init
    private static func initializeVC() -> Self? {
        let identifier = "\(Self.self)"
        let bundle = Bundle.init(for: Self.self)
        let storyboard = UIStoryboard.init( name: "SmileLockVC",
                                            bundle: bundle)
        let viewController = storyboard.instantiateViewController(withIdentifier: identifier) as? Self
        return viewController
    }
    
    // MARK: - VC Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setUpUnlockAnimation()
        self.setUpSmileAnimation()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.faceSmileTracker.startTracking()
    }
}

// MARK: - Animations
extension SmileLockVC {
    func setUpUnlockAnimation() {
        viewUnlockAnimation.contentMode = .scaleAspectFit
        viewUnlockAnimation.animationSpeed = 1.5
    }
    
    func setUpSmileAnimation() {
        viewSmilingAnimation.contentMode = .scaleAspectFit
        viewSmilingAnimation.animationSpeed = 1.0
        viewSmilingAnimation.currentFrame = 49 // Seeing towards left down
    }
    
    func playSmileDetectedAnimation() {
        self.viewSmilingAnimation.play(fromFrame: 59,
                                       toFrame: 95,
                                       loopMode: .playOnce) { [weak self]  _ in
            guard let self = self else { return }
            
            UIView.animate(withDuration: 0.1,
                           delay: .zero,
                           options: [.curveEaseIn]) {
                
                self.viewSmilingAnimation.alpha = .zero
                
            } completion: { _ in
                self.playUnlockAnimation()
            }
            
        }
    }
   
    func playUnlockAnimation() {
        self.labelUnlock.text = "Unlocked!"
    
        /// Success Haptic Feedback
        Vibration.success.vibrate()
        
        /// Unlock Animation
        self.viewUnlockAnimation.play() { [weak self]  _ in
            guard let self = self else { return }
            
            self.labelUnlock.alpha = .zero
            
            // Scale and Reduce Alpha to 0, of root view
            UIView.animate(withDuration: 0.7) {
                
                self.view.transform = .init(scaleX: 5, y: 5)
                self.view.alpha = .zero
                
            } completion: { _ in
                
                /// Finally close the vc.
                self.closeVC()
            }
        }
    }
}

// MARK: - Face Smile Tracker Delegate
extension SmileLockVC: FaceSmileTrackerDelegate {
    func faceSmileTracker(_ tracker: FaceSmileTracker, needsFaceUpdate state: FaceSmileTracker.FaceState) {
      
        guard isUnlocked == false else { return }
        if state == .smiling {
            isUnlocked = true
            self.playSmileDetectedAnimation()
        }
    }
    
    func faceSmileTracker(_ tracker: FaceSmileTracker, failedWithError error:  NSError) {
        let alert = UIAlertController(title: "Error",
                                      message: error.description,
                                      preferredStyle: .alert)
        alert.addAction(.init(title: "Ok", style: .default))
        DispatchQueue.main.async {
            self.present(alert, animated: true)
        }
    }
    
    
}

// MARK: - Close VC
extension SmileLockVC {
    func closeVC() {
        DispatchQueue.main.async {
            self.dismiss(animated: false)
        }
    }
}

// MARK: - Show VC from any View Controller
extension SmileLockVC {
    static func present(callingVC: UIViewController) {
        guard let vc = initializeVC() else {
            fatalError("Could not initialize \(Self.self)")
        }
        vc.modalPresentationStyle = .overCurrentContext
        vc.modalTransitionStyle = .crossDissolve
        DispatchQueue.main.async {
            callingVC.present(vc, animated: true)
        }
    }
}
