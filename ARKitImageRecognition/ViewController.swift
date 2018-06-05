//
//  ViewController.swift
//  Image Recognition
//
//  Created by Jayven Nhan on 3/20/18.
//  Copyright © 2018 Jayven Nhan. All rights reserved.
//

import UIKit
import ARKit
import ARCharts

class ViewController: UIViewController {


    static var barChart: ARBarChart?
    private let arKitColors = [
        UIColor(red: 238.0 / 255.0, green: 109.0 / 255.0, blue: 150.0 / 255.0, alpha: 1.0),
        UIColor(red: 70.0  / 255.0, green: 150.0 / 255.0, blue: 150.0 / 255.0, alpha: 1.0),
        UIColor(red: 134.0 / 255.0, green: 218.0 / 255.0, blue: 255.0 / 255.0, alpha: 1.0),
        UIColor(red: 237.0 / 255.0, green: 231.0 / 255.0, blue: 254.0 / 255.0, alpha: 1.0),
        UIColor(red: 0.0   / 255.0, green: 110.0 / 255.0, blue: 235.0 / 255.0, alpha: 1.0),
        UIColor(red: 193.0 / 255.0, green: 193.0 / 255.0, blue: 255.0 / 255.0, alpha: 1.0),
        UIColor(red: 84.0  / 255.0, green: 204.0 / 255.0, blue: 254.0 / 255.0, alpha: 1.0)
    ]
    var settings = Settings()
    var dataSeries: ARDataSeries!
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
       // sceneView.debugOptions = ARSCNDebugOptions.showFeaturePoints
        sceneView.preferredFramesPerSecond = 60
        if let camera = sceneView.pointOfView?.camera {
            camera.wantsHDR = true
            camera.wantsExposureAdaptation = true
            camera.exposureOffset = -1
            camera.minimumExposure = -1
        }
        configureLighting()
        setupHighlightGesture()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        resetTrackingConfiguration()
        addBarChart()
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
    
    //func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
    //    print(node.position)
    //}
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        guard let imageAnchor = anchor as? ARImageAnchor else { return }
        let referenceImage = imageAnchor.referenceImage
        let imageName = referenceImage.name ?? "no name"
        
        print("Creating image \(imageName)")
        
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
        case "qr-code-1":
            node = Models.Drone
            break
        case "qr-code-2":
            node = Models.Exhaust
            break
        case "qr-code-3":
            node = Models.Propeller
            break
        case "qr-code-4":
            node = Models.PS2
            break
        case "qr-code-5":
            node = Models.Wheel
            break
        case "qr-code-6":
            node = Models.Zahnrad
            break
        default:
            break
        }
        return node
    }
    
}

extension ViewController {
    func setupHighlightGesture() {
        let longPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(_:)))
        self.view.addGestureRecognizer(longPressRecognizer)
    }
    
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
    
    private func setupGraph() {
        ViewController.barChart!.animationType = settings.animationType
        ViewController.barChart!.size = SCNVector3(settings.graphWidth, settings.graphHeight, settings.graphLength)
    }
    
    @objc func handleLongPress(_ gestureRecognizer: UITapGestureRecognizer) {
        guard gestureRecognizer.state == .began else { return }
        var labelToHighlight: ARChartLabel?
        
        let animationStyle = settings.longPressAnimationType
        let animationDuration = 0.3
        let longPressLocation = gestureRecognizer.location(in: self.view)
        let selectedNode = self.sceneView.hitTest(longPressLocation, options: nil).first?.node
        if let barNode = selectedNode as? ARBarChartBar {
            ViewController.barChart!.highlightBar(atIndex: barNode.index, forSeries: barNode.series, withAnimationStyle: animationStyle, withAnimationDuration: animationDuration)
        } else if let labelNode = selectedNode as? ARChartLabel {
            // Detect long press on label text
            labelToHighlight = labelNode
        } else if let labelNode = selectedNode?.parent as? ARChartLabel {
            // Detect long press on label background
            labelToHighlight = labelNode
        }
        
        if let labelNode = labelToHighlight {
            switch labelNode.type {
            case .index:
                ViewController.barChart!.highlightIndex(labelNode.id, withAnimationStyle: animationStyle, withAnimationDuration: animationDuration)
            case .series:
                ViewController.barChart!.highlightSeries(labelNode.id, withAnimationStyle: animationStyle, withAnimationDuration: animationDuration)
            }
        }
        
        let tapToUnhighlight = UITapGestureRecognizer(target: self, action: #selector(handleTapToUnhighlight(_:)))
        self.view.addGestureRecognizer(tapToUnhighlight)
    }
    
    @objc func handleTapToUnhighlight(_ gestureRecognizer: UITapGestureRecognizer) {
        ViewController.barChart!.unhighlight()
        self.view.removeGestureRecognizer(gestureRecognizer)
    }
    
    func addBarChart() {
      
        var values = generateRandomNumbers(withRange: 0..<50, numberOfRows: settings.numberOfSeries, numberOfColumns: settings.numberOfIndices)
        var seriesLabels = Array(0..<values.count).map({ "Series \($0)" })
        var indexLabels = Array(0..<values.first!.count).map({ "Index \($0)" })
        
        
        if settings.dataSet > 0 {
            values = generateNumbers(fromDataSampleWithIndex: settings.dataSet - 1) ?? values
            seriesLabels = parseSeriesLabels(fromDataSampleWithIndex: settings.dataSet - 1) ?? seriesLabels
            indexLabels = parseIndexLabels(fromDataSampleWithIndex: settings.dataSet - 1) ?? indexLabels
        }
        
        dataSeries = ARDataSeries(withValues: values)
        if settings.showLabels {
            dataSeries?.seriesLabels = seriesLabels
            dataSeries?.indexLabels = indexLabels
            dataSeries?.spaceForIndexLabels = 0.2
            dataSeries?.spaceForIndexLabels = 0.2
        } else {
            dataSeries?.spaceForIndexLabels = 0.0
            dataSeries?.spaceForIndexLabels = 0.0
        }
        dataSeries?.barColors = arKitColors
        dataSeries?.barOpacity = settings.barOpacity
        
        ViewController.barChart = ARBarChart()
        if let barChart = ViewController.barChart {
            barChart.dataSource = dataSeries
            barChart.delegate = dataSeries
            setupGraph()

            barChart.draw()
        }
    }

}
