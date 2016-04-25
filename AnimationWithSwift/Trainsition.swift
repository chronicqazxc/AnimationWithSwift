//
//  CurlUp.swift
//  AnimationWithSwift
//
//  Created by Wayne Hsiao on 4/13/16.
//  Copyright © 2016 Wayne Hsiao. -ND. All rights reserved.
//

import UIKit

class ColoredView: UIView {
    private let kBackgroundColor = "BackgroundColor"
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.backgroundColor = aDecoder.decodeObjectForKey(kBackgroundColor) as? UIColor
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    override func isEqual(object: AnyObject?) -> Bool {
        return object!.backgroundColor == self.backgroundColor
    }
    
    override func encodeWithCoder(aCoder: NSCoder) {
        super.encodeWithCoder(aCoder)
        aCoder.encodeObject(self.backgroundColor, forKey: kBackgroundColor)
    }
}

extension UIViewAnimationOptions {
    static func animationForKey(key: String) -> UIViewAnimationOptions? {
        switch key {
        case "TransitionNone":
            return .TransitionNone
        case "TransitionFlipFromLeft":
            return .TransitionFlipFromLeft
        case "TransitionFlipFromRight":
            return .TransitionFlipFromRight
        case "TransitionCurlUp":
            return .TransitionCurlUp
        case "TransitionCurlDown":
            return .TransitionCurlDown
        case "TransitionCrossDissolve":
            return .TransitionCrossDissolve
        case "TransitionFlipFromTop":
            return .TransitionFlipFromTop
        case "TransitionFlipFromBottom":
            return .TransitionFlipFromBottom
        default:
            return .TransitionNone
        }
    }
}

class TrainsitionViewController: UIViewController {
    
    enum CurrentView: Int {
        case redView
        case blueView
    }
    
    private var animatePicker:UIPickerView? {
        
        get {
            var viewController: WANPickerViewController? = nil
            for chilViewController in self.childViewControllers {
                if NSStringFromClass(chilViewController.classForCoder) == "AnimationWithSwift.WANPickerViewController" {
                    viewController =  chilViewController as? WANPickerViewController
                    break
                }
            }
            
            return viewController?.animatePicker
        }
        
    }
    
    private var currentView: UIView?
    
    lazy private var transitionOptions: UIViewAnimationOptions? = {
        return UIViewAnimationOptions.TransitionNone
    }()
    
    let kCurlCurrentView: String = "CurlCurrentView"
    static let kCurlCurrentView: String = "CurlCurrentView"
    
    lazy private var containerView: UIView = {
        var tempContainerView = UIView(frame: CGRect(x: 60, y: 60, width: 200, height: 200))
        return tempContainerView
    }()
    
    lazy private var redSquare: ColoredView = {
        var tempContainerView = ColoredView(frame: CGRect(x: 0, y: 0, width: 200, height: 200))
        tempContainerView.backgroundColor = UIColor.redColor()
        return tempContainerView
    }()
    
    lazy private var blueSquare: ColoredView = {
        var tempContainerView = ColoredView(frame: CGRect(x: 0, y: 0, width: 200, height: 200))
        tempContainerView.backgroundColor = UIColor.blueColor()
        return tempContainerView
    }()
    
    lazy private var currentValue:ColoredView? = {
        let userDefault: NSUserDefaults = NSUserDefaults.standardUserDefaults()
        let encodedObject: NSData? = userDefault.objectForKey(kCurlCurrentView) as? NSData
        if encodedObject == nil {
            let currentView = ColoredView()
            currentView.backgroundColor = UIColor.redColor()
            return currentView
        } else {
            return NSKeyedUnarchiver.unarchiveObjectWithData(encodedObject!) as? ColoredView
        }
    }()
    
    deinit {
        saveCurrentViewToUserDefault()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.addSubview(containerView)
        
        if let currentView: ColoredView = currentValue {
            if (currentView.isEqual(redSquare)) {
                containerView.addSubview(redSquare)
            } else {
                containerView.addSubview(blueSquare)
            }
        } else {
            containerView.addSubview(redSquare)
        }
    }
    
    func animate(sender: AnyObject) {
        
        let button: UIBarButtonItem = sender as! UIBarButtonItem
        button.enabled = false
        
        let views = viewsTuple()
        UIView.transitionWithView(containerView, duration: 1.0, options: transitionOptions!, animations: { () -> Void in
            views.frontView.removeFromSuperview()
            self.containerView.addSubview(views.backView)
            })
            { (finish: Bool) -> Void in
                button.enabled = true
                if (views.backView == self.blueSquare) {
                    self.currentValue = self.blueSquare
                } else {
                    self.currentValue = self.redSquare
                }
        }
    }
    
    func viewsTuple() -> (frontView: UIView, backView: UIView) {
        if (currentValue!.isEqual(redSquare)) {
            return (frontView: redSquare, backView: blueSquare)
        } else {
            return (frontView: blueSquare, backView: redSquare)
        }
    }
    
    func saveCurrentViewToUserDefault() {
        let userDefault: NSUserDefaults = NSUserDefaults.standardUserDefaults()
        var saveValue: AnyObject?
        if (currentValue!.isEqual(redSquare)) {
            saveValue = NSKeyedArchiver.archivedDataWithRootObject(redSquare)
        } else {
            saveValue = NSKeyedArchiver.archivedDataWithRootObject(blueSquare)
        }
        
        
        userDefault.setObject(saveValue, forKey: kCurlCurrentView)
        userDefault.synchronize()
    }
    
    lazy private var trainsitions: NSArray = {
        let finalPath = NSBundle.mainBundle().pathForResource("Trainsitions", ofType: "json")
        let jsonData = NSData(contentsOfFile: finalPath!)
        var jsonDic: NSDictionary?
        var trainsitions: NSArray?
        do {
            jsonDic = try NSJSONSerialization.JSONObjectWithData(jsonData!, options: .MutableContainers) as? NSDictionary
            trainsitions = jsonDic!["trainsitions"] as? NSArray
        } catch {
            print("error")
        }
        return trainsitions!
    }()
    
// MARK: PickerViewControllerProtocol
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> NSNumber {
        return NSNumber(integer: 1)
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: NSNumber) -> NSNumber {
        return NSNumber(integer: trainsitions.count)
    }
    
    func pickerViewAttributedTitleForRow(row: NSNumber, forComponent component: NSNumber) -> NSAttributedString? {
        return NSAttributedString(string: trainsitions[row.integerValue] as! String, attributes: [NSFontAttributeName:UIFont(name: "Avenir-Roman", size: 20.0)!])
    }
    
    func pickerViewDidSelectRow(row: NSNumber, inComponent component: NSNumber) {
        transitionOptions = UIViewAnimationOptions.animationForKey(trainsitions[row.integerValue] as! String)
    }
}
