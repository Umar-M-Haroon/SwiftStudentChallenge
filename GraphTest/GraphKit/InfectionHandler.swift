//
//  InfectionHandler.swift
//  GraphKit
//
//  Created by Umar Haroon on 3/31/21.
//

import Foundation
struct InfectionHandler {
    internal init(graph: Graph, iterationsDict: [Int : Graph]) {
        self.graph = graph
        self.iterationsDict = iterationsDict
    }
    
    var graph: Graph
    var iterationsDict: [Int: Graph]
    
}
