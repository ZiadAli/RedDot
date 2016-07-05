//
//  ViewController.swift
//  Red Dot
//
//  Created by Ziad Ali on 1/30/16.
//  Copyright © 2016 ZiadCorp. All rights reserved.
//

import UIKit
import AVFoundation

var currentCountdownNumber:Int = 3

var gameMode = "Endurance"
var gameDifficulty = 3

var soundsOn = true

/* Game Mode: Time Trial
 * The goal is to get through all of the dots in the shortest amount of time possible.
 * There will be easy, medium, and hard levels. In easy the player must get through only red dots. In medium the player must
 * get through red dots with distractor dots. In hard the amount of distractor dots is increased. The amount of rounds is the same
 * for each difficulty level.
 */

/* Game Mode: Endurance
 * In this game mode, the player must last as long as possible without being timed out by the clock. The
 * clock counts down here, not up, and every round gets more difficult. In each round the amount of time the player has decreases
 * and the amount of distractors increases until both hit a ceiling. The rate at which both increase depends on the difficulty.
 */

/* Game Mode: Challenge
 * In this game mode the goal is to hit the red dots as they appear as fast as possible. The rate at which the red dots appear
 * will increase as the game progresses, and your score will be the amount of time you last. There will be easy, medium, and
 * hard difficulties which will correspond to how fast the red dot rate increases throughout the game. If at any point the player
 * clicks on a distractor dot or the entire screen fills up then the player loses.
 */

class ViewController: UIViewController {

    @IBOutlet var background: UIImageView!
    @IBOutlet var restartButton: UIButton!
    @IBOutlet var button: UIButton!
    @IBOutlet var scoreLabel: UILabel!
    @IBOutlet var scoreLabel2: UILabel!
    @IBOutlet var periodLabel: UILabel!
    @IBOutlet var menuView: UIView!
    @IBOutlet var menuViewTitle: UILabel!
    @IBOutlet var menuViewPlayAgain: UIButton!
    @IBOutlet var menuViewYourScore: UILabel!
    @IBOutlet var menuViewHighScore: UILabel!
    
    var buttonArray = [UIButton]()
    var completedRounds = 0
    var buttonsClicked = 0
    var start = 0.0
    var myTimer:NSTimer!
    let newView = UIView()
    var gameStillActive = true
    var timeDifference = 0.0 //Keeps track of passage of time
    var gameModeButtonCount = 7 //Controls how many red dots are added per round
    var difficultyLimit = 0 //Keeps track of how many distractors to add
    var enduranceDistractorRate = 1 //Controls how many more distractors are added per turn in Endurance
    var enduranceTimeLimit = 5.0 //Amount of time player has to complete each round in Endurance
    var userFinishedRound = true //Used to cancel animation during Challenge mode
    var challengeModeRepopulateTime = 1.0 //Time at which challenge mode repopulates dots
    var challengeModeRepopulateAdder = 1.0 //Difference between when dots are added
    var firstRound = true
    var timerIsStopped = false
    var redDotTimeDuration = 5.0 //Time that red dots last in challenge mode
    var greenDotTimeDuration = 1.0 //Time that green dots last in challenge mode
    var greenDotTimer = 0 //When it reaches a certain value in challenge mode it allows one green dot to be made
    var greenDotTimerLimit = 5 //Rate at which green dots are added, determined by difficulty
    var menuViewLoaded = false //Keeps track of whether or not menu view was already loaded
    
    //Player arrays hold multiple players so sounds can be layered on top of each other instead of cutting each other off
    var correctPlayerArray:[AVAudioPlayer] = [] //Plays sound when user hits red dot
    var wrongPlayerArray:[AVAudioPlayer] = [] //Plays sound when user hits green dot
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        view.removeConstraints(view.constraints)
        newView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(newView)
        
        menuViewPlayAgain.enabled = false
        
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
        
        //Instantiates correct player and wrong player
        let correctPath = NSBundle.mainBundle().pathForResource("blopSound", ofType: "wav")!
        let wrongPath = NSBundle.mainBundle().pathForResource("punchSound", ofType: "wav")!
        do
        {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryAmbient)
            try AVAudioSession.sharedInstance().setActive(true)
            
