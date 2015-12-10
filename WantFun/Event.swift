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
    var imageName: String?
    var thumbImageName: String?
    var eventType: String
    var eventTime: String
    var location: String
    var city: String
    var state: String
    var eventCreator: String
    var description: String
    var phoneNumber: String
    var duration: String
    
    // Mark: Initialization
    init?(id: String, title: String, eventType: String){
        self.id = id
        self.title = title
        self.imageName = ""
        self.thumbImageName = ""
        self.eventType = eventType
        self.eventTime = ""
        self.location = ""
        self.city = ""
        self.state = ""
        self.eventCreator = ""
        self.description = ""
        self.phoneNumber = ""
        self.duration = ""
        
        // Initialization should fail if there is no id or if the title is negative.
        if id.isEmpty || title.isEmpty {
            return nil
        }
    }
    
}