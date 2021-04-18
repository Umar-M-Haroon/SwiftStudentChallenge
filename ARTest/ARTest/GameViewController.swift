//
//  GameViewController.swift
//  ARTest
//
//  Created by Umar Haroon on 3/31/21.
//

import UIKit
import RealityKit
import InfectionGraphKit
import SwiftUI
import ARKit
class GameViewController: UIViewController {
    
    @IBOutlet weak var arView: ARView!
    @IBOutlet weak var infectionTitleLabel: UILabel!
    
    @IBOutlet weak var infectionHandlerLabel: UILabel!
    
    @IBOutlet weak var difficultyButton: UIButton!
    
    
    var defaultSphereMaterial = SimpleMaterial(color: .darkGray, isMetallic: false)
    var metalMaterial = SimpleMaterial(color: .gray, isMetallic: true)
    var sphereRadius: Float = 0.0127 // half an inch or 1.27 cm
    var sphereObj = ModelEntity(mesh: .generateSphere(radius: 0.0127), materials: [SimpleMaterial(color: .darkGray, isMetallic: true)])
    var ids: [String] = []
    var anchorEntity = AnchorEntity.init(plane: AnchoringComponent.Target.Alignment.any, classification: AnchoringComponent.Target.Classification.table, minimumBounds: SIMD2<Float>(0.0, 0.0))
    var numberOfNodes = 30
    var infectionHandler: InfectionHandler!
    var graph: Graph!
    
    let coachingOverlay = ARCoachingOverlayView()
    var easyDifficulty = Difficulty(difficultyLevel: .custom(1, 0.7, 3, 0))
    var mediumDifficulty = Difficulty(difficultyLevel: .custom(2, 0.7, 4, 0))
    var hardDifficulty = Difficulty(difficultyLevel: .custom(3, 0.7, 9, Int.random(in: 1...2)))
    var antiVaxxerNodeIDs: Set<String> = []
    
    var difficultyInUse: Difficulty!
    var isShowingCustomView = false
    
    var resultsView = ResultsView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCoachingOverlay()
        setupAR(n: numberOfNodes, diff: self.easyDifficulty)
        
