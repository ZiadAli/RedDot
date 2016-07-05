//
//  LoadingScreenController.swift
//  Red Dot
//
//  Created by Ziad Ali on 6/17/16.
//  Copyright © 2016 ZiadCorp. All rights reserved.
//

import UIKit
import iAd

class LoadingScreenController: UIViewController, ADBannerViewDelegate
{
    
    @IBOutlet var segueButton: UIButton!
    @IBOutlet var countdownLabel: UILabel!
    var bannerView: ADBannerView!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        bannerView = ADBannerView(adType: .Banner)
        bannerView.translatesAutoresizingMaskIntoConstraints = false
        bannerView.delegate = self
        view.addSubview(bannerView)
        
        print("Countdown loaded")
        segueButton.hidden = true
        //labelSequence()
    }
    
    override func viewDidAppear(animated: Bool) {
        labelSequence()
    }
    
    func labelSequence()
    {
        countdownLabel.text = "\(currentCountdownNumber)"
        fadeOut()
    }
    
    func transitionToGame()
    {
        sleep(1)
        performSegueWithIdentifier("transition", sender: nil)
    }
    
    func fadeOut()
    {
        //Fades out label
        UIView.animateWithDuration(0.6, delay: 0.25, options: UIViewAnimationOptions.CurveEaseOut, animations:
            {
                self.countdownLabel.alpha = 0.0
            }, completion:
            {
                (finished: Bool) -> Void in
                currentCountdownNumber -= 1
                self.countdownLabel.text = "\(currentCountdownNumber)"
                if currentCountdownNumber > 0
                {
                    self.fadeIn()
                }
                else
                {
                    self.countdownLabel.text = "Go!"
                    self.fadeIn()
                }
        })
    }
    
    func fadeIn()
    {
        //Fades label in quickly
        UIView.animateWithDuration(0.2, delay: 0.05, options: UIViewAnimationOptions.CurveEaseIn, animations:
            {
                self.countdownLabel.alpha = 1.0
            }, completion:
            {
                (finished: Bool) -> Void in
                if currentCountdownNumber > 0
                {
                    self.fadeOut()
                }
                else
                {
                    self.transitionToGame()
                }
        })
    }
}
