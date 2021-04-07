//
//  GameViewController.swift
//  ARTest
//
//  Created by Umar Haroon on 3/31/21.
//

import UIKit
import RealityKit
import InfectionGraphKit
class GameViewController: UIViewController {
    
    @IBOutlet var arView: ARView!
    var defaultSphereMaterial = SimpleMaterial(color: .darkGray, isMetallic: false)
    var metalMaterial = SimpleMaterial(color: .gray, isMetallic: true)
    var sphereRadius: Float = 0.0127 // half an inch or 1.27 cm
    var sphereObj = ModelEntity(mesh: .generateSphere(radius: 0.0127), materials: [SimpleMaterial(color: .darkGray, isMetallic: true)])
    var ids: [String] = []
    let anchorEntity = AnchorEntity(plane: .horizontal, classification: .any, minimumBounds: SIMD2<Float>(0.3,0.3))
    var numberOfNodes = 100
    var infectionHandler: InfectionHandler!
    var graph: Graph!
    override func viewDidLoad() {
        super.viewDidLoad()
        graph = Graph(numberOfNodes: numberOfNodes)
        infectionHandler = InfectionHandler(graph: graph, difficulty: .init(difficultyLevel: .hard))
        generateNetwork()
//        let y = testLoad2Spheres1Edge()
        arView.scene.anchors.append(anchorEntity)
//        arView.installGestures(.all, for: t)
        
    }
    func midpoint(r1: ModelEntity, r2: ModelEntity) -> SIMD3<Float> {
        let diff = r2.position + r1.position
        return diff/2
    }
    func generateNetwork() {
        addNodes(numberOfNodes: self.numberOfNodes)
        addEdges(graph: self.graph)
        
    }
    func addEdgeBetween(r1: String, r2: String) {
        guard
            let sphere = anchorEntity.findEntity(named: r1) as? ModelEntity,
            let sphere2 = anchorEntity.findEntity(named: r2) as? ModelEntity else { return }
        let diff = (sphere2.position - sphere.position)
        let dist = sqrt(diff.x * diff.x + diff.y * diff.y + diff.z * diff.z)
        let edge = MeshResource.generateBox(size: SIMD3<Float>(sphereRadius*0.85, sphereRadius*0.85, dist), cornerRadius: (sphereRadius*0.85))
        let edgeEntity = ModelEntity(mesh: edge, materials: [metalMaterial])
        edgeEntity.name = "Edge: \(r1) \(r2)"
        edgeEntity.look(at: sphere2.position, from: sphere.position, relativeTo: edgeEntity)
        edgeEntity.setPosition(midpoint(r1: sphere, r2: sphere2), relativeTo: nil)
        anchorEntity.addChild(edgeEntity)
        
    }
    func addNodes(numberOfNodes: Int) {
        
//        let anchorEntity = AnchorEntity(plane: .horizontal, classification: .any, minimumBounds: SIMD2<Float>(0.3,0.3))
        for n in 0..<numberOfNodes {
            let sphereEntity = sphereObj.clone(recursive: true)
            let randMax: Float = Float(numberOfNodes) * 2
            let randMin: Float = Float(numberOfNodes) / 2.0
            let randomTransform = SIMD3<Float>(
                Float.random(in: (sphereRadius*randMin)...(sphereRadius*randMax)),
                Float.random(in: (sphereRadius)...(sphereRadius*randMin)),
                Float.random(in: (sphereRadius*randMin)...(sphereRadius*randMax)))
            //            print(addEdge(r1: sphereEntity, r2: sphereEntity2))
            sphereEntity.transform.translation += randomTransform
            sphereEntity.transform.scale += SIMD3<Float>(Float(graph.nodes[n].degree()),Float(graph.nodes[n].degree()),Float(graph.nodes[n].degree()))
            sphereEntity.name = "Node: \(graph.nodes[n].id)"
            anchorEntity.addChild(sphereEntity, preservingWorldTransform: true)
        }
    }
    func addEdges(graph: Graph) {
        for node in graph.nodes {
            for edge in node.edges {
                let sphereID = "Node: \(edge.u.id)"
                let sphere2ID = "Node: \(edge.v.id)"
                let edgeID = "Edge: \(sphereID) \(sphere2ID)"
                let reversedEdgeID = "Edge: \(sphere2ID) \(sphereID)"
                if !checkForEdge(edgeID, reversedEdgeID) {
                    addEdgeBetween(r1: sphereID, r2: sphere2ID)
                }
            }
        }
    }
    func checkForEdge(_ edges: String...) -> Bool {
        for edge in edges {
            if anchorEntity.findEntity(named: edge) as? ModelEntity != nil {
                return true
            }
        }
        return false
    }
}