        infectionHandlerLabel.text = "\(difficultyInUse.numberOfVaccines)"
        difficultyButton.menu = UIMenu(title: "", image: nil, identifier: nil, options: .displayInline, children: [
            UIAction(title: "Easy", handler: { (_) in
                self.setupAR(n: 30, diff: self.easyDifficulty)
            }),
            UIAction(title: "Medium", handler: { (_) in
                self.setupAR(n: 40, diff: self.mediumDifficulty)
            }),
            UIAction(title: "Hard", handler: { (_) in
                self.setupAR(n: 50, diff: self.hardDifficulty)
//                self.difficultyInUse = self.hardDifficulty
            }),
            UIAction(title: "Custom", handler: { (_) in
                self.isShowingCustomView = true
                let v = UIHostingController(rootView: CustomDifficultyView(numberOfVaccines: 3, numberOfStartingInfected: 1, numberOfAntiVax: 0, numberOfNodes: self.numberOfNodes, outputAction: {
                    self.setupAR(n: $0, diff: $1)
                }))
                v.rootView.outputAction = {
                    self.setupAR(n: $0, diff: $1)
                    v.view.removeFromSuperview()
                }
                v.view.alpha = 0
                let anim = UIViewPropertyAnimator(duration: 0.8, dampingRatio: 0.8) {
                    v.view.alpha = 1
                }
                anim.addCompletion { _ in
                    self.isShowingCustomView = true
                    v.view.translatesAutoresizingMaskIntoConstraints = false
                    self.view.addSubview(v.view)
                }
                
                anim.startAnimation()
                v.view.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
                v.view.centerYAnchor.constraint(equalTo: self.view.centerYAnchor).isActive = true
                v.view.trailingAnchor.constraint(greaterThanOrEqualTo: self.view.trailingAnchor, constant: 20).isActive = true
                v.view.leadingAnchor.constraint(greaterThanOrEqualTo: self.view.leadingAnchor, constant: 20).isActive = true
                v.view.backgroundColor = .clear
            })
        ])
        difficultyButton.showsMenuAsPrimaryAction = true
        print(self.view.frame)
        print(self.arView.constraints)
        print(self.arView.frame)
        
    }
    func setupAR(n: Int?, diff: Difficulty) {
        if let num = n {
            self.numberOfNodes = num
        }
        self.difficultyInUse = diff
        self.graph = Graph.init(numberOfNodes: self.numberOfNodes)
        infectionHandler = InfectionHandler(graph: self.graph, difficulty: self.difficultyInUse)
        if let config = arView.session.configuration {
            anchorEntity.children.removeAll()
            arView.session.run(config, options: [.removeExistingAnchors, .resetTracking])
        }
        generateNetwork()
        if difficultyInUse.antiVaxxers > 0 {
            infectionHandler.addAntiVaxxers()
            RKAddAntiVaxxers()
        }
        arView.scene.anchors.append(anchorEntity)
    }
    func midpoint(r1: ModelEntity, r2: ModelEntity) -> SIMD3<Float> {
        let diff = r2.position + r1.position
        return diff / 2
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
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                            e.removeFromParent()
                        }
                    }
                    if let reversedE = anchorEntity.findEntity(named:  edge.reverseRKFormat()) {
                        var newTransform = reversedE.transform
                        newTransform.scale = SIMD3<Float>(x: 0, y: 0, z: 0)
                        reversedE.move(to: newTransform, relativeTo: reversedE.parent, duration: 1.5)
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
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
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                    e.removeFromParent()
                }
            }
            if let reversedE = anchorEntity.findEntity(named:  edge.reverseRKFormat()) {
                var newTransform = reversedE.transform
                newTransform.scale = SIMD3<Float>(x: 0, y: 0, z: 0)
                reversedE.move(to: newTransform, relativeTo: reversedE.parent, duration: 1.5)
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                    reversedE.removeFromParent()
                }
            }
        }
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        var started = false
        if isShowingCustomView {
            let anim = UIViewPropertyAnimator(duration: 0.8, dampingRatio: 0.8) {
                self.view.subviews.last?.alpha = 0
            }
            anim.addCompletion { _ in
                self.view.subviews.last?.removeFromSuperview()
                self.isShowingCustomView = false
            }
            
            anim.startAnimation()
            return
        }
        guard let touchPoint = touches.first?.location(in: arView) else { return }
        guard let test = arView.entity(at: touchPoint) as? ModelEntity else {
//            print("Nothing on this touch")
            return
        }
        if !hasEdges(test) {
            //TODO: Implement Error Alert
            return
        }
        if let node = graph.nodes.first(where: { $0.toRKFormat() == test.name }) {
            //TODO: Implement error alert
            if node.SIRState == .Infected { return }
        }
        if infectionHandler.vaccinesAdministered < difficultyInUse.numberOfVaccines {
            if let node = graph.nodes.first(where: { $0.toRKFormat() == test.name }) {
                infectionHandler.vaccinateNode(node: node)
            }
            infectionHandlerLabel.text = "\(difficultyInUse.numberOfVaccines - infectionHandler.vaccinesAdministered)"
            if infectionHandler.vaccinesAdministered == difficultyInUse.numberOfVaccines {
                infectionHandler.startInfection()
                RKInfectNodes()
                started = true
                infectionTitleLabel.text = "Quarantined"
                infectionHandlerLabel.text = "\(0)"
            }
        } else {
            if let node = graph.nodes.first(where: { $0.toRKFormat() == test.name }) {
                print("EDGES: \(graph.edges)")
                print("infectable Edges pre removal: \(infectionHandler.infectableEdges())")
                infectionHandler.quarantineNode(node: node)
                print("infectable Edges post removal: \(infectionHandler.infectableEdges())")
                infectionHandlerLabel.text = "\(infectionHandler.graph.nodes.filter({$0.metaData == .quarantined}).count)"
//                print("\(infectionHandler.graph.nodes.filter({$0.metaData == .quarantined}).count)")
            }
        }
        removeEdgesForNode(test)
        if !started {
            infectionHandler.nextStep()
            RKInfectNodes()            
        }
        if infectionHandler.graph.nodes.filter({$0.SIRState == .Infected}).count > 0 {
            let edgesLeft = infectionHandler.graph.nodes.filter({$0.SIRState == .Infected}).reduce(into: 0, { res, node in
                res += node.edges.filter({$0.isActive}).count
            })
            if edgesLeft == 0 {
                let alert = UIAlertController(title: "OUTBREAK FINISHED", message: "WOO BACK BABY", preferredStyle: .alert)
                alert.addAction(UIAlertAction.init(title: "OK", style: .default, handler: { _ in
                    alert.dismiss(animated: true, completion: nil)
                }))
                self.present(alert, animated: true, completion: nil)
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
    @IBAction func resetButtonPressed(_ sender: Any) {
        setupAR(n: nil, diff: self.difficultyInUse)
    }
    @IBAction func difficultyButtonPressed(sender: UIButton) {
        sender.menu = UIMenu(title: "", image: nil, identifier: nil, options: .displayInline, children: [UIAction(title: "Easy", state: .on, handler: { (_) in
            print("TAPPED")
        })])
        sender.showsMenuAsPrimaryAction = true
    }
}
extension GameViewController: ARCoachingOverlayViewDelegate {
    func setupCoachingOverlay() {
        // Set up coaching view
        coachingOverlay.session = arView.session
        coachingOverlay.delegate = self
        
        coachingOverlay.translatesAutoresizingMaskIntoConstraints = false
        arView.addSubview(coachingOverlay)
        
        NSLayoutConstraint.activate([
            coachingOverlay.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            coachingOverlay.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            coachingOverlay.widthAnchor.constraint(equalTo: view.widthAnchor),
            coachingOverlay.heightAnchor.constraint(equalTo: view.heightAnchor)
            ])
    }
}
