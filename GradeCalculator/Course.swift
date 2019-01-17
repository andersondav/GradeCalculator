//
//  Course.swift
//  GradeCalculator
//
//  Created by Anderson David on 1/13/19.
//  Copyright © 2019 Anderson David. All rights reserved.
//

import Foundation

struct Course {
    
    var name:String
    var weights:[String:Double]
    var assignments:[Assignment]
    var credits:Int
    
    init(name:String, weights:[String:Double], assignments:[Assignment], credits:Int) {
        self.name = name
        self.weights = weights
        self.assignments = assignments
        self.credits = credits
    }
    
    init() {
        self.name = "Example course"
        self.weights = ["All": 1.0]
        self.assignments = []
        self.credits = 0
    }
    
    
}
