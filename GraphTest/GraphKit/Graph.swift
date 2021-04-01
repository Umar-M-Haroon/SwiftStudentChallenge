//
//  Graph.swift
//  GraphKit
//
//  Created by Umar Haroon on 3/31/21.
//

import Foundation
public struct Node {
    public var id: Int
    public var edges: [Edge]
    public var metaData: NodeMetadata
    public var SIRState: SIRNodeStates
    public func degree() -> Int {
        return edges.count
    }
}
public struct Edge {
    public var u: Node
    public var v: Node
    public func reverse() -> Edge {
        return Edge(u: v, v: u)
    }
}

public enum SIRNodeStates {
    case susceptible
    case Infected
    case recovered
}
public enum NodeMetadata {
    case quarantined
    case antiVax
    case vaccinated
    case none
}
public struct Graph {
    internal init(nodes: [Node]) {
        self.nodes = nodes
    }
    
    public var nodes: [Node]
    public init(numberOfNodes: Int) {
        var totalNodes: [Node] = []
        var dict: [Int: Node] = [:]
        for i in 0 ..< numberOfNodes {
            let n = Node(id: i, edges: [], metaData: .none, SIRState: .susceptible)
            totalNodes.append(n)
            dict[i] = n
        }
        self.nodes = totalNodes
        for node in totalNodes {
            createEdge(numberOfNodes: numberOfNodes, node: node)
            if Double.random(in: 0..<1) > 0.2{
                createEdge(numberOfNodes: numberOfNodes, node: node)
            }
        }
    }
    private mutating func createEdge(numberOfNodes: Int, node: Node) {
        var randomNumber = Int.random(in: 0 ..< numberOfNodes)
        while randomNumber == node.id {
            randomNumber = Int.random(in: 0 ..< numberOfNodes)
        }
        guard let v = self.nodes.first(where: { $0.id == randomNumber }) else {
            fatalError("invalid v")
        }
        let edge = Edge(u: node, v: v)
        addUndirectedEdge(edge: edge, node: node)
    }
    mutating func addUndirectedEdge(edge: Edge, node: Node) {
        var mutableNodes = self.nodes
        guard let uIndex = self.nodes.firstIndex(where: {$0.id == node.id}),
              let vIndex = self.nodes.firstIndex(where: {$0.id == edge.v.id}) else { return }
        mutableNodes[uIndex].edges.append(edge)
        mutableNodes[vIndex].edges.append(edge.reverse())
        self.nodes = mutableNodes
    }
}
