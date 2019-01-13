//
//  homeScreenCourseCell.swift
//  GradeCalculator
//
//  Created by Anderson David on 1/12/19.
//  Copyright © 2019 Anderson David. All rights reserved.
//

import UIKit

class HomeScreenCourseCell: UITableViewCell {

    @IBOutlet weak var courseNameLabel: UILabel!
    @IBOutlet weak var percentageLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
