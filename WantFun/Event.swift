//
//  Event.swift
//  WantFun
//
//  Created by Pengzhi Zhou on 11/17/15.
//  Copyright © 2015 Pengzhi Zhou. All rights reserved.
//

import UIKit

class Event {
    // Mark: Properties
    var id: String
    var title: String
    var photoName: String?
    var eventType: String
    var eventTime: String
    
    // Mark: Initialization
    init?(id: String, title: String, photoName: String, eventType: String){
        self.id = id
        self.title = title
        self.photoName = photoName
        self.eventType = eventType
        self.eventTime = ""
        
        // Initialization should fail if there is no id or if the title is negative.
        if id.isEmpty || title.isEmpty {
            return nil
        }
    }
    
}