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

    
    func configureCell(p:Post)
    {
        /*
        titleLbl.sizeToFit()
        infoLbl.sizeToFit()
        self.sizeToFit()
        */
        
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
        //var htmlContent = NSAttributedString(string: p.content, attributes:)
        infoLbl.text = p.username + " - " + p.relativeTime
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
