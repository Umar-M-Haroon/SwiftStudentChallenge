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
class ViewController: UIViewController {
    
    @IBOutlet weak var arView: ARView!
    @IBOutlet weak var infectionTitleLabel: UILabel!
    
    @IBOutlet weak var infectionHandlerLabel: UILabel!
    
    @IBOutlet weak var difficultyButton: UIButton!
    
    @IBOutlet weak var isLoadingIndicator: UIActivityIndicatorView!
    let coachingOverlay = ARCoachingOverlayView()
    var networkGenerated: Bool = false
    var defaultSphereMaterial = SimpleMaterial(color: .darkGray, isMetallic: false)
    var metalMaterial = SimpleMaterial(color: .gray, isMetallic: true)
    var sphereRadius: Float = 0.0127 // half an inch or 1.27 cm
    var sphereObj = ModelEntity(mesh: .generateSphere(radius: 0.0127), materials: [SimpleMaterial(color: .darkGray, isMetallic: true)])
    var ids: [String] = []
    var anchorEntity = AnchorEntity.init(plane: AnchoringComponent.Target.Alignment.horizontal, classification: AnchoringComponent.Target.Classification.any, minimumBounds: SIMD2<Float>(0.0, 0.0))
    var numberOfNodes = 30
    var infectionHandler: InfectionHandler!
    var graph: Graph!
    
    
    var easyDifficulty = Difficulty(difficultyLevel: .custom(1, 0.7, 2, 0))
    var mediumDifficulty = Difficulty(difficultyLevel: .custom(2, 0.7, 7, 0))
    var hardDifficulty = Difficulty(difficultyLevel: .custom(3, 0.7, 9, Int.random(in: 1...2)))
    var herdDifficulty = Difficulty(difficultyLevel: .custom(3, 0.7, 20, Int.random(in: 1...2)))
    var antiVaxxerNodeIDs: Set<String> = []
    
    var difficultyInUse: Difficulty!
    var isShowingCustomView = false
    
    var resultModel: ResultModel!
    var resultsView: ResultsView!
    
    var easyAction: UIAction!
    var mediumAction: UIAction!
    var hardAction: UIAction!
    var herdAction: UIAction!
    var customAction: UIAction!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCoachingOverlay()
        arView.cameraMode = .ar
        setupLabel()
        easyAction = UIAction(title: "Easy", handler: { (act) in
            self.setupAR(n: 30, diff: self.easyDifficulty)
        })
        mediumAction = UIAction(title: "Medium", state: difficultyInUse == mediumDifficulty ? .on : .off, handler: { (act) in
            self.setupAR(n: 40, diff: self.mediumDifficulty)
        })
        hardAction = UIAction(title: "Hard",  state: difficultyInUse == hardDifficulty ? .on : .off, handler: { (act) in
            self.setupAR(n: 50, diff: self.hardDifficulty)
        })
        herdAction = UIAction(title: "Herd Immunity",  state: difficultyInUse == herdDifficulty ? .on : .off, handler: { (act) in
            self.setupAR(n: 40, diff: self.herdDifficulty)
        })
        customAction = UIAction(title: "Custom", handler: { (act) in
            if !self.isShowingCustomView {
            self.isShowingCustomView = true
                let v = UIHostingController(rootView: CustomDifficultyView(numberOfVaccines: 3, numberOfStartingInfected: 1, numberOfAntiVax: 0, numberOfNodes: self.numberOfNodes, outputAction: { n, dif in
                    
                    self.setupAR(n: n, diff: dif)
                }))
                v.rootView.outputAction = {
                    self.setupAR(n: $0, diff: $1)
                    v.view.removeFromSuperview()
                    self.resultModel = ResultModel(v: $1.numberOfVaccines, c: false, q: 0, isQ: false, t: self.numberOfNodes, i: 0)
                    self.resultsView = ResultsView(model: self.resultModel)
                    let vc = UIHostingController(rootView: self.resultsView)
                    self.view.addSubview(vc.view)
                    vc.view.translatesAutoresizingMaskIntoConstraints = false
                    vc.view.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 0).isActive = true
                    vc.view.centerXAnchor.constraint(equalTo: self.view.centerXAnchor, constant: 0).isActive = true
                    vc.view.trailingAnchor.constraint(greaterThanOrEqualTo: self.view.trailingAnchor, constant: 20).isActive = true
                    vc.view.leadingAnchor.constraint(greaterThanOrEqualTo: self.view.leadingAnchor, constant: 20).isActive = true
                    vc.view.backgroundColor = .clear
                }
                v.view.alpha = 0
                let anim = UIViewPropertyAnimator(duration: 0.8, dampingRatio: 0.8) {
                    v.view.alpha = 1
                }
                anim.addCompletion { _ in
                    self.isShowingCustomView = true
                    v.view.translatesAutoresizingMaskIntoConstraints = false
                    self.view.addSubview(v.view)
                    v.view.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
                    v.view.centerYAnchor.constraint(equalTo: self.view.centerYAnchor).isActive = true
                    v.view.trailingAnchor.constraint(greaterThanOrEqualTo: self.view.trailingAnchor, constant: 20).isActive = true
                    v.view.leadingAnchor.constraint(greaterThanOrEqualTo: self.view.leadingAnchor, constant: 20).isActive = true
                    v.view.backgroundColor = .clear
                }
                
                anim.startAnimation()
            }
        })
        difficultyButton.menu = UIMenu(title: "", image: nil, identifier: nil, options: .displayInline, children: [
            easyAction, mediumAction, hardAction, herdAction, customAction
        ])
        difficultyButton.showsMenuAsPrimaryAction = true
        setupAR(n: numberOfNodes, diff: self.easyDifficulty)
