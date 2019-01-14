//
//  Course.swift
//  GradeCalculator
//
//  Created by Anderson David on 1/13/19.
//  Copyright © 2019 Anderson David. All rights reserved.
//

import Foundation

struct Course {
    
    let name:String
    let weights:[String:Double]
    let assignments:[Assignment]
    
    init(name:String, weights:[String:Double], assignments:[Assignment]) {
        self.name = name
        self.weights = weights
        self.assignments = assignments
    }
    
    init() {
        self.name = "Example course"
        self.weights = ["All": 1.0]
        self.assignments = [Assignment()]
    }
    
    
}
