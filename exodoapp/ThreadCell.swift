//
//  ThreadCell.swift
//  exodoapp
//
//  Created by Alberto on 19/9/15.
//  Copyright © 2015 Alberto. All rights reserved.
//

import UIKit

class ThreadCell: UITableViewCell {
    
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var infoLbl: UILabel!
    
    
    func configureCell(topic:Thread)
    {
        /*
        titleLbl.sizeToFit()
        infoLbl.sizeToFit()
        self.sizeToFit()
        */
        
        titleLbl.text = topic.title
        infoLbl.text = topic.lastPostUser + " - " + topic.lastPostDate
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
