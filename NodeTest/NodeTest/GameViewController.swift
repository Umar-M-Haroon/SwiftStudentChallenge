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
    var defaultSphereMaterial = SimpleMaterial(color: .darkGray, isMetallic: false)
    var metalMaterial = SimpleMaterial(color: .darkGray, isMetallic: false)
    var sphereRadius: Float = 0.0127 // half an inch or 1.27 cm
    override func awakeFromNib() {
        
//        arView.scene.anchors.append(testLoad3SpheresWith1Edge())
//        arView.scene.anchors.append(testLoad2Spheres1Edge())
        arView.environment.background = .color(.systemGray)
//        var t = testLoad3Spheres2Edge()
        let t = generateNetwork(n: 3)
//        let y = testLoad2Spheres1Edge()
        arView.scene.anchors.append(t)
//        arView.installGestures(.all, for: t)
        
    }
    func testLoad2Spheres1Edge() -> AnchorEntity {
        let sphere = MeshResource.generateSphere(radius: 0.03)
        let anchorEntity = AnchorEntity()
        let sphereEntity = ModelEntity(mesh: sphere, materials: [defaultSphereMaterial])
        anchorEntity.addChild(sphereEntity,preservingWorldTransform: true)
        arView.scene.anchors.append(anchorEntity)
        let sphere3 = MeshResource.generateSphere(radius: 0.03)
        let sphereEntity3 = ModelEntity(mesh: sphere3, materials: [metalMaterial])
        sphereEntity3.transform.translation += SIMD3<Float>(0.0, 0, 0.1)
//        print(midpoint(r1: sphereEntity, r2: sphereEntity3))
        let edgeBox = MeshResource.generateBox(size: SIMD3<Float>(0.025, 0.025, addEdge(r1: sphereEntity, r2: sphereEntity3)), cornerRadius: 0.025)
        
        let edgeMaterial = SimpleMaterial(color: .lightGray, isMetallic: true)
        
        let edge = ModelEntity(mesh: edgeBox, materials: [edgeMaterial])
        anchorEntity.addChild(sphereEntity3, preservingWorldTransform: true)
        anchorEntity.addChild(edge, preservingWorldTransform: true)
        
        sphereEntity.transform.translation +=  SIMD3<Float>(0, 0.05, 0)
        edge.look(at: sphereEntity3.position, from: sphereEntity.position, relativeTo: edge)
        edge.setPosition(midpoint(r1: sphereEntity, r2: sphereEntity3), relativeTo: nil)
        return anchorEntity
    }
    func testLoad3Spheres2Edge() -> AnchorEntity {
        //sphere at 0,0,0
        let sphere = MeshResource.generateSphere(radius: sphereRadius)
        let anchorEntity = AnchorEntity(world: Transform().matrix)
        let sphereEntity = ModelEntity(mesh: sphere, materials: [defaultSphereMaterial])
        anchorEntity.addChild(sphereEntity)
//        arView.scene.anchors.append(sphere)
        arView.scene.anchors.append(anchorEntity)

        //sphere at 0.1, 0.1, 0.1
        let sphere3 = MeshResource.generateSphere(radius: 0.03)
        let sphereEntity3 = ModelEntity(mesh: sphere3, materials: [metalMaterial])
        sphereEntity3.transform.translation += SIMD3<Float>(0.1, 0.1, 0.1)
        anchorEntity.addChild(sphereEntity3)
        //edge between sphere 0,0,0 and 0.1,0.1, 0.1
        let edgeBox = MeshResource.generateBox(size: SIMD3<Float>(0.025, 0.025, addEdge(r1: sphereEntity, r2: sphereEntity3)), cornerRadius: 0.025)
        
        let edgeMaterial = SimpleMaterial(color: .lightGray, isMetallic: true)
        
        let edge = ModelEntity(mesh: edgeBox, materials: [edgeMaterial])

        edge.setPosition(midpoint(r1: sphereEntity, r2: sphereEntity3), relativeTo: nil)
        edge.look(at: sphereEntity3.position, from: edge.position, relativeTo: sphereEntity)
        
        anchorEntity.addChild(edge)
        
        //sphere at 0,0.4,0.0
        let sphere2 = MeshResource.generateSphere(radius: 0.03)
        let sphereEntity2 = ModelEntity(mesh: sphere2, materials: [metalMaterial])
        sphereEntity2.transform.translation += SIMD3<Float>(0, 0.4, 0)
        anchorEntity.addChild(sphereEntity2)
        
        //edge between 0,0,0 and 0.0, 0.4, 0.0
        //should be between sphereEntity and sphereEntity2
        let edgeBox2 = MeshResource.generateBox(size: SIMD3<Float>(0.025, 0.025, addEdge(r1: sphereEntity, r2: sphereEntity2)), cornerRadius: 0.025)
        
        
        
        let edge2 = ModelEntity(mesh: edgeBox2, materials: [edgeMaterial])
    
        print(-midpoint(r1: sphereEntity2, r2: sphereEntity))
        edge2.transform.translation += -midpoint(r1: sphereEntity2, r2: sphereEntity)
        edge2.look(at: sphereEntity2.position, from: edge.position, relativeTo: sphereEntity)
        
        anchorEntity.addChild(edge2)
//        sphereEntity.addChild(edge)
//        edgeBoxEntity.transform.translation += SIMD3<Float>(0.30, 0, 0.0)
        return anchorEntity
    }
    func addEdge(r1: ModelEntity, r2: ModelEntity) -> Float {
        let diff = abs(r2.position - r1.position)
        return sqrt(diff.x * diff.x + diff.y * diff.y + diff.z * diff.z)
    }
    func addSphere() -> ModelEntity {
        let sphere = MeshResource.generateSphere(radius: 50.27)
        return ModelEntity(mesh: sphere, materials: [defaultSphereMaterial])
    }
    func midpoint(r1: ModelEntity, r2: ModelEntity) -> SIMD3<Float> {
        let diff = r2.position + r1.position
        return diff/2
    }
    func generatePlane() -> ModelEntity {
        let plane = MeshResource.generatePlane(width: 60.96, depth: 60.96)
        return ModelEntity(mesh: plane, materials: [SimpleMaterial(color: .green, isMetallic: false)])
    }
    func generateNetwork(n: Int) -> AnchorEntity {
        let anchorEntity = AnchorEntity(world: Transform().matrix)
        for _ in 0..<1 {
            let sphere = MeshResource.generateSphere(radius: sphereRadius)
            let sphere2 = MeshResource.generateSphere(radius: sphereRadius)
            let sphereEntity = ModelEntity(mesh: sphere, materials: [defaultSphereMaterial])
            anchorEntity.addChild(sphereEntity, preservingWorldTransform: true)
            let sphereEntity2 = ModelEntity(mesh: sphere2, materials: [defaultSphereMaterial])
            
            let randomTransform = SIMD3<Float>(
                Float.random(in: (sphereRadius*10)...(sphereRadius*20)),
                Float.random(in: (sphereRadius*10)...(sphereRadius*20)),
                Float.random(in: (sphereRadius*10)...(sphereRadius*20)))
            let randomTransform2 = SIMD3<Float>(
                Float.random(in: (sphereRadius*10)...(sphereRadius*20)),
                Float.random(in: (sphereRadius*10)...(sphereRadius*20)),
                Float.random(in: (sphereRadius*10)...(sphereRadius*20)))
            
//            print(addEdge(r1: sphereEntity, r2: sphereEntity2))
            sphereEntity2.transform.translation += randomTransform
            let sphereDistance = addEdge(r1: sphereEntity, r2: sphereEntity2)
            let edge = MeshResource.generateBox(size: SIMD3<Float>(sphereRadius*0.85, sphereRadius*0.85, sphereDistance), cornerRadius: (sphereRadius*0.85))
            let edgeEntity = ModelEntity(mesh: edge, materials: [defaultSphereMaterial])
            anchorEntity.addChild(sphereEntity2, preservingWorldTransform: true)
            anchorEntity.addChild(edgeEntity, preservingWorldTransform: true)
            sphereEntity.transform.translation += randomTransform
            edgeEntity.look(at: sphereEntity2.position, from: sphereEntity.position, relativeTo: edgeEntity)
            edgeEntity.setPosition(midpoint(r1: sphereEntity, r2: sphereEntity2), relativeTo: nil)
        }
        return anchorEntity
    }
//    func generateEdge() -> ModelEntity {
//
//    }
}
