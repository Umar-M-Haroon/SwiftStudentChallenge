//
//  HeadingPitchBank.swift
//  NodeTest
//
//  Created by Umar Haroon on 4/2/21.
//

import Foundation
import RealityKit

struct HeadingPitchBank {
    let heading: Float
    let pitch: Float
    let bank: Float
    
    static func from(vector: SIMD3<Float>) -> HeadingPitchBank {
        let heading = atan2f(vector.x, vector.z)
        let pitch = atan2f(sqrt(vector.x*vector.x + vector.z * vector.z), vector.y) - Float.pi / 2.0
        return HeadingPitchBank(heading: heading, pitch: pitch, bank: 0)
    }
}
class HeadingPitchBankWrapper: Entity {
    private var headingEntity: Entity
    private var pitchEntity: Entity
    private var bankEntity: Entity
    private var _wrappedEntity: Entity
    
    init(wrappedEntity: Entity) {
        headingEntity = Entity()
        pitchEntity = Entity()
        bankEntity = Entity()
        _wrappedEntity = wrappedEntity
        super.init()
        addChild(headingEntity)
        headingEntity.addChild(pitchEntity)
        pitchEntity.addChild(bankEntity)
        bankEntity.addChild(wrappedEntity)
    }
    
    required init() {
        fatalError("init() has not been implemented")
    }
    
//    var heading: Float {
//        get {
//            return headingEntity.
//        }
//    }
}
