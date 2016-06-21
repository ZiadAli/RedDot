//
//  ViewController.swift
//  Red Dot
//
//  Created by Ziad Ali on 1/30/16.
//  Copyright © 2016 ZiadCorp. All rights reserved.
//

import UIKit

var currentCountdownNumber:Int = 3

class ViewController: UIViewController {

    @IBOutlet var background: UIImageView!
    @IBOutlet var restartButton: UIButton!
    @IBOutlet var button: UIButton!
    @IBOutlet var playAgainButton: UIButton!
    @IBOutlet var scoreLabel: UILabel!
    @IBOutlet var scoreLabel2: UILabel!
    @IBOutlet var periodLabel: UILabel!
    @IBOutlet var playButton: UIButton!
    var buttonArray = [UIButton]()
    var completedRounds = 0
    var start = 0.0
    var myTimer:NSTimer!
    var currentTime = 0.00
    let gameView = UIView()
    let newView = UIView()
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        view.removeConstraints(view.constraints)
        newView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(newView)
        
        let widthConstraint = NSLayoutConstraint(item: newView, attribute: NSLayoutAttribute.Width, relatedBy: NSLayoutRelation.Equal, toItem: view, attribute: NSLayoutAttribute.Width, multiplier: 1, constant: 0)
        let heightConstraint = NSLayoutConstraint(item: newView, attribute: NSLayoutAttribute.Height, relatedBy: NSLayoutRelation.Equal, toItem: view, attribute: NSLayoutAttribute.Height, multiplier: 1, constant: 0)
        let xConstraint = NSLayoutConstraint(item: newView, attribute: NSLayoutAttribute.CenterX, relatedBy: NSLayoutRelation.Equal, toItem: view, attribute: NSLayoutAttribute.CenterX, multiplier: 1, constant: 0)
        let yConstraint = NSLayoutConstraint(item: newView, attribute: NSLayoutAttribute.CenterY, relatedBy: NSLayoutRelation.Equal, toItem: view, attribute: NSLayoutAttribute.CenterY, multiplier: 1, constant: 0)
        
        view.addConstraint(widthConstraint)
        view.addConstraint(heightConstraint)
        view.addConstraint(xConstraint)
        view.addConstraint(yConstraint)
        
        print("New button array size: \(buttonArray.count)")
        
