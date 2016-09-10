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
    
    @IBOutlet var statusLbl: UILabel!
    
    func configureCell(_ u:Room)
    {
        username.text = u.username
        
        if let p = u.picture{
            DispatchQueue.global(priority: DispatchQueue.GlobalQueuePriority.default).async{
                if p.lowercased().range(of: "http") != nil
                {
                    if let picData = try? Data(contentsOf: URL(string: p)!){
                        DispatchQueue.main.async{
                            self.picture.image = UIImage(data: picData)
                        }
                    }
                }
                else
                {
                    let pp = "http://exo.do\(p)".replacingOccurrences(of: " ", with: "%20", options: NSString.CompareOptions.literal, range: nil)
                    print(pp)
                    if let picData = try? Data(contentsOf: URL(string: pp)!){
                        DispatchQueue.main.async{
                            self.picture.image = UIImage(data: picData)
                        }
                    }
                }
            }
        }
        
        switch u.status {
        case "online":
            statusLbl.textColor = UIColor.green
        case "away":
            statusLbl.textColor = UIColor.yellow
        case "dnd":
            statusLbl.textColor = UIColor.red
        default:
            statusLbl.textColor = UIColor.gray
        }
        
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
