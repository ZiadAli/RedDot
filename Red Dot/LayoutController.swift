//
//  LayoutController.swift
//  Red Dot
//
//  Created by Ziad Ali on 6/17/16.
//  Copyright © 2016 ZiadCorp. All rights reserved.
//

import UIKit

class LayoutController: UIViewController
{
    @IBOutlet var button: UIButton!
    var buttonArray = [UIButton]()
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        view.removeConstraints(view.constraints)
        
        let newView = UIView()
        newView.backgroundColor = UIColor.greenColor()
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
        
        for item in self.view.subviews
        {
            if let newButton = item as? UIButton
            {
                buttonArray.append(newButton)
            }
        }
        
        print("Button array size: \(buttonArray.count)")
        for var i in 0..<buttonArray.count
        {
            newView.addSubview(buttonArray[i])
            let currentButton = buttonArray[i]
            currentButton.removeConstraints(currentButton.constraints)
            currentButton.removeConstraints(currentButton.constraints)
            currentButton.translatesAutoresizingMaskIntoConstraints = false
            
            let multiplier = CGFloat((i+1) / 4)
            
            let widthConstraint2 = NSLayoutConstraint(item: currentButton, attribute: NSLayoutAttribute.Width, relatedBy: NSLayoutRelation.Equal, toItem: newView, attribute: NSLayoutAttribute.Width, multiplier: 0.213333, constant: 0)
            let heightConstraint2 = NSLayoutConstraint(item: currentButton, attribute: NSLayoutAttribute.Height, relatedBy: NSLayoutRelation.Equal, toItem: newView, attribute: NSLayoutAttribute.Width, multiplier: 0.213333, constant: 0)
            let xConstraint2 = NSLayoutConstraint(item: currentButton, attribute: NSLayoutAttribute.CenterX, relatedBy: NSLayoutRelation.Equal, toItem: newView, attribute: NSLayoutAttribute.CenterX, multiplier: CGFloat(Float(i+3)/3.0), constant: 0)
            let yConstraint2 = NSLayoutConstraint(item: currentButton, attribute: NSLayoutAttribute.CenterY, relatedBy: NSLayoutRelation.Equal, toItem: newView, attribute: NSLayoutAttribute.CenterY, multiplier: CGFloat(Float(i+3)/3.0), constant: 0)
            
            view.addConstraint(widthConstraint2)
            view.addConstraint(heightConstraint2)
            view.addConstraint(xConstraint2)
            view.addConstraint(yConstraint2)
        }
        
        newView.addSubview(button)
        
        button.removeConstraints(button.constraints)
        button.translatesAutoresizingMaskIntoConstraints = false
        
        let widthConstraint2 = NSLayoutConstraint(item: button, attribute: NSLayoutAttribute.Width, relatedBy: NSLayoutRelation.Equal, toItem: newView, attribute: NSLayoutAttribute.Width, multiplier: 0.213333, constant: 0)
        let heightConstraint2 = NSLayoutConstraint(item: button, attribute: NSLayoutAttribute.Height, relatedBy: NSLayoutRelation.Equal, toItem: newView, attribute: NSLayoutAttribute.Width, multiplier: 0.213333, constant: 0)
        let xConstraint2 = NSLayoutConstraint(item: button, attribute: NSLayoutAttribute.CenterX, relatedBy: NSLayoutRelation.Equal, toItem: newView, attribute: NSLayoutAttribute.CenterX, multiplier: 1, constant: 0)
        let yConstraint2 = NSLayoutConstraint(item: button, attribute: NSLayoutAttribute.CenterY, relatedBy: NSLayoutRelation.Equal, toItem: newView, attribute: NSLayoutAttribute.CenterY, multiplier: 1, constant: 0)
        
        view.addConstraint(widthConstraint2)
        view.addConstraint(heightConstraint2)
        view.addConstraint(xConstraint2)
        view.addConstraint(yConstraint2)
        
    }
    @IBAction func buttonClicked(sender: AnyObject) {
        
    }
    
    func removeConstraints()
    {
    
    }
}
