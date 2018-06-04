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
    
    lazy var treeNode: SCNNode = {
        guard let scene = SCNScene(named: "tree.scn"),
            let node = scene.rootNode.childNode(withName: "tree", recursively: false) else { return SCNNode() }
        let scaleFactor = 0.005
        node.scale = SCNVector3(scaleFactor, scaleFactor, scaleFactor)
        node.eulerAngles.x = -.pi / 2
        return node
    }()
    
    lazy var propellerNode: SCNNode = {
        guard let scene = SCNScene(named: "p2.scn"),
            let node = scene.rootNode.childNode(withName: "p2", recursively: false) else { return SCNNode() }
        let scaleFactor = 1
        node.scale = SCNVector3(scaleFactor, scaleFactor, scaleFactor)
        node.eulerAngles.x = -.pi / 2
        return node
    }()
    
    lazy var boxNode: SCNNode = {
        let scene = SCNScene(named: "boxinv.scn")
        let node = scene!.rootNode
        let propeller = SCNScene(named: "Propeller.scn")!.rootNode
        propeller.scale = SCNVector3(0.3, 0.3, 0.3)
        node.addChildNode(propeller)
        let scaleFactor = 0.3
        node.scale = SCNVector3(scaleFactor, scaleFactor, scaleFactor)
        node.eulerAngles.x = -.pi / 2
    
        return node
    }()
    
    lazy var bookNode: SCNNode = {
        guard let scene = SCNScene(named: "book.scn"),
            let node = scene.rootNode.childNode(withName: "book", recursively: false) else { return SCNNode() }
        let scaleFactor  = 0.1
        node.scale = SCNVector3(scaleFactor, scaleFactor, scaleFactor)
        return node
    }()
    
    lazy var mountainNode: SCNNode = {
        guard let scene = SCNScene(named: "mountain.scn"),
            let node = scene.rootNode.childNode(withName: "mountain", recursively: false) else { return SCNNode() }
        let scaleFactor  = 0.25
        node.scale = SCNVector3(scaleFactor, scaleFactor, scaleFactor)
        node.eulerAngles.x += -.pi / 2
        return node
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
        
//        let scene = SCNScene(named: "Light.scn")
//        let node = scene!.rootNode
////        node.transform = sceneView.pointOfView!.transform
//        sceneView.pointOfView?.addChildNode(node)
        
        let light = SCNLight()
        light.type = SCNLight.LightType.spot
        light.spotInnerAngle = 50.0
        light.spotOuterAngle = 80.0
        light.shadowRadius = 10
        light.zNear = 0.1
        light.shadowColor = UIColor(displayP3Red: 0, green: 0, blue: 0, alpha: 0.5).cgColor
        light.zFar = 100
        light.shadowMapSize = CGSize(width: 3000.0, height: 3000.0)
        //light.shadowMode = .modulated
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
        print(node)
        print(anchor)
        guard let imageAnchor = anchor as? ARImageAnchor else { return }
        let referenceImage = imageAnchor.referenceImage
        let imageName = "box" //referenceImage.name ?? "no name"
        
        
//        let plane = SCNPlane(width: referenceImage.physicalSize.width, height: referenceImage.physicalSize.height)
//        let planeNode = SCNNode(geometry: plane)
//        planeNode.opacity = 0.20
//        planeNode.eulerAngles.x = -.pi / 2
//        node.addChildNode(planeNode)
        let overlayNode = self.getNode(withImageName: imageName)
        overlayNode.opacity = 0
        overlayNode.position.y = -0.2
        overlayNode.runAction(self.fadeAction)
        //overlayNode.transform = SCNMatrix4Mult(node.transform, node.parent!.transform) //SCNMatrix4(anchor.transform)
        node.addChildNode(overlayNode)
        
        //sceneView.scene.rootNode.addChildNode(overlayNode)
//        let box = self.getNode(withImageName: "box")
//        box.opacity = 0
//        box.position.y = -0.02
//        box.runAction(self.fadeAction)
//        node.addChildNode(box)

        DispatchQueue.main.async {
            self.label.text = "Image detected: \"\(imageName)\""
            
          //  (self.sceneView.session.configuration! as! ARWorldTrackingConfiguration).detectionImages!.remove(referenceImage)
            //self.referenceImages?.remove(referenceImage)
            //self.resetTrackingConfiguration()
        }
    }
    
   // func renderer(_ renderer: SCNSceneRenderer, didRemove node: SCNNode, for anchor: ARAnchor) {
   //     DispatchQueue.main.async {
   //         self.referenceImages?.insert((anchor as! ARImageAnchor).referenceImage)
   //         self.resetTrackingConfiguration()
   //     }
   // }

    func getPlaneNode(withReferenceImage image: ARReferenceImage) -> SCNNode {
        let plane = SCNPlane(width: image.physicalSize.width,
                             height: image.physicalSize.height)
        let node = SCNNode(geometry: plane)
        return node
    }
    
    func getNode(withImageName name: String) -> SCNNode {
        var node = SCNNode()
        switch name {
        case "qrcode-large":
            node = propellerNode
        case "box":
            node = boxNode
        case "qrcode-mid":
            node = mountainNode
        case "qrcode-small":
            node = treeNode
        case "qrcode-small-2":
            node = bookNode
        default:
            break
        }
        return node
    }
    
}
