//
//  ViewController.swift
//  Image Recognition
//
//  Created by Jayven Nhan on 3/20/18.
//  Copyright © 2018 Jayven Nhan. All rights reserved.
//

import UIKit
import ARKit

class ViewController: UIViewController {

    override open var shouldAutorotate: Bool {
        return false
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.portrait
    }
    
    @IBOutlet weak var sceneView: ARSCNView!
    @IBOutlet weak var label: UILabel!
    
    let fadeDuration: TimeInterval = 0.3
    let rotateDuration: TimeInterval = 3
    let waitDuration: TimeInterval = 5
    var referenceImages = ARReferenceImage.referenceImages(inGroupNamed: "AR Resources", bundle: nil)
    
    
    lazy var fadeAndSpinAction: SCNAction = {
        return .sequence([
            .fadeIn(duration: fadeDuration),
            .rotateBy(x: 0, y: 0, z: CGFloat.pi * 360 / 180, duration: rotateDuration),
            .wait(duration: waitDuration),
            .fadeOut(duration: fadeDuration)
            ])
    }()
    
    lazy var fadeAction: SCNAction = {
        return .sequence([
            .fadeOpacity(by: 0.9, duration: fadeDuration),
            .fadeIn(duration: fadeDuration),
        ])
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        sceneView.delegate = self
        sceneView.showsStatistics = true
        sceneView.debugOptions = ARSCNDebugOptions.showFeaturePoints
        sceneView.preferredFramesPerSecond = 60
        if let camera = sceneView.pointOfView?.camera {
            camera.wantsHDR = true
            camera.wantsExposureAdaptation = true
            camera.exposureOffset = -1
            camera.minimumExposure = -1
        }
        configureLighting()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        resetTrackingConfiguration()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        sceneView.session.pause()
    }
    
    func configureLighting() {
        let light = SCNLight()
        light.type = SCNLight.LightType.spot
        light.spotInnerAngle = 50.0
        light.spotOuterAngle = 80.0
        light.shadowRadius = 10
        light.zNear = 0.1
        light.shadowColor = UIColor(displayP3Red: 0, green: 0, blue: 0, alpha: 0.5).cgColor
        light.zFar = 100
        light.shadowMapSize = CGSize(width: 3000.0, height: 3000.0)
        light.castsShadow = true
        
        let lightNode = SCNNode()
        lightNode.position = SCNVector3(0, 0, 0.3)
        lightNode.light = light
        sceneView.pointOfView!.addChildNode(lightNode)

        sceneView.autoenablesDefaultLighting = false
        sceneView.automaticallyUpdatesLighting = false
    }
    
    @IBAction func resetButtonDidTouch(_ sender: UIBarButtonItem) {
        resetTrackingConfiguration()
    }
 
    func resetTrackingConfiguration() {
        let configuration = ARWorldTrackingConfiguration()
        configuration.detectionImages = self.referenceImages
        let options: ARSession.RunOptions = [.resetTracking, .removeExistingAnchors]
        sceneView.session.run(configuration, options: options)
        label.text = "Move camera around to detect QR Code"
    }
}

extension ViewController: ARSCNViewDelegate {
    
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        print(node.position)
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        guard let imageAnchor = anchor as? ARImageAnchor else { return }
        let referenceImage = imageAnchor.referenceImage
        let imageName = referenceImage.name ?? "no name"
        
        let overlayNode = self.getNode(withImageName: imageName)
        overlayNode.opacity = 0
        overlayNode.position.y = overlayNode.scale.y / -2
        overlayNode.runAction(self.fadeAction)
        node.addChildNode(overlayNode)

        DispatchQueue.main.async {
            self.label.text = "Image detected: \"\(imageName)\""
        }
    }
    
    func getNode(withImageName name: String) -> SCNNode {
        var node = SCNNode()
        switch name {
        case "qrcode-large":
            node =
        case "box":
            node = Models.Propeller
        case "qrcode-mid":
            node =
        case "qrcode-small":
            node =
        case "qrcode-small-2":
            node =
        default:
            break
        }
        return node
    }
    
}
