//
//  UserChatMessageCellTableViewCell.swift
//  exodoapp
//
//  Created by Alberto on 23/9/15.
//  Copyright © 2015 Alberto. All rights reserved.
//

import UIKit

class UserChatMessageCellTableViewCell: UITableViewCell {
    
    @IBOutlet weak var webview: UIWebView!
    
    func configureCell(msg:String)
    {
        var html = "<link rel=\"stylesheet\" type=\"text/css\" href=\"/stylesheet.css\"> \(msg)"
        
        webview.loadHTMLString(html, baseURL:NSURL(string: "http://exo.do/"))
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
