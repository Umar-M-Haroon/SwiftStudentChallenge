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
    var defaultSphereMaterial = SimpleMaterial(color: .darkGray, isMetallic: false)
    var metalMaterial = SimpleMaterial(color: .blue, isMetallic: false)
    var sphereRadius: Float = 0.0127 // half an inch or 1.27 cm
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        let sphere = MeshResource.generateSphere(radius: 0.15)
//        let anchorEntity = AnchorEntity(world: Transform().matrix)
//        let sphereEntity = ModelEntity(mesh: sphere, materials: [metalMaterial])
//        anchorEntity.addChild(sphereEntity)
////        arView.scene.anchors.append(sphere)
//        let sphere2 = MeshResource.generateSphere(radius: 0.15)
//        let sphereEntity2 = ModelEntity(mesh: sphere2, materials: [metalMaterial])
//        sphereEntity.transform.translation += SIMD3<Float>(0.6, 0, 0.0)
//        anchorEntity.addChild(sphereEntity2)
//        let edgeBox = MeshResource.generateBox(size: SIMD3<Float>(sphereEntity.position(relativeTo: sphereEntity2).x, 0.05, sphereEntity.position(relativeTo: sphereEntity2).z), cornerRadius: 0.025)
//        let edgeMaterial = SimpleMaterial(color: .lightGray, isMetallic: true)
//
//        let edgeBoxEntity = ModelEntity(mesh: edgeBox, materials: [edgeMaterial])
//        anchorEntity.addChild(edgeBoxEntity)
//        edgeBoxEntity.transform.translation += SIMD3<Float>(0.30, 0, 0.0)
//        arView.scene.anchors.append(anchorEntity)
//
//        let sphere3 = MeshResource.generateSphere(radius: 0.15)
//        let sphereEntity3 = ModelEntity(mesh: sphere3, materials: [metalMaterial])
//        sphereEntity3.transform.translation += SIMD3<Float>(0.3, 0.3, 0.3)
//        anchorEntity.addChild(sphereEntity3)
//
//        let edgeBox2 = MeshResource.generateBox(size: SIMD3<Float>(sphereEntity.position(relativeTo: sphereEntity2).x, 0.05, sphereEntity.position(relativeTo: sphereEntity2).z), cornerRadius: 0.025)
//        let edgeBoxEntity2 = ModelEntity(mesh: edgeBox2, materials: [edgeMaterial])
//        anchorEntity.addChild(edgeBoxEntity)
//        anchorEntity.addChild(edgeBoxEntity2)
//        edgeBoxEntity.transform.translation += SIMD3<Float>(0.30, 0, 0.0)
//        let plane = generatePlane()
//        let sphere = addSphere()
////        anchorEntity.addChild(sphere)
//        anchorEntity.addChild(plane)
        let t = generateNetwork(n: 100)
//        let y = testLoad2Spheres1Edge()
        arView.scene.anchors.append(t)
//        arView.installGestures(.all, for: t)
        
    }
    func testLoad2Spheres1Edge() -> AnchorEntity {
        let sphere = MeshResource.generateSphere(radius: 0.03)
        let anchorEntity = AnchorEntity(plane: .horizontal, classification: .any, minimumBounds: SIMD2<Float>(0.0, 0.0))
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
    func generateNetwork(n: Int) -> AnchorEntity {
        let anchorEntity = AnchorEntity(plane: .horizontal, classification: .any, minimumBounds: SIMD2<Float>(0.3,0.3))
        for _ in 0..<(n/2)  {
            let sphere = MeshResource.generateSphere(radius: sphereRadius)
            let sphere2 = MeshResource.generateSphere(radius: sphereRadius)
            let sphereEntity = ModelEntity(mesh: sphere, materials: [defaultSphereMaterial])
            anchorEntity.addChild(sphereEntity, preservingWorldTransform: true)
            let sphereEntity2 = ModelEntity(mesh: sphere2, materials: [defaultSphereMaterial])
            let randMax: Float = Float(n) / 2.0
            let randMin: Float = 4.0
            let randomTransform = SIMD3<Float>(
                Float.random(in: (sphereRadius*randMin)...(sphereRadius*randMax)),
                Float.random(in: (sphereRadius*randMin)...(sphereRadius*randMax / 2)),
                Float.random(in: (sphereRadius*randMin)...(sphereRadius*randMax)))
            let randomTransform2 = SIMD3<Float>(
                Float.random(in: (sphereRadius*randMin)...(sphereRadius*randMax)),
                Float.random(in: (sphereRadius*randMin)...(sphereRadius*randMax/2)),
                Float.random(in: (sphereRadius*randMin)...(sphereRadius*randMax)))
            
//            print(addEdge(r1: sphereEntity, r2: sphereEntity2))
            sphereEntity2.transform.translation += randomTransform2
            let diff = (randomTransform2 - randomTransform)
            let dist = sqrt(diff.x * diff.x + diff.y * diff.y + diff.z * diff.z)
            let edge = MeshResource.generateBox(size: SIMD3<Float>(sphereRadius*0.85, sphereRadius*0.85, dist), cornerRadius: (sphereRadius*0.85))
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
