//
//  ARScene.swift
//  arqrscanner
//
//  Created by Yasuhito Nagatomo on 2022/05/26.
//

import ARKit
import RealityKit
import Combine

final class ARScene {
    enum State { case stop, scanning }
    private var state: State = .stop
    private var accumulativeTime: Double = 0.0
    private let detectionIntervalTime: Double = 3.0 // scanning interval [sec]
    private var renderLoopSubscription: Cancellable?

    private var arView: ARView!
    private var baseEntity = Entity()

    private let qrCodeCollection = QRCodeCollection()

    init(arView: ARView, anchor: AnchorEntity) {
        self.arView = arView
        anchor.addChild(baseEntity)
    }

    func startSession() {
        startScanning()
    }

    func stopSession() {
        stopScanning()
    }
}

extension ARScene {
    private func startScanning() {
        guard state == .stop else { return }
        state = .scanning
        renderLoopSubscription = arView.scene.subscribe(to: SceneEvents.Update.self) { event in
            // This closure will be called on the Main Thread.
            // print("LOG: render subscription runs on \(Thread.isMainThread ? "(m)" : "(-)")")

            // Scan QR code periodically
            self.accumulativeTime += event.deltaTime
            if self.accumulativeTime > self.detectionIntervalTime {
                guard let frame = self.arView.session.currentFrame else { return }
                self.accumulativeTime = 0 // clear after confirmation of frame existence
                Task {
                    // scan the QR code
                    let qrcodes = self.scan(frame: frame)
                    // place virtual objects in the AR scene
                    if !qrcodes.isEmpty {
                        await MainActor.run {
                            for qrcode in qrcodes {
                                if !self.qrCodeCollection.isIncluded(qrcode) {
                                    self.qrCodeCollection.add(qrcode)
                                    self.placeQRCodeModel(at: qrcode)
                                    print("LOG: payload = \(qrcode.payload ?? "")")
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    private func stopScanning() {
        guard state == .scanning else { return }
        state = .stop
        renderLoopSubscription?.cancel()
        renderLoopSubscription = nil
    }

    // Scans multiple QR code in the ARFrame
    // and calculates their positions in the AR scene.
    private func scan(frame: ARFrame) -> [QRCode] {
        var codes: [QRCode] = []

        // Scan QR code with Vision

        let request = VNDetectBarcodesRequest()
        // By default, a request scans for all symbologies of barcode.
        // Limit for QR code and micro QR code.
        request.symbologies = [VNBarcodeSymbology.qr, VNBarcodeSymbology.microQR]

        // [Note] VNRequest.preferBackgroundProcessing is false by default.
        // print("LOG: VNRequest.preferBackgroundProcessing = \(request.preferBackgroundProcessing)")

        let handler = VNImageRequestHandler(cvPixelBuffer: frame.capturedImage)
        do {
            try handler.perform([request])
        } catch {
            return []   // error occurred.
        }

        guard let results = request.results  //  [VNBarcodeObservation]?
        else {
            return [] // VNRequest produced no result.
        }

        // Convert detected QR code's 2d-positions to 3d-positionss in the AR scene
        for result in results {
            // [Note] VNBarcodeObservation.barcodeDescriptor can be used
            //        to regenerate the barcode with CoreImage.
            // [Note] VNBarcodeObservation.symbology can be used
            //        to identify the barcode type.
            // [Note] VNObservation.confidence [0, 1] can be used
            //        to check the level of confidence.

            // project four 2d-points to the closest 3d-points
            let vertices: [matrix_float4x4] = [
                result.topLeft,     // CGPoint - 2d point [0.0...1.0]
                result.topRight,
                result.bottomLeft,
                result.bottomRight
            ].compactMap {
                // convert Vision coordinate (+Y up) to UIKit coordinate (+Y down)
                let pos2d = CGPoint(x: $0.x, y: 1.0 - $0.y)
                // project the 2d-point onto any plane in the 3d scene
                let query = frame.raycastQuery(from: pos2d, allowing: .estimatedPlane,
                                   alignment: .any)
                // take the nearest 3d-point of projected points
                guard let hitPoint3d = self.arView.session.raycast(query).first
                else {
                    return nil // no projected point
                }

                // [Note] hitTest(_:types:) API is deprecated
                //    guard let hitFeature = frame.hitTest($0, // CGPoint
                //              types: .featurePoint) // .existingPlane or .featurePoint

                // [Note] ARRaycastResult.targetAlignment can be used
                //        to know the surface alignment, any | horizontal | vertical.
                return hitPoint3d.worldTransform
            }

            // check the vertices of the QR code
            if QRCode.isValid(vertices: vertices) {
                codes.append(QRCode(vertices: vertices,
                                    payload: result.payloadStringValue))
            }
        } // for
        return codes
    }
}

extension ARScene {
    // Places virtual objects of the QR code in the AR scene
    private func placeQRCodeModel(at qrcode: QRCode) {
        assert(qrcode.vertices.count == 4)
        var positions: [SIMD3<Float>] = []

        // place a polygon on top of the QR code

        for vertex in qrcode.vertices { // 0:top-left, 1:-right, 2:bottom-left, 3:-right
            positions.append(SIMD3<Float>(vertex[3].x,
                                          vertex[3].y, vertex[3].z))
        }
        let counts: [UInt8] = [4] // four vertices for one polygon
        let indices: [UInt32] = [0, 2, 3, 1] // one polygon

        var descriptor = MeshDescriptor()
        descriptor.positions = MeshBuffers.Positions(positions)
        descriptor.primitives = .polygons(counts, indices) // counts, indices
        descriptor.materials = .allFaces(0)

        let matPolygon = SimpleMaterial(color: UIColor.randomColor(alpha: 0.8),
                                      isMetallic: false)
        if let meshPolygon = try? MeshResource.generate(from: [descriptor]) {
            let model = ModelEntity(mesh: meshPolygon,
                                    materials: [matPolygon])
            baseEntity.addChild(model)
        } else {
            fatalError("failed to generate mesh-resource.")
        }

        // place a sphere on top of the QR code

        let meshSphere = MeshResource.generateSphere(radius: 0.01)
        let matSphere = SimpleMaterial(color: UIColor.randomColor(alpha: 1.0),
                                      isMetallic: false)
        let model = ModelEntity(mesh: meshSphere, materials: [matSphere])
        model.transform.translation = qrcode.center
        baseEntity.addChild(model)
    }
}
