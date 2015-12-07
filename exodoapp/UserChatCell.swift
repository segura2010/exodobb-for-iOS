//
//  UserChatCell.swift
//  exodoapp
//
//  Created by Alberto on 23/9/15.
//  Copyright © 2015 Alberto. All rights reserved.
//

import UIKit

class UserChatCell: UITableViewCell {
    
    @IBOutlet weak var username: UILabel!
    @IBOutlet weak var picture: UIImageView!
    
    
    func configureCell(u:User)
    {
        username.text = u.username
        
        if let p = u.picture{
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)){
                if p.lowercaseString.rangeOfString("http") != nil
                {
                    if let picData = NSData(contentsOfURL: NSURL(string: p)!){
                        dispatch_async(dispatch_get_main_queue()){
                            self.picture.image = UIImage(data: picData)
                        }
                    }
                }
                else
                {
                    let pp = "http://exo.do\(p)".stringByReplacingOccurrencesOfString(" ", withString: "%20", options: NSStringCompareOptions.LiteralSearch, range: nil)
                    print(pp)
                    if let picData = NSData(contentsOfURL: NSURL(string: pp)!){
                        dispatch_async(dispatch_get_main_queue()){
                            self.picture.image = UIImage(data: picData)
                        }
                    }
                }
            }
        }
        
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