        //Adds notifications to indicate when app has been closed
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ViewController.exitApp), name: UIApplicationWillResignActiveNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ViewController.exitApp), name: UIApplicationWillTerminateNotification, object: nil)
        
        //Adds notifications to indicate when app has been reopened
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ViewController.loadApp), name: UIApplicationDidBecomeActiveNotification, object: nil)
        
        startTimer()
        startGame()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(animated: Bool) {
        print("View will appear")
        //startGame()
    }
    
    func addDotButtons()
    {
        for item in self.view.subviews
        {
            if let newButton = item as? UIButton
            {
                if newButton.tag == 0
                {
                    buttonArray.append(newButton)
                }
            }
        }
        
        for item in self.newView.subviews
        {
            if let newButton = item as? UIButton
            {
                if newButton.tag == 0
                {
                    buttonArray.append(newButton)
                }
            }
        }
        
        for i in 0..<buttonArray.count
        {
            setButtonParameters(buttonArray[i], buttonNumber: i+1)
        }
    }
    
    func startGame()
    {
        buttonArray.removeAll()
        
        setRegularConstraints()
        addDotButtons()
        
        playButton.hidden = true
        completedRounds = 0
        restartButton.hidden = false
        populateDots()
        stopTimer()
        startTimer()
    }
    
    func exitApp()
    {
        print("Exited")
        stopTimer()
    }
    
    func loadApp()
    {
        print("Loaded")
        //startGame()
    }
    
    func startTimer()
    {
        start = NSDate.timeIntervalSinceReferenceDate()
        myTimer = NSTimer.scheduledTimerWithTimeInterval(0.001, target: self, selector: #selector(ViewController.updateTimer), userInfo: nil, repeats: true)
    }
    
    func stopTimer()
    {
        myTimer.invalidate()
        currentTime = 0.00
    }
    
    func updateTimer()
    {
        let timeDifference = NSDate.timeIntervalSinceReferenceDate() - start
        currentTime += 0.01
        let currentTimeDisplayMilliseconds = Int(100*timeDifference) % 100
        let currenTimeDisplaySeconds = Int(floor(timeDifference))
        scoreLabel.text = "\(currentTimeDisplayMilliseconds)"
        scoreLabel2.text = "\(currenTimeDisplaySeconds)"
        
        if currentTimeDisplayMilliseconds < 10
        {
            scoreLabel.text = "0\(currentTimeDisplayMilliseconds)"
        }
    }
    
    @IBAction func restartGame(sender: AnyObject)
    {
        print("Restart Clicked")
        currentCountdownNumber = 4
        //startGame()
    }
    
    @IBAction func playAgain(sender: AnyObject)
    {
        print("Play again clicked")
        currentCountdownNumber = 4
        //startGame()
    }
    
    func populateDots()
    {
        var indexArray = [Int]()
        var i = 0
        for i in 0..<buttonArray.count
        {
            buttonArray[i].setImage(nil, forState: .Normal)
        }
        while i < 7
        {
            let randomIndex = Int(arc4random_uniform(UInt32(buttonArray.count)))
            if !indexArray.contains(randomIndex)
            {
                buttonArray[randomIndex].setImage(UIImage(named: "red dot.png"), forState: .Normal)
                indexArray.append(randomIndex)
                i += 1
            }
        }
        
        //For alternate game mode
        while i < 3
        {
            let randomIndex = Int(arc4random_uniform(UInt32(buttonArray.count)))
            if !indexArray.contains(randomIndex)
            {
                buttonArray[randomIndex].setImage(UIImage(named: "green dot.png"), forState: .Normal)
                //Tag of 1 indicates a green dot
                buttonArray[randomIndex].tag = 1
                indexArray.append(randomIndex)
                i += 1
            }
        }
    }

    @IBAction func buttonPressed(sender: AnyObject)
    {
        print("Button Array Size: \(buttonArray.count)")
        
        
        sender.setImage(nil, forState: .Normal)
        var buttonsLeft = false
        for button in buttonArray
        {
            if let _ = button.currentImage
            {
                buttonsLeft = true
            }
        }
        if buttonsLeft == false
        {
            print("Winner")
            completedRounds += 1
            if completedRounds > 5
            {
                stopTimer()
                playButton.hidden = false
                restartButton.hidden = true
            }
            else
            {
                populateDots()
            }
        }
    }
    
    func setRegularConstraints()
    {
        //Sets background constraints
        setItemConstraints(background, wm: 1, hm: 1, xm: 1, ym: 1, wc: 0, hc: 0, xc: 0, yc: 0)
        
        //Sets label constraints
        setItemConstraints(scoreLabel2, wm: 0.5, hm: 0, xm: 0.5, ym: 0.1709, wc: 0, hc: 40, xc: -2, yc: 0)
        setItemConstraints(scoreLabel, wm: 0.5, hm: 0, xm: 1.5, ym: 0.1709, wc: 0, hc: 40, xc: 2, yc: 0)
        setItemConstraints(periodLabel, wm: 0, hm: 0, xm: 1, ym: 0.1724, wc: 30, hc: 21, xc: 0, yc: 0)
        
        //Sets restart and play again button constraints
        setItemConstraints(restartButton, wm: 0, hm: 0, xm: 1.792, ym: 1.931, wc: 50, hc: 30, xc: 0, yc: 0)
        setItemConstraints(playButton, wm: 0, hm: 0, xm: 1, ym: 1.859, wc: 163, hc: 54, xc: 0, yc: 0)
    }
    
    func setItemConstraints(uiElement:UIView, wm:CGFloat, hm:CGFloat, xm:CGFloat, ym:CGFloat, wc:CGFloat, hc:CGFloat, xc:CGFloat, yc:CGFloat)
    {
        newView.addSubview(uiElement)
        uiElement.removeConstraints(uiElement.constraints)
        uiElement.translatesAutoresizingMaskIntoConstraints = false
        
        let widthConstraint = NSLayoutConstraint(item: uiElement, attribute: NSLayoutAttribute.Width, relatedBy: NSLayoutRelation.Equal, toItem: newView, attribute: NSLayoutAttribute.Width, multiplier: wm, constant: wc)
        let heightConstraint = NSLayoutConstraint(item: uiElement, attribute: NSLayoutAttribute.Height, relatedBy: NSLayoutRelation.Equal, toItem: newView, attribute: NSLayoutAttribute.Height, multiplier: hm, constant: hc)
        let xConstraint = NSLayoutConstraint(item: uiElement, attribute: NSLayoutAttribute.CenterX, relatedBy: NSLayoutRelation.Equal, toItem: newView, attribute: NSLayoutAttribute.CenterX, multiplier: xm, constant: xc)
        let yConstraint = NSLayoutConstraint(item: uiElement, attribute: NSLayoutAttribute.CenterY, relatedBy: NSLayoutRelation.Equal, toItem: newView, attribute: NSLayoutAttribute.CenterY, multiplier: ym, constant: yc)
        
        view.addConstraint(widthConstraint)
        view.addConstraint(heightConstraint)
        view.addConstraint(xConstraint)
        view.addConstraint(yConstraint)
    }
    
    func setButtonParameters(dotButton:UIButton, buttonNumber:Int)
    {
        newView.addSubview(dotButton)
        dotButton.removeConstraints(dotButton.constraints)
        dotButton.translatesAutoresizingMaskIntoConstraints = false
        
        var centerXMultiplier = CGFloat(buttonNumber % 4)
        var centerYMultiplier = CGFloat((floor(Float(buttonNumber) / 4.1)))
        
        if centerXMultiplier == 1 {centerXMultiplier = 2 * 0.148}
        else if centerXMultiplier == 2 {centerXMultiplier = 2 * 0.382666}
        else if centerXMultiplier == 3 {centerXMultiplier = 2 * 0.61733333}
        else {centerXMultiplier = 2 * 0.852}
        
        centerYMultiplier = (157.5 + 100*centerYMultiplier) / (667 / 2)
        
        //print("Button: \(buttonNumber) X: \(centerXMultiplier) Y: \(centerYMultiplier)")
        
        let widthConstraint = NSLayoutConstraint(item: dotButton, attribute: NSLayoutAttribute.Width, relatedBy: NSLayoutRelation.Equal, toItem: newView, attribute: NSLayoutAttribute.Width, multiplier: 0.213333, constant: 0)
        let heightConstraint = NSLayoutConstraint(item: dotButton, attribute: NSLayoutAttribute.Height, relatedBy: NSLayoutRelation.Equal, toItem: newView, attribute: NSLayoutAttribute.Width, multiplier: 0.213333, constant: 0)
        let xConstraint = NSLayoutConstraint(item: dotButton, attribute: NSLayoutAttribute.CenterX, relatedBy: NSLayoutRelation.Equal, toItem: newView, attribute: NSLayoutAttribute.CenterX, multiplier: centerXMultiplier, constant: 0)
        let yConstraint = NSLayoutConstraint(item: dotButton, attribute: NSLayoutAttribute.CenterY, relatedBy: NSLayoutRelation.Equal, toItem: newView, attribute: NSLayoutAttribute.CenterY, multiplier: centerYMultiplier, constant: 0)
        
        view.addConstraint(widthConstraint)
        view.addConstraint(heightConstraint)
        view.addConstraint(xConstraint)
        view.addConstraint(yConstraint)
    }
}

