//
//  GameViewController.swift
//  ARTest
//
//  Created by Umar Haroon on 3/31/21.
//

import UIKit
import RealityKit

class GameViewController: UIViewController {
    
    @IBOutlet var arView: ARView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Load the "Box" scene from the "Experience" Reality File
        let boxAnchor = try! Experience.loadBox()
        
        // Add the box anchor to the scene
        arView.scene.anchors.append(boxAnchor)
        let clone = boxAnchor.clone(recursive: true)
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
            
            self.arView.scene.anchors.append(clone)
            clone.node?.setPosition(SIMD3<Float>(50, 50, 50), relativeTo: boxAnchor)
            print(clone.position(relativeTo: boxAnchor))
            print(clone.position)
            print(boxAnchor.position)
        }
    }
}
