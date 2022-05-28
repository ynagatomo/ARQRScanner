# AR QR Scanner

![AppIcon]()

A minimal iOS AR(Augmented Reality) app that scans QR code in AR scene.

The app detects multiple QR codes in the AR scene at the same time.
It also places a plane and sphere virtual object on top of each QR code.
The decoded string of the QR code is displayed on the Xcode console.

The project;

- Xcode 13.4, Swift 5.5 (Swift Concurrency)
- Target: iOS / iPadOS 15.0 and later
- Frameworks: SwiftUI, ARKit, RealityKit2, Vision

It shows;

- QR code detection in ARFrame with Vision framework
- Raycasting to locate the QR code position in the AR scene
- Displaying polygon on top of the QR code using RealityKit 2 procedural geometry

Vision can detect many types of barcodes.
This project is limited to QR codes and mini QR codes.
You can easily remove the restrictions or specify other formats.

As Vision detects QR codes for each frame,
you can add a QR code tracking function with a small code change.

This project is a minimal implementation.
Please modify it and make your own AR app!

![Image]()
![GIF]()

## References

- Apple Documentation: API [VNDetectBarcodesRequest](https://developer.apple.com/documentation/vision/vndetectbarcodesrequest)
- Apple Documentation: API [VNBarcodeObservation](https://developer.apple.com/documentation/vision/vnbarcodeobservation)
- Apple Documentation: API [VNBarcodeSymbology](https://developer.apple.com/documentation/vision/vnbarcodesymbology)
- Apple Documentation: API [raycastQuery(from:allowing:alignment:)
](https://developer.apple.com/documentation/arkit/arframe/3194578-raycastquery)
- Apple Documentation: API [ARRaycastResult](https://developer.apple.com/documentation/arkit/arraycastresult)

![MIT License](http://img.shields.io/badge/license-MIT-blue.svg?style=flat)
