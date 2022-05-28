//
//  ARViewController.swift
//  arqrscanner
//
//  Created by Yasuhito Nagatomo on 2022/05/26.
//

import UIKit
import ARKit
import RealityKit

final class ARViewController: UIViewController {
    private var arView: ARView!
    private var arScene: ARScene!

    override func viewDidLoad() {
        #if targetEnvironment(simulator)
        arView = ARView(frame: .zero)
        #else
        if ProcessInfo.processInfo.isiOSAppOnMac {
            arView = ARView(frame: .zero, cameraMode: .nonAR,
                            automaticallyConfigureSession: true)
        } else {
            arView = ARView(frame: .zero, cameraMode: .ar,
                            automaticallyConfigureSession: true)
        }
        #endif
        // arView.session.delegate = self

        #if DEBUG
        arView.debugOptions = [.showFeaturePoints]
        #endif

        view = arView
        let anchorEntity = AnchorEntity()
        arView.scene.addAnchor(anchorEntity)
        arScene = ARScene(arView: arView, anchor: anchorEntity)

        #if !targetEnvironment(simulator)
        if !ProcessInfo.processInfo.isiOSAppOnMac {
            let config = ARWorldTrackingConfiguration()
            // RayCasting uses detected planes.
            config.planeDetection = [.horizontal, .vertical]
            arView.session.run(config)
        }
        #endif

        arScene.startSession()
    }

    override func viewWillDisappear(_ animated: Bool) {
        arScene.stopSession()
    }
}
