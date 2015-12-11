//
//  User.swift
//  WantFun
//
//  Created by Pengzhi Zhou on 12/9/15.
//  Copyright © 2015 Pengzhi Zhou. All rights reserved.
//

import UIKit

class User {
    // Mark: Properties
    var id: String
    var name: String
    var thumbnailName: String?
    var photoName: String?
    var phoneNumber: String?
    var realName: String?
    var description: String?
    var profileImage: UIImage?

    
    // Mark: Initialization
    init?(id: String){
        self.id = id
        self.name = ""
        
        // Initialization should fail if there is no id
        if id.isEmpty {
            return nil
        }
    }
    
}