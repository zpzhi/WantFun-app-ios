//
//  EventTableViewCell.swift
//  WantFun
//
//  Created by Pengzhi Zhou on 11/17/15.
//  Copyright © 2015 Pengzhi Zhou. All rights reserved.
//

import UIKit

class EventTableViewCell: UITableViewCell {
    
    // Mark: Properties
    
    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
