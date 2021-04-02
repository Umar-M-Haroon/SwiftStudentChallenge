//
//  GameViewController.swift
//  NodeTest
//
//  Created by Umar Haroon on 3/31/21.
//

import AppKit
import RealityKit

class GameViewController: NSViewController {
    
    @IBOutlet var arView: ARView!
    
    override func awakeFromNib() {
        // Load the "Box" scene from the "Experience" Reality File
//        let boxAnchor = try! Reality.loadNodeScene()
////        let boxAnchor = try! Reality.loadScene()
//        // Add the box anchor to the scene
////        boxAnchor.generateCollisionShapes(recursive: true)
////        arView.scene.anchors.append(boxAnchor)
//        let clone = try! Reality.loadNodeScene()
////        let boxAnchor = try! Reality.loadScene()
//        // Add the box anchor to the scene
////        clone.node?.transform.translation += SIMD3<Float>(100, 100, 100)
//        clone.generateCollisionShapes(recursive: true)
//        
//        arView.scene.anchors.append(clone)
////        let clone2 = try! Reality.loadScene()
//        let clone2 = clone.clone(recursive: true)
//        arView.scene.anchors.append(clone2)
//        clone2.node?.transform.translation += SIMD3<Float>(1, 0, 0)
//        clone.node?.transform.translation += SIMD3<Float>(-1, 0, 0)
//        let edge = try! Reality.loadEdge()
////        edge.edge?.transform.translation += SIMD3<Float>(-0.5, 0, 0)
//        var t = clone.node!.transform
//        t.translation += SIMD3<Float>(-clone.node!.position.x, 0, 0)
////        edge.edge?.move(to: t, relativeTo: nil)
//        edge.edge?.scale += SIMD3<Float>(0, 3, 0)
////        let ninetyDegreesInRad = 90.0 * Float.pi / 180.0
////        edge.edge?.transform.rotation += simd_quatf(angle: ninetyDegreesInRad, axis: SIMD3<Float>(0,0,1))
//        arView.scene.anchors.append(edge)
//        
        let testEdge = MeshResource.
        
        
    }
}
