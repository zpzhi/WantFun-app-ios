//
//  ViewController.swift
//  WantFun
//
//  Created by Pengzhi Zhou on 11/16/15.
//  Copyright © 2015 Pengzhi Zhou. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    // Mark: Properties
    @IBOutlet weak var listEventsImage: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tap = UITapGestureRecognizer(target: self, action: Selector("tappedMe"))
        listEventsImage.addGestureRecognizer(tap)
        listEventsImage.userInteractionEnabled = true
    }
    
    func tappedMe()
    {
    self.performSegueWithIdentifier("listEvents", sender: self)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

