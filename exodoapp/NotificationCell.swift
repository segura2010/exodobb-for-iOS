//
//  NotificationCell.swift
//  exodoapp
//
//  Created by Alberto on 27/9/16.
//  Copyright © 2016 Alberto. All rights reserved.
//

import UIKit

class NotificationCell: UITableViewCell {
    
    @IBOutlet weak var bodyShort: UILabel!
    @IBOutlet weak var bodyLong: UILabel!
    
    func configureCell(_ notif:Notification)
    {
        
        bodyShort.text = notif.bodyShort
        bodyLong.text = notif.bodyLong
        
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    
    
}
