//
//  InfectionHandler.swift
//  GraphKit
//
//  Created by Umar Haroon on 3/31/21.
//

import Foundation
public struct InfectionHandler {
    internal init(graph: Graph, iterationsDict: [Int : Graph], vaccinesAdministered: Int, defaultInfectionRate: Double = 0.7, difficulty: Difficulty) {
        self.graph = graph
        self.iterationsDict = iterationsDict
        self.vaccinesAdministered = vaccinesAdministered
        self.defaultInfectionRate = defaultInfectionRate
        self.difficulty = difficulty
    }
    public init(graph: Graph, difficulty: Difficulty) {
        self.graph = graph
        self.iterationsDict = [:]
        self.vaccinesAdministered = 0
        self.defaultInfectionRate = difficulty.infectionRate
        self.difficulty = difficulty
    }
    
    var timeStamp = 0
    var graph: Graph
    var iterationsDict: [Int: Graph]
    var vaccinesAdministered: Int
    
    var defaultInfectionRate = 0.7
    var difficulty: Difficulty
    public mutating func startInfection() {
        for _ in 0 ..< difficulty.numberOfStartingInfected {
            var randomIndex = Int.random(in: 0 ..< graph.nodes.count)
            while graph.nodes[randomIndex].SIRState == .Infected {
                randomIndex = Int.random(in: 0 ..< graph.nodes.count)
            }
            graph.nodes[randomIndex].SIRState = SIRNodeStates.Infected
        }
        iterationsDict[timeStamp] = graph
        timeStamp += 1
    }
    public mutating func nextStep() {
        let newGraph = infectNodes()
        graph = newGraph
        iterationsDict[timeStamp] = newGraph
        timeStamp += 1
    }
    public func numberOfInfectedNodes() -> Int {
//        for (_, value) in iterationsDict {
//            print(value.nodes.filter({$0.SIRState == .Infected}).count)
//        }
        guard let test = iterationsDict[iterationsDict.count - 1] else { return 0 }
        return test.nodes.filter({$0.SIRState == .Infected}).count
    
    }
    func infectNodes() -> Graph {
        var newGraph = graph
        for node in graph.nodes where node.SIRState == .Infected {
            for edge in node.edges {
                if Double.random(in: 0.0 ..< 1) <= difficulty.infectionRate {
                    guard let index = newGraph.nodes.firstIndex(where: { $0.id == edge.v.id }) else {
                        print("INVALID INDEX")
                        return graph
                    }
                    print("infecting \(index)")
                    newGraph.nodes[index].SIRState = .Infected
                }
            }
        }
        return newGraph
    }
    public mutating func vaccinateNode(node: Node) {
        var newGraph = graph
        //removes vaccinated nodes
//        newGraph.nodes.removeAll(where: {$0.id == node.id})
//        for (nodeIndex, node) in newGraph.nodes.enumerated() {
//            for (index, edge) in node.edges.enumerated() {
//                if edge.u.id == node.id || edge.v.id == node.id {
//                    var node2 = node
//                    node2.edges.remove(at: index)
//                    newGraph.nodes[nodeIndex] = node2
//                }
//            }
//        }
        //sets node to vaccinated
        guard let index = newGraph.nodes.firstIndex(where: {$0.id == node.id}) else { return }
        var n2 = newGraph.nodes[index]
        n2.metaData = .vaccinated
        newGraph.nodes[index] = node
        graph = newGraph
        iterationsDict[timeStamp] = newGraph
    }
    public mutating func quarantineNode(node: Node) {
        var newGraph = graph
        //removes vaccinated nodes
//        newGraph.nodes.removeAll(where: {$0.id == node.id})
//        for (nodeIndex, node) in newGraph.nodes.enumerated() {
//            for (index, edge) in node.edges.enumerated() {
//                if edge.u.id == node.id || edge.v.id == node.id {
//                    var node2 = node
//                    node2.edges.remove(at: index)
//                    newGraph.nodes[nodeIndex] = node2
//                }
//            }
//        }
        //sets node to vaccinated
        guard let index = newGraph.nodes.firstIndex(where: {$0.id == node.id}) else { return }
        var n2 = newGraph.nodes[index]
        n2.metaData = .vaccinated
        newGraph.nodes[index] = node
        graph = newGraph
        iterationsDict[timeStamp] = newGraph
    }
    public mutating func antiVaxNode(node: Node) {
        var newGraph = graph

        
        guard let index = newGraph.nodes.firstIndex(where: {$0.id == node.id}) else { return }
        var n2 = newGraph.nodes[index]
        n2.metaData = .quarantined
        newGraph.nodes[index] = node
        graph = newGraph
        iterationsDict[timeStamp] = newGraph
    }
    public mutating func markNodesAntiVax(numberOfAntiVaxxers: Int) {
        var newGraph = graph

        for node in newGraph.nodes where node.SIRState != .Infected {
            guard let index = newGraph.nodes.firstIndex(where: {$0.id == node.id}) else { return }
            var n2 = newGraph.nodes[index]
            n2.metaData = .antiVax
            newGraph.nodes[index] = n2
        }
        
        graph = newGraph
        iterationsDict[timeStamp] = newGraph
    }
}
public struct Difficulty {
//    public var numberOfNodes: Int
    public var numberOfStartingInfected: Int
    public var infectionRate: Double
    public var numberOfVaccines: Int
    public var difficultyLevel: DifficultyLevel
    public init(difficultyLevel: DifficultyLevel) {
        switch difficultyLevel {
        case .easy:
            self.numberOfStartingInfected = 1
            infectionRate = 0.7
            numberOfVaccines = 5
            self.difficultyLevel = difficultyLevel
        case .medium:
            self.numberOfStartingInfected = 2
            infectionRate = 0.7
            numberOfVaccines = 7
            self.difficultyLevel = difficultyLevel
        case .hard:
            self.numberOfStartingInfected = 3
            infectionRate = 0.7
            numberOfVaccines = 15
            self.difficultyLevel = difficultyLevel
            
        case .custom(let num, let iR, let vacc):
            self.numberOfStartingInfected = num
            infectionRate = iR
            numberOfVaccines = vacc
            self.difficultyLevel = difficultyLevel
        }
    }
}
public enum DifficultyLevel {
    case easy
    case medium
    case hard
    case custom(Int, Double, Int)
}
