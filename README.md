<div align="center">
  <img width="100" src="https://user-images.githubusercontent.com/35783310/182454335-fbb17362-2e45-4fb1-a673-5d54c828313f.png" alt="Icon" /> <br>
  Smile Face Unlock <br>  <br>

![GitHub top language](https://img.shields.io/github/languages/top/m-afham/SmileToUnlock?color=red)
![Platform](https://img.shields.io/cocoapods/p/ios?color=red)

A screen that unlocks itself when you smile.
</div>

## Requirements

- iOS 11.0+
- Swift 4+

## How it is built?

- ARKit with "ARFaceTrackingConfiguration" to detect smiles using the front camera
- Lottie-ios for animations
- UIImpactFeedbackGenerator for haptic feedback
- UIView animations and transitions for better UX

## Usage

- Download the zip file, and copy and paste the "SmileLockVC" folder into your project. 
- You need to install the Lottie-ios ( https://github.com/airbnb/lottie-ios.git )  package to run animations.  

To show, write this line anywhere in your view controller
```Swift
 SmileLockVC.present(callingVC: self)
 ```


