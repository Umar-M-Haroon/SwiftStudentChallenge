//
//  Difficulty.swift
//  InfectionGraphKit
//
//  Created by Umar Haroon on 3/31/21.
//

import Foundation
public struct Difficulty: Equatable {
//    public var numberOfNodes: Int
    public var numberOfStartingInfected: Int
    public var infectionRate: Double
    public var numberOfVaccines: Int
    public var difficultyLevel: DifficultyLevel
    public var antiVaxxers = 0
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
            antiVaxxers = Int.random(in: 0..<5)
            self.difficultyLevel = difficultyLevel
            
        case .custom(let num, let iR, let vacc, let anti):
            self.numberOfStartingInfected = num
            infectionRate = iR
            numberOfVaccines = vacc
            antiVaxxers = anti
            self.difficultyLevel = difficultyLevel
        }
    }
}
public enum DifficultyLevel: Equatable {
    case easy
    case medium
    case hard
    case custom(Int, Double, Int, Int)
}
