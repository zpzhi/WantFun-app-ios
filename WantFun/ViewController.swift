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
    @IBOutlet weak var loginLabel: UILabel!
    @IBOutlet weak var newAccountLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let listEvent = UITapGestureRecognizer(target: self, action: Selector("listEventAction"))
        listEventsImage.addGestureRecognizer(listEvent)
        listEventsImage.userInteractionEnabled = true
        
        let underlineAttribute = [NSUnderlineStyleAttributeName: NSUnderlineStyle.StyleSingle.rawValue]
        let underlineLoginString = NSAttributedString(string: "Login", attributes: underlineAttribute)
        let underlineRegisterString = NSAttributedString(string: "New Account", attributes: underlineAttribute)
        
        loginLabel.attributedText = underlineLoginString
        newAccountLabel.attributedText = underlineRegisterString
    }
    
    // Mark: Actions
    
    func listEventAction()
    {
    self.performSegueWithIdentifier("listEvents", sender: self)
    }

    
}

