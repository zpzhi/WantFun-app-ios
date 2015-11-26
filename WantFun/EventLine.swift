//
//  EventLine.swift
//  WantFun
//
//  Created by Pengzhi Zhou on 11/25/15.
//  Copyright © 2015 Pengzhi Zhou. All rights reserved.
//

import UIKit

class EventLine {
    // Mark: Properties
    var title: String
    var eventsData:Array< Event > = Array < Event >()
    
    // Mark: Initialization
    init?(title: String, photoName: String){
        self.title = title
        
        // Initialization should fail if there is no id or if the title is negative.
        if title.isEmpty {
            return nil
        }
    }
    
}