//
//  main.swift
//  GraphTest
//
//  Created by Umar Haroon on 3/31/21.
//

import Foundation
import GraphKit


//let graph = Graph(numberOfNodes: 100)
//print(graph)
//print(graph)
//var degree = 0
//var min = 10000000
//graph.nodes.forEach { node in
////    print(node.degree())
//}
//graph.nodes.forEach { node in
//    if node.degree() > degree {
//        degree = node.degree()
//    }
//    if node.degree() < min {
//        min = node.degree()
//    }
//}
//print(min)
//print(degree)
//var totalMax = 0
//var totalMin = 100000
//for _ in 0..<100 {
//    var localMax = 0
//    var localMin = 10000000
//    let graph = Graph(numberOfNodes: 100)
//    graph.nodes.forEach { node in
//        let degree = node.degree()
//        if degree > localMax {
//            localMax = degree
//        }
//        if degree < localMin {
//            localMin = degree
//        }
//    }
//    if localMin < totalMin {
//        totalMin = localMin
//    }
//    if localMax > totalMax {
//        totalMax = localMax
//    }
//}
//print(totalMin)
//print(totalMax)

let graph = Graph(numberOfNodes: 50)
var infector = InfectionHandler(graph: graph, difficulty: Difficulty(difficultyLevel: .hard))
infector.startInfection()
while infector.numberOfInfectedNodes() < graph.nodes.count {
    infector.nextStep()
    print(infector.numberOfInfectedNodes())
}

