//
//  Box.swift
//  ARKitImageRecognition
//
//  Created by Philipp Meyer on 04.06.18.
//  Copyright © 2018 Jayven Nhan. All rights reserved.
//

import Foundation
import UIKit
import ARKit

class Box {
    init(interior: SCNNode, scaleObject: SCNVector3, scaleBox: SCNVector3) {
        self.interior = interior
        self.scaleObject = scaleObject
        self.scaleBox = scaleBox
    }
    var interior: SCNNode
    var scaleObject: SCNVector3
    var scaleBox: SCNVector3
    
    lazy var node: SCNNode = {
        let scene = SCNScene(named: "boxinv.scn")
        let node = scene!.rootNode
        self.interior.scale = SCNVector3(
            scaleObject.x / scaleBox.x,
            scaleObject.y / scaleBox.y,
            scaleObject.z / scaleBox.z)
        node.addChildNode(self.interior)
        node.scale = self.scaleBox
        return node
    }()
}

let spinAction: SCNAction = {
    return .repeatForever(
        .rotateBy(x: 1, y: 1, z: 10, duration: 10)
    )
}()

class Models {
    static let Propeller : SCNNode = {
        let interiorNode = SCNScene(named: "Propeller.scn")!.rootNode
        interiorNode.runAction(spinAction)
        return Box(interior: interiorNode,
           scaleObject: SCNVector3(0.05, 0.05, 0.05),
           scaleBox: SCNVector3(0.215, 0.215, 0.285)).node
    }()
}
