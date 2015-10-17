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
    @IBOutlet weak var viewsField: UITextField!
    @IBOutlet weak var repliesField: UITextField!
    
    
    func configureCell(topic:Thread)
    {
        /*
        titleLbl.sizeToFit()
        infoLbl.sizeToFit()
        self.sizeToFit()
        */
        
        titleLbl.text = topic.title
        if (topic.unread != false){
            titleLbl.textColor = UIColor.blueColor()
        }
        else if(topic.locked != false){
            titleLbl.textColor = UIColor.redColor()
        }
        else{
            titleLbl.textColor = UIColor.blackColor()
        }
        infoLbl.text = topic.lastPostUser + " - " + topic.lastPostDate
        
        repliesField.text = "\(topic.postCount)"
        viewsField.text = "\(topic.viewCount)"
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
