//
//  UserTableViewCell.swift
//  WantFun
//
//  Created by Pengzhi Zhou on 12/9/15.
//  Copyright © 2015 Pengzhi Zhou. All rights reserved.
//

import UIKit

class UserTableViewCell: UITableViewCell {

    //MARK: Properties
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var thumbUserImageView: UIImageView!
    
    @IBOutlet weak var followingUserName: UILabel!
    
    @IBOutlet weak var followingUserThumbImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