//        self.isLoadingIndicator.stopAnimating()
    }
    func setupLabel() {
        resultModel = ResultModel(v: 0, c: false, q: 0, isQ: false, t: numberOfNodes, i: 0)
        resultsView = ResultsView(model: resultModel)
        let vc = UIHostingController(rootView: resultsView)
        self.view.addSubview(vc.view)
        vc.view.translatesAutoresizingMaskIntoConstraints = false
        vc.view.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 0).isActive = true
        vc.view.centerXAnchor.constraint(equalTo: self.view.centerXAnchor, constant: 0).isActive = true
//        vc.view.trailingAnchor.constraint(greaterThanOrEqualTo: self.view.trailingAnchor, constant: 20).isActive = true
//        vc.view.leadingAnchor.constraint(greaterThanOrEqualTo: self.view.leadingAnchor, constant: 20).isActive = true
        vc.view.backgroundColor = .clear
    }
    func setupAR(n: Int?, diff: Difficulty) {
        if let num = n {
            self.numberOfNodes = num
        }
    
            
        self.difficultyInUse = diff
        self.graph = Graph.init(numberOfNodes: self.numberOfNodes)
        self.infectionHandler = InfectionHandler(graph: self.graph, difficulty: self.difficultyInUse)
        if let config = arView.session.configuration {
            self.anchorEntity.children.removeAll()
            self.anchorEntity = AnchorEntity()
            self.arView.session.run(config, options: [.resetTracking, .removeExistingAnchors])
        
        }
        self.resultModel.vaccines = self.difficultyInUse.numberOfVaccines
        self.resultModel.isQuarantined = false
        self.resultModel.quarantined = 0
        self.resultModel.isComplete = false
        self.resultModel.total = self.numberOfNodes
        self.resultModel.infected = 0
        self.generateNetwork()
        if self.difficultyInUse.antiVaxxers > 0 {
            self.infectionHandler.addAntiVaxxers()
            self.RKAddAntiVaxxers()
        }
        self.infectionHandlerLabel.text = "\(diff.numberOfVaccines)"
        
//        arView.scene.rootNode.addChildNode(self.anchorEntity)
//        if self.arView.scene.anchors.isEmpty {
            self.arView.scene.anchors.append(self.anchorEntity)
//        }
    }
    func midpoint(r1: ModelEntity, r2: ModelEntity) -> SIMD3<Float> {
        let diff = r2.position + r1.position
        return diff / 2
    }
    func generateNetwork() {
        addNodes(numberOfNodes: self.numberOfNodes)
        addEdges(graph: self.graph)
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        var started = false
        var done = infectionHandler.checkIfDone()
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
        if done { return }
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
                resultModel.vaccines -= 1
            }
            test.model?.materials = [SimpleMaterial(color: .blue, isMetallic: false)]
