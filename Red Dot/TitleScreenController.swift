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
    
    //Game Modes (Title Screen)
    @IBAction func timeTrialPressed(sender: AnyObject)
    {
        gameMode = "Time Trial"
    }
    
    @IBAction func endurancePressed(sender: AnyObject)
    {
        gameMode = "Endurance"
    }
    
    @IBAction func challengePressed(sender: AnyObject)
    {
        gameMode = "Challenge"
    }
    
    //Game Difficulties (Difficulty Screen)
    @IBAction func easyPressed(sender: AnyObject)
    {
        gameDifficulty = 1
    }
    
    @IBAction func mediumPressed(sender: AnyObject)
    {
        gameDifficulty = 2
    }
    
    @IBAction func hardPressed(sender: AnyObject)
    {
        gameDifficulty = 3
    }
}
