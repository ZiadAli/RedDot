//
//  TitleScreenController.swift
//  Red Dot
//
//  Created by Ziad Ali on 6/20/16.
//  Copyright © 2016 ZiadCorp. All rights reserved.
//

import UIKit

class TitleScreenController: UIViewController
{
    
    @IBOutlet var timeTrialButton: UIButton!
    @IBOutlet var enduranceButton: UIButton!
    @IBOutlet var challengeButton: UIButton!
    @IBOutlet var instructionsButton: UIButton!
    @IBOutlet var optionsButton: UIButton!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        for item in self.view.subviews
        {
            if let button = item as? UIButton
            {
                if button.tag == 5
                {
                    button.layer.cornerRadius = 10
                    button.clipsToBounds = true
                }
            }
        }
    }
    
}
