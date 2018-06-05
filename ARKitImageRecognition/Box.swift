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
        let shitnode = SCNNode()
        shitnode.scale = SCNVector3(
        1.0 / scaleBox.x,
        1.0 / scaleBox.y,
        1.0 / scaleBox.z)
        let node = scene!.rootNode
        self.interior.scale = scaleObject
        shitnode.addChildNode(self.interior)
        node.addChildNode(shitnode)
        node.scale = self.scaleBox
        return node
    }()
}

let spinAction: SCNAction = {
    return .repeatForever(
        .rotateBy(x: 1, y: 1, z: 10, duration: 10)
    )
}()

let fastSpinAction: SCNAction = {
    return .repeatForever(
        .rotateBy(x: 0, y: 10, z: 0, duration: 0.5)
    )
}()
let fastSpinRotor: SCNAction = {
    return .repeatForever(
        .rotateBy(x: 0, y: 0, z: 10, duration: 0.5)
    )
}()

class Models {
    static let None = SCNNode()
    static let Propeller : SCNNode = {
        let interiorNode = SCNScene(named: "Propeller.scn")!.rootNode
        interiorNode.runAction(spinAction)
        return Box(interior: interiorNode,
           scaleObject: SCNVector3(0.05, 0.05, 0.05),
           scaleBox: SCNVector3(0.285, 0.215, 0.215)).node
    }()
    
    static let PS2 : SCNNode = {
        let interiorNode = SCNScene(named: "Playstation 2.scn")!.rootNode
        //interiorNode.runAction(spinAction)
        interiorNode.eulerAngles = SCNVector3(0, Float.pi / 2, 0)
        return Box(interior: interiorNode,
                   scaleObject: SCNVector3(0.04, 0.04, 0.04),
                   scaleBox: SCNVector3(0.31, 0.115, 0.24)).node
    }()
    
    static let Drone : SCNNode = {
        let interiorNode = SCNScene(named: "Drone.scn")!.rootNode
        let rotorL = interiorNode.childNode(withName: "Rotor_L", recursively: true)
        let rotorR = interiorNode.childNode(withName: "Rotor_R", recursively: true)
        rotorL?.runAction(fastSpinRotor)
        rotorR?.runAction(fastSpinRotor)
        //interiorNode.runAction(spinAction)
        interiorNode.eulerAngles = SCNVector3(-90, 0, 0)
        return Box(interior: interiorNode,
                   scaleObject: SCNVector3(0.3, 0.3, 0.3),
                   scaleBox: SCNVector3(0.325, 0.175, 0.25)).node
    }()
    
    static let Zahnrad : SCNNode = {
        let interiorNode = SCNScene(named: "Zahnrad.scn")!.rootNode
        interiorNode.runAction(spinAction)
        return Box(interior: interiorNode,
                   scaleObject: SCNVector3(0.04, 0.04, 0.04),
                   scaleBox: SCNVector3(0.255, 0.192, 0.303)).node
    }()
    
    static let Exhaust : SCNNode = {
        let interiorNode = SCNScene(named: "Exhaust.scn")!.rootNode
        interiorNode.eulerAngles = SCNVector3(90, 45, 0)
        return Box(interior: interiorNode,
                   scaleObject: SCNVector3(0.025, 0.025, 0.025),
                   scaleBox: SCNVector3(0.195, 0.063, 0.23)).node
    }()
    
    static let Wheel : SCNNode = {
        let interiorNode = SCNScene(named: "Wheel.scn")!.rootNode
        interiorNode.runAction(fastSpinAction)
        return Box(interior: interiorNode,
                   scaleObject: SCNVector3(0.035, 0.035, 0.035),
                   scaleBox: SCNVector3(0.195, 0.063, 0.23)).node
    }()
}
