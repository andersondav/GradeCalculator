//
//  Assignment.swift
//  GradeCalculator
//
//  Created by Anderson David on 1/13/19.
//  Copyright © 2019 Anderson David. All rights reserved.
//

import Foundation

struct Assignment {
    
    let name:String
    let type:String
    let score:Double
    let max:Double
    
    init(name:String, type:String, score:Double, max:Double) {
        self.name = name
        self.type = type
        self.score = score
        self.max = max
    }
    
    init() {
        self.name = "Example Assignment"
        self.type = "All"
        self.score = 94.0
        self.max = 100.0
    }
}
