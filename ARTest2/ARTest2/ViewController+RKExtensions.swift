//
//  ViewController+RKExtensions.swift
//  ARTest2
//
//  Created by Umar Haroon on 4/18/21.
//

import Foundation
import RealityKit
import ARKit
import InfectionGraphKit
extension ViewController {
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
//        print("adding edge with name: \(edgeEntity.name)")
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
            sphereEntity.collision = CollisionComponent(shapes: [ShapeResource.generateSphere(radius: sphereRadius)])
            sphereEntity.transform.scale += SIMD3<Float>(Float(graph.nodes[n].degree() * numberOfNodes/100),Float(graph.nodes[n].degree()*numberOfNodes/100),Float(graph.nodes[n].degree()*numberOfNodes/100))
            sphereEntity.name = "Node: \(graph.nodes[n].id)"
            anchorEntity.addChild(sphereEntity, preservingWorldTransform: true)
//            arView.installGestures([.translation], for: sphereEntity)
        }
        print("ADDED NODES: \(anchorEntity.children.count)")
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
    func removeEdgesForNode(_ node: ModelEntity) {
        guard let graphnode = graph.nodes.first(where: { $0.toRKFormat() == node.name}) else { return }
        for node in graph.nodes {
            for edge in node.edges {
                if edge.u.id == graphnode.id || edge.v.id == graphnode.id {
                    if let e = anchorEntity.findEntity(named: edge.toRKFormat()) {
                        var newTransform = e.transform
                        newTransform.scale = SIMD3<Float>(x: 0, y: 0, z: 0)
                        e.move(to: newTransform, relativeTo: e.parent, duration: 1.5)
                        
                        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1.5) {
                            e.removeFromParent()
                        }
                    }
                    if let reversedE = anchorEntity.findEntity(named:  edge.reverseRKFormat()) {
                        var newTransform = reversedE.transform
                        newTransform.scale = SIMD3<Float>(x: 0, y: 0, z: 0)
                        reversedE.move(to: newTransform, relativeTo: reversedE.parent, duration: 1.5)
                        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1.5) {
                            reversedE.removeFromParent()
                        }
                    }
                }
            }
        }
        for edge in graphnode.edges {
//            print("Looking for edge: \(RKFormatEdge(e: edge)) or \(ReverseRKFormatEdge(e: edge))")
            if let e = anchorEntity.findEntity(named: edge.toRKFormat()) {
                var newTransform = e.transform
                newTransform.scale = SIMD3<Float>(x: 0, y: 0, z: 0)
                e.move(to: newTransform, relativeTo: e.parent, duration: 1.5)
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1.5) {
                    e.removeFromParent()
                }

            }
            if let reversedE = anchorEntity.findEntity(named:  edge.reverseRKFormat()) {
                var newTransform = reversedE.transform
                newTransform.scale = SIMD3<Float>(x: 0, y: 0, z: 0)
                reversedE.move(to: newTransform, relativeTo: reversedE.parent, duration: 1.5)
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1.5) {
                    reversedE.removeFromParent()
                }
            }
        }
    }
    
    func RKAddAntiVaxxers() {
        for node in infectionHandler.graph.nodes.filter({$0.metaData == .antiVax}) {
            guard let nodeEntity = anchorEntity.findEntity(named: node.toRKFormat()) as? ModelEntity else {
                continue
            }
            print("adding anti-vax node \(node.toRKFormat())")
            nodeEntity.model?.materials = [SimpleMaterial(color: .yellow, isMetallic: false)]
            antiVaxxerNodeIDs.insert(node.toRKFormat())
        }
        assert(antiVaxxerNodeIDs.count == infectionHandler.graph.nodes.filter({$0.metaData == .antiVax}).count)
    }
    func RKInfectNodes() {
        for node in infectionHandler.graph.nodes.filter({$0.SIRState == .Infected}) {
            guard let nodeEntity = anchorEntity.findEntity(named: node.toRKFormat()) as? ModelEntity else {
                continue
            }
            nodeEntity.model?.materials = [SimpleMaterial(color: .red, isMetallic: false)]
        }
    }
    func hasEdges(_ node: ModelEntity) -> Bool {
        guard let graphnode = graph.nodes.first(where: { $0.toRKFormat() == node.name}) else { return false }
        for node in graph.nodes {
            for edge in node.edges {
                if edge.u.id == graphnode.id || edge.v.id == graphnode.id {
                    if let _ = anchorEntity.findEntity(named: edge.toRKFormat()) {
                        return true
                    }
                    if let _ = anchorEntity.findEntity(named:  edge.reverseRKFormat()) {
                        return true
                    }
                }
            }
        }
        for edge in graphnode.edges {
            if let _ = anchorEntity.findEntity(named: edge.toRKFormat()) {
                return true
            }
            if let _ = anchorEntity.findEntity(named:  edge.reverseRKFormat()) {
                return true
            }
        }
        return false
    }
}