            for _ in 0..<10
            {
                var correctPlayer:AVAudioPlayer = AVAudioPlayer()
                try correctPlayer = AVAudioPlayer(contentsOfURL: NSURL(fileURLWithPath: correctPath))
                correctPlayer.prepareToPlay()
                self.correctPlayerArray.append(correctPlayer)
            }
            
            for _ in 0..<10
            {
                var wrongPlayer:AVAudioPlayer = AVAudioPlayer()
                try wrongPlayer = AVAudioPlayer(contentsOfURL: NSURL(fileURLWithPath: wrongPath))
                wrongPlayer.prepareToPlay()
                self.wrongPlayerArray.append(wrongPlayer)
            }
        }
        catch
        {
            print("Error: Couldn't create audio players")
        }
        
        startTimer()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(animated: Bool) {
        print("View will appear")
        startGame()
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
        firstRound = true
        menuViewLoaded = false
        
        if gameMode == "Challenge"
        {
            gameModeButtonCount = 1
            redDotTimeDuration -= (Double(gameDifficulty) - 1.0)
            greenDotTimerLimit = 6 - gameDifficulty
        }
        
        buttonArray.removeAll()
        
        setRegularConstraints()
        addDotButtons()
        
        completedRounds = 0
        
        stopTimer()
        populateDots()
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
    
    func playSound(soundName:String)
    {
        if soundsOn
        {
            switch soundName
            {
                case "Correct":
                    print("Correct")
                    playSoundFromArray(correctPlayerArray)
                case "Wrong":
                    print("Wrong")
                    playSoundFromArray(wrongPlayerArray)
            default:
                    print("Nothing")
            }
        }
    }
    
    func resetAudioPlayer(player:AVAudioPlayer)
    {
        player.pause()
        player.currentTime = 0
        player.prepareToPlay()
    }
    
    func playSoundFromArray(soundArray:[AVAudioPlayer])
    {
        var playedSound = false
        var i = 0
        while i < soundArray.count && playedSound == false
        {
            if !soundArray[i].playing
            {
                soundArray[i].play()
                playedSound = true
            }
            i += 1
        }
    }
    
    func startTimer()
    {
        timerIsStopped = false
        start = NSDate.timeIntervalSinceReferenceDate()
        myTimer = NSTimer.scheduledTimerWithTimeInterval(0.001, target: self, selector: #selector(ViewController.updateTimer), userInfo: nil, repeats: true)
    }
    
    func saveScore(intScore:Int, doubleScore:Double, scoreIsInteger:Bool)
    {
        let key = "\(gameMode) \(gameDifficulty)"
        
        if scoreIsInteger
        {
            if NSUserDefaults.standardUserDefaults().integerForKey(key) < intScore
            {
                NSUserDefaults.standardUserDefaults().setValue(intScore, forKey: key)
            }
        }
        else
        {
            let currentHighScore = NSUserDefaults.standardUserDefaults().doubleForKey(key)
            
            if currentHighScore > doubleScore || currentHighScore <= 0.01
            {
                NSUserDefaults.standardUserDefaults().setValue(doubleScore, forKey: key)
            }
        }
    }
    
    func stopTimer()
    {
        if !timerIsStopped
        {
            timerIsStopped = true
            myTimer.invalidate()
            if !firstRound
            {
                print("Stopping timer")
                if gameMode == "Challenge"
                {
                    
                    let layer = view.layer.presentationLayer() as! CALayer
                    let frame = layer.frame
                    view.layer.removeAllAnimations()
                    view.frame = frame
                    
                    //self.newView.layer.removeAllAnimations()
                    //self.gameView.layer.speed = 0.0
                    //self.newView.frame = (self.newView.layer.presentationLayer()?.frame)!
                    for i in 0..<buttonArray.count
                    {
                        if buttonArray[i].currentImage != nil
                        {
                            //let buttonAlpha = CGFloat(buttonArray[i].alpha)
                            //print("Button Alpha: \(self.gameView.layer.presentationLayer()?.buttonArray[i].alpha)")
                            //stopFade(buttonArray[i], buttonAlpha: buttonAlpha)
                        }
                    }
                }
            }
        }
    }
    
    func loadMenuView()
    {
        if !menuViewLoaded //Prevents repeat loading of menu view
        {
            print("Loading menu view")
            var highScoreInt:Int = 0 //Holds high score if it's an integer
            var highScoreString:String = "" //Holds high score if it's a double
            var highScoreIsDouble = false //Indicates if high score was a double
            
            if gameMode == "Time Trial" //Formats high score double and your score double and sets high score is double to true
            {
                let yourScoreTimeMilliseconds = Int(100*timeDifference) % 100
                let yourScoreTimeSeconds = Int(floor(timeDifference))
                print("Your Score: \(timeDifference)")
                var yourScoreString = "\(yourScoreTimeSeconds).\(yourScoreTimeMilliseconds)"
                if yourScoreTimeMilliseconds == 0 {yourScoreString = "\(yourScoreTimeSeconds).\(yourScoreTimeMilliseconds)0"}
                else if yourScoreTimeMilliseconds < 10 {yourScoreString = "\(yourScoreTimeSeconds).0\(yourScoreTimeMilliseconds)"}
                
                menuViewYourScore.text = "Your Score: \(yourScoreString)"
                
                let highScoreDouble = NSUserDefaults.standardUserDefaults().doubleForKey("\(gameMode) \(gameDifficulty)")

                print("High Score: \(highScoreDouble)")
                let highScoreTimeMilliseconds = Int(100*highScoreDouble) % 100
                print(highScoreTimeMilliseconds)
                let highScoreTimeSeconds = Int(floor(highScoreDouble))
                print(highScoreTimeSeconds)
                
                highScoreString = "\(highScoreTimeSeconds).\(highScoreTimeMilliseconds)"
                if highScoreTimeMilliseconds == 0 {highScoreString = "\(highScoreTimeSeconds).\(highScoreTimeMilliseconds)0"}
                else if highScoreTimeMilliseconds < 10 {highScoreString = "\(highScoreTimeSeconds).0\(highScoreTimeMilliseconds)"}
                highScoreIsDouble = true
            }
            else if gameMode == "Endurance" {menuViewYourScore.text = "Your Score: \(completedRounds)"}
            else if gameMode == "Challenge" {menuViewYourScore.text = "Your Score: \(buttonsClicked)"}
            
            if highScoreIsDouble {menuViewHighScore.text = "High Score: \(highScoreString)"}
                
            else
            {
                highScoreInt = NSUserDefaults.standardUserDefaults().integerForKey("\(gameMode) \(gameDifficulty)")
                menuViewHighScore.text = "High Score: \(highScoreInt)"
            }
            
            newView.bringSubviewToFront(menuView)
            moveUp(menuView)
            menuViewLoaded = true
        }
    }
    
    func updateTimer()
    {
        var stopTimerBoolean = false //Must use boolean because stop timer command comes after labels have been set
        if gameMode == "Time Trial"
        {
            timeDifference = NSDate.timeIntervalSinceReferenceDate() - start
        }
        
        else if gameMode == "Endurance"
        {
            timeDifference = enduranceTimeLimit - (NSDate.timeIntervalSinceReferenceDate() - start)
            if timeDifference <= 0.0
            {
                print("Ran out of time")
                stopTimerBoolean = true
                gameStillActive = false
                saveScore(completedRounds, doubleScore: 0.0, scoreIsInteger: true)
                timeDifference = 0.0
                loadMenuView()
            }
        }
        
        else if gameMode == "Challenge"
        {
            timeDifference = (NSDate.timeIntervalSinceReferenceDate() - start)
            if timeDifference > challengeModeRepopulateTime
            {
                greenDotTimer += 1
                if greenDotTimer >= greenDotTimerLimit
                {
                    difficultyLimit = 1
                    greenDotTimer = 0
                }
                
                populateDots()
                difficultyLimit = 0
                
                challengeModeRepopulateTime += challengeModeRepopulateAdder
                challengeModeRepopulateAdder -= 0.025
                if challengeModeRepopulateAdder < 0.17 {challengeModeRepopulateAdder = 0.17}
            }
        }
        
        let currentTimeDisplayMilliseconds = Int(100*timeDifference) % 100
        let currenTimeDisplaySeconds = Int(floor(timeDifference))
        scoreLabel.text = "\(currentTimeDisplayMilliseconds)"
        scoreLabel2.text = "\(currenTimeDisplaySeconds)"
        
        if currentTimeDisplayMilliseconds < 10
        {
            scoreLabel.text = "0\(currentTimeDisplayMilliseconds)"
        }
        
        if stopTimerBoolean == true || (timeDifference >= 200.0 && gameMode == "Time Trial")
        {
            stopTimer()
        }
    }
    
    @IBAction func restartGame(sender: AnyObject)
    {
        print("Restart Clicked")
        currentCountdownNumber = 3
        stopTimer()
    }
    
    @IBAction func playAgain(sender: AnyObject)
    {
        print("Play again clicked")
        currentCountdownNumber = 3
    }
    
    func populateDots()
    {
        print("Populating dots")
        userFinishedRound = false
        
        //if gameMode == "Challenge" {gameModeButtonCount += 1}
        if gameMode == "Endurance" {difficultyLimit = enduranceDistractorRate}
        var indexArray = [Int]()
        var i = 0
        for i in 0..<buttonArray.count
        {
            if firstRound || gameMode != "Challenge"
            {
                buttonArray[i].setImage(nil, forState: .Normal)
                buttonArray[i].tag = 2
            }
            if gameMode == "Challenge"
            {
                if buttonArray[i].currentImage == nil
                {
                   fadeIn(buttonArray[i])
                }
                else
                {
                    indexArray.append(i) //Adds index of all buttons that are still active so they aren't overridden
                }
            }
        }
        
        //Adds the red dots
        while i < gameModeButtonCount
        {
            let randomIndex = Int(arc4random_uniform(UInt32(buttonArray.count)))
            if !indexArray.contains(randomIndex)
            {
                buttonArray[randomIndex].setImage(UIImage(named: "red dot.png"), forState: .Normal)
                buttonArray[randomIndex].tag = 0
                if gameMode == "Challenge" {fadeOut(buttonArray[randomIndex], timeDuration: redDotTimeDuration)}
                indexArray.append(randomIndex)
                i += 1
            }
        }
        
        if indexArray.count >= 20 //Would occur in Challenge game mode
        {
            gameStillActive = false
            stopTimer()
            saveScore(buttonsClicked, doubleScore: 0.0, scoreIsInteger: true)
            loadMenuView()
        }
        
        i = 0
        
        if gameMode == "Time Trial"
        {
            //Preset distractor limits for Time Trial
            if gameDifficulty == 2 {difficultyLimit = 5}
            else if gameDifficulty == 3 {difficultyLimit = 10}
        }
        
        while i < difficultyLimit
        {
            let randomIndex = Int(arc4random_uniform(UInt32(buttonArray.count)))
            if !indexArray.contains(randomIndex)
            {
                buttonArray[randomIndex].setImage(UIImage(named: "green dot.png"), forState: .Normal)
                //Tag of 1 indicates a green dot
                if gameMode == "Challenge" {fadeOut(buttonArray[randomIndex], timeDuration: greenDotTimeDuration)}
                buttonArray[randomIndex].tag = 1
                indexArray.append(randomIndex)
                i += 1
            }
        }
        
        firstRound = false
    }
    
    func fadeOut(fadeButton:UIButton, timeDuration:Double)
    {
        UIView.animateWithDuration(timeDuration, delay: 1.0, options: UIViewAnimationOptions.AllowUserInteraction, animations:
            {
                fadeButton.alpha = 0.1
            }, completion:
            {
                (finished: Bool) -> Void in
                if finished
                {
                    fadeButton.setImage(nil, forState: .Normal)

                    if fadeButton.tag == 0
                    {
                        print("Game Over")
                        self.stopTimer()
                        self.gameStillActive = false
                        self.saveScore(self.buttonsClicked, doubleScore: 0.0, scoreIsInteger: true)
                        self.loadMenuView()
                    }
                    
                    if fadeButton.tag == 1
                    {
                        fadeButton.tag = 2
                    }
                }
        })
    }
    
    func moveUp(menu:UIView)
    {
        UIView.animateWithDuration(0.75, delay: 0, options: UIViewAnimationOptions.CurveEaseIn, animations:
        {
            menu.frame.origin.y = -300
            self.menuViewPlayAgain.enabled = false
        }
        ) { (finished: Bool) -> Void in
            self.menuViewPlayAgain.enabled = true
        }
    }
    
    func checkUserFinishedRound()
    {
        if !userFinishedRound
        {
            print("User didn't finish round")
        }
    }
    
    func fadeIn(fadeButton:UIButton)
    {
        UIView.animateWithDuration(0.01, delay: 0.0, options: UIViewAnimationOptions.AllowUserInteraction, animations:
            {
                fadeButton.alpha = 1.0
            }, completion:
            {
                (finished: Bool) -> Void in
        })
    }
    
    func stopFade(fadeButton:UIButton, buttonAlpha:CGFloat)
    {
        UIView.animateWithDuration(0.01, delay: 0.0, options: [.BeginFromCurrentState], animations:
            {
                
            }, completion:
            {
                (finished: Bool) -> Void in
        })
    }
    
    func setButtonTag(button:UIButton, newTag:Int)
    {
        button.tag = newTag
    }

    @IBAction func buttonPressed(sender: AnyObject)
    {
        if gameStillActive == true
        {
            //For alternate game mode (green button clicked)
            if sender.tag == 1 && gameMode == "Time Trial"
            {
                start -= Double(gameDifficulty-1)
                playSound("Wrong")
            }
            else if sender.tag == 1
            {
                playSound("Wrong")
                print("You lose!")
                stopTimer()
                gameStillActive = false
                if gameMode == "Challenge" {saveScore(buttonsClicked, doubleScore: 0.0, scoreIsInteger: true)}
                else if gameMode == "Endurance" {saveScore(completedRounds, doubleScore: 0.0, scoreIsInteger: true)}
                loadMenuView()
            }
            
            
            else if sender.tag == 0
            {
                playSound("Correct")
                buttonsClicked += 1
                sender.setImage(nil, forState: .Normal)
                setButtonTag(sender as! UIButton, newTag: 2)
                if gameMode == "Challenge" {fadeIn(sender as! UIButton)}
                var buttonsLeft = false
                for button in buttonArray
                {
                    if let _ = button.currentImage
                    {
                        if button.tag == 0
                        {
                            buttonsLeft = true
                        }
                    }
                }
                if buttonsLeft == false
                {
                    completedRounds += 1
                    userFinishedRound = true
                    
                    //Time Trial condition block
                    if completedRounds > 5 && gameMode == "Time Trial"
                    {
                        gameStillActive = false
                        stopTimer()
                        saveScore(0, doubleScore: timeDifference, scoreIsInteger: false)
                        loadMenuView()
                    }
                    else if gameMode == "Time Trial"
                    {
                        populateDots()
                    }
                    
                    //Endurance condition block
                    if gameMode == "Endurance"
                    {
                        //Reduces time limit for Endurance based on difficulty. Keeps minimum at 1.0 second
                        enduranceTimeLimit -= Double(gameDifficulty) / 4.0
                        if enduranceTimeLimit < 1.65 && gameDifficulty != 3 {enduranceTimeLimit = 1.75}
                        else if enduranceTimeLimit < 1.35 && gameDifficulty == 3 {enduranceTimeLimit = 1.35}
                        
                        //Resets the clock
                        start = NSDate.timeIntervalSinceReferenceDate()
                        
                        //Increases the amount of distractors added based on rounds completed and game difficulty.
                        enduranceDistractorRate = 1 + Int(floor(Double(completedRounds) * Double(gameDifficulty) / 3.0))
                        if enduranceDistractorRate > (18 - gameModeButtonCount) {enduranceDistractorRate = (18-gameModeButtonCount)}
                        populateDots()
                    }
                }
            }
        }
    }
    
    
    

    func setRegularConstraints()
    {
        //Sets menu view contraints
        setItemConstraints(newView, uiElement: menuView, wm: 0, hm: 0, xm: 1, ym: 1, wc: 250, hc: 250, xc: 0, yc: 0)
        menuView.layer.cornerRadius = 20
        menuView.clipsToBounds = true
        setItemConstraints(menuView, uiElement: menuViewYourScore, wm: 0, hm: 0, xm: 1, ym: 1, wc: 250, hc: 30, xc: 0, yc: -21)
        setItemConstraints(menuView, uiElement: menuViewHighScore, wm: 0, hm: 0, xm: 1, ym: 1, wc: 250, hc: 30, xc: 0, yc: 21)
        setItemConstraints(menuView, uiElement: menuViewTitle, wm: 0, hm: 0, xm: 1, ym: 1, wc: 250, hc: 50, xc: 0, yc: -92)
        setItemConstraints(menuView, uiElement: menuViewPlayAgain, wm: 0, hm: 0, xm: 1, ym: 1, wc: 120, hc: 30, xc: 0, yc: 97)
        
        //Sets background constraints
        setItemConstraints(newView, uiElement: background, wm: 1, hm: 1, xm: 1, ym: 1, wc: 0, hc: 0, xc: 0, yc: 0)
        
        //Sets label constraints
        setItemConstraints(newView, uiElement: scoreLabel2, wm: 0.5, hm: 0, xm: 0.5, ym: 0.1709, wc: 0, hc: 40, xc: -2, yc: 0)
        setItemConstraints(newView, uiElement: scoreLabel, wm: 0.5, hm: 0, xm: 1.5, ym: 0.1709, wc: 0, hc: 40, xc: 2, yc: 0)
        setItemConstraints(newView, uiElement: periodLabel, wm: 0, hm: 0, xm: 1, ym: 0.1724, wc: 30, hc: 21, xc: 0, yc: 0)
        
        //Sets restart, play again, and menu button constraints
        setItemConstraints(newView, uiElement: restartButton, wm: 0, hm: 0, xm: 1.792, ym: 1.931, wc: 50, hc: 30, xc: 0, yc: 0)
    }
    
    func setItemConstraints(parentView: UIView, uiElement:UIView, wm:CGFloat, hm:CGFloat, xm:CGFloat, ym:CGFloat, wc:CGFloat, hc:CGFloat, xc:CGFloat, yc:CGFloat)
    {
        parentView.addSubview(uiElement)
        uiElement.removeConstraints(uiElement.constraints)
        uiElement.translatesAutoresizingMaskIntoConstraints = false
        
        let widthConstraint = NSLayoutConstraint(item: uiElement, attribute: NSLayoutAttribute.Width, relatedBy: NSLayoutRelation.Equal, toItem: parentView, attribute: NSLayoutAttribute.Width, multiplier: wm, constant: wc)
        let heightConstraint = NSLayoutConstraint(item: uiElement, attribute: NSLayoutAttribute.Height, relatedBy: NSLayoutRelation.Equal, toItem: parentView, attribute: NSLayoutAttribute.Height, multiplier: hm, constant: hc)
        let xConstraint = NSLayoutConstraint(item: uiElement, attribute: NSLayoutAttribute.CenterX, relatedBy: NSLayoutRelation.Equal, toItem: parentView, attribute: NSLayoutAttribute.CenterX, multiplier: xm, constant: xc)
        let yConstraint = NSLayoutConstraint(item: uiElement, attribute: NSLayoutAttribute.CenterY, relatedBy: NSLayoutRelation.Equal, toItem: parentView, attribute: NSLayoutAttribute.CenterY, multiplier: ym, constant: yc)
        
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

