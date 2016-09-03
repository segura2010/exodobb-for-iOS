//
//  PostCell.swift
//  exodoapp
//
//  Created by Alberto on 20/9/15.
//  Copyright © 2015 Alberto. All rights reserved.
//

import UIKit

class PostCell: UITableViewCell {
    
    @IBOutlet weak var infoLbl: UILabel!
    @IBOutlet weak var postContentView: UITextView!
    @IBOutlet weak var votes: UILabel!
    @IBOutlet weak var reputation: UILabel!

    
    func configureCell(_ p:Post)
    {
        /*
        titleLbl.sizeToFit()
        infoLbl.sizeToFit()
        self.sizeToFit()
        */
        
        /*
        let encodedData = p.content.dataUsingEncoding(NSUTF8StringEncoding)!
        let attributedOptions : [String: AnyObject] = [
            NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType,
            NSCharacterEncodingDocumentAttribute: NSUTF8StringEncoding
        ]
        do{
            let attributedString = try NSAttributedString(data: encodedData, options: attributedOptions, documentAttributes: nil)
            postContentView.text = attributedString.string
        } catch {
            postContentView.text = p.content
        }
        */

        postContentView.text = p.content

        //var htmlContent = NSAttributedString(string: p.content, attributes:)
        infoLbl.text = p.username + " - " + p.relativeTime
        
        votes.text = "\(p.votes)"
        reputation.text = "\(p.reputation)"
        
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