//            resultModel.vaccines = self.difficultyInUse.numberOfVaccines - infectionHandler.graph.nodes.filter({$0.metaData == .vaccinated}).count
//            print("VACCINES LEFT: \(self.difficultyInUse.numberOfVaccines - infectionHandler.graph.nodes.filter({$0.metaData == .vaccinated}).count)")
            resultModel.isQuarantined = false
            resultModel.quarantined = 0
            resultModel.isComplete = false
            resultModel.infected = infectionHandler.graph.nodes.filter({$0.SIRState == .Infected}).count
            resultModel.total = self.numberOfNodes
            infectionHandlerLabel.text = "\(difficultyInUse.numberOfVaccines - infectionHandler.vaccinesAdministered)"
            if infectionHandler.vaccinesAdministered == difficultyInUse.numberOfVaccines {
                infectionHandler.startInfection()
                RKInfectNodes()
                started = true
                infectionTitleLabel.text = "Quarantined"
                infectionHandlerLabel.text = "\(0)"
//                resultModel.vaccines = self.difficultyInUse.numberOfVaccines - infectionHandler.graph.nodes.filter({$0.metaData == .vaccinated}).count
                resultModel.isQuarantined = true
                resultModel.quarantined = 0
                resultModel.infected = infectionHandler.graph.nodes.filter({$0.SIRState == .Infected}).count
                resultModel.total = self.numberOfNodes
                resultModel.isComplete = false
            }
        } else {
            test.model?.materials = [SimpleMaterial(color: .white, isMetallic: false)]
            if let node = graph.nodes.first(where: { $0.toRKFormat() == test.name }) {
                infectionHandler.quarantineNode(node: node)
                infectionHandlerLabel.text = "\(infectionHandler.graph.nodes.filter({$0.metaData == .quarantined}).count)"
                done = infectionHandler.checkIfDone()
//                resultModel.vaccines = self.difficultyInUse.numberOfVaccines - infectionHandler.graph.nodes.filter({$0.metaData == .vaccinated}).count
                resultModel.isQuarantined = true
                resultModel.quarantined = infectionHandler.graph.nodes.filter({$0.metaData == .quarantined}).count
                resultModel.infected = infectionHandler.graph.nodes.filter({$0.SIRState == .Infected}).count
                resultModel.total = self.numberOfNodes
                resultModel.isComplete = done
            }
        }
        removeEdgesForNode(test)
        if !started {
            infectionHandler.nextStep()
            RKInfectNodes()
        }
        done = infectionHandler.checkIfDone()
//        resultModel.vaccines = self.difficultyInUse.numberOfVaccines
        resultModel.isQuarantined = true
        resultModel.quarantined = infectionHandler.graph.nodes.filter({$0.metaData == .quarantined}).count
        resultModel.infected = infectionHandler.graph.nodes.filter({$0.SIRState == .Infected}).count
        resultModel.total = self.numberOfNodes
        resultModel.isComplete = done
        
    }
    @IBAction func resetButtonPressed(_ sender: Any) {
//        self.isLoadingIndicator.startAnimating()
        DispatchQueue.main.async {
            self.setupAR(n: nil, diff: self.difficultyInUse)
        }
        resultModel.isComplete = false
        self.isLoadingIndicator.stopAnimating()
    }
    @IBAction func difficultyButtonPressed(sender: UIButton) {
        sender.menu = UIMenu(title: "", image: nil, identifier: nil, options: .displayInline, children: [UIAction(title: "Easy", state: .on, handler: { (_) in
            print("TAPPED")
        })])
        sender.showsMenuAsPrimaryAction = true
    }
}
extension ViewController: ARCoachingOverlayViewDelegate {
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

extension InfectionHandler {
    func checkIfDone() -> Bool{
        if graph.nodes.filter({$0.SIRState == .Infected}).count == 0 { return false }
        let unavailableNodes = graph.nodes.filter({$0.metaData == .vaccinated || $0.metaData == .quarantined})
        var newGraph = graph
        if graph.nodes.filter({$0.SIRState == .Infected}).flatMap({$0.edges}).isEmpty { return true }
//        if infectableEdges.isEmpty {
//            return true
//        }
        for node in graph.nodes where node.SIRState == .Infected {
            for edge in node.edges where edge.v.metaData != .quarantined && edge.v.metaData != .vaccinated && edge.isActive {
                if !unavailableNodes.contains(edge.v) || !unavailableNodes.contains(edge.u) {
                    guard let index = newGraph.nodes.firstIndex(where: { $0.id == edge.v.id }) else {
                        print("INVALID INDEX")
                        return true
                    }
                    if !unavailableNodes.contains(newGraph.nodes[index]) {
                        if newGraph.nodes[index].SIRState != .Infected {
                            newGraph.nodes[index].SIRState = .Infected
                        }
                    }
                }
            }
        }
        return newGraph.nodes.filter({$0.SIRState == .Infected}).count == graph.nodes.filter({$0.SIRState == .Infected}).count
    }
}
