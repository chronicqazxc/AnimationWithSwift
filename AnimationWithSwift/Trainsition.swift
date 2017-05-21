//
//  CurlUp.swift
//  AnimationWithSwift
//
//  Created by Wayne Hsiao on 4/13/16.
//  Copyright © 2016 Wayne Hsiao. -ND. All rights reserved.
//

import UIKit

class ColoredView: UIView {
    fileprivate let kBackgroundColor = "BackgroundColor"
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.backgroundColor = aDecoder.decodeObject(forKey: kBackgroundColor) as? UIColor
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    override func isEqual(_ object: Any?) -> Bool {
        return (object! as AnyObject).backgroundColor == self.backgroundColor
    }
    
    override func encode(with aCoder: NSCoder) {
        super.encode(with: aCoder)
        aCoder.encode(self.backgroundColor, forKey: kBackgroundColor)
    }
}

extension UIViewAnimationOptions {
    static func animationForKey(_ key: String) -> UIViewAnimationOptions? {
        switch key {
        case "TransitionNone":
            return UIViewAnimationOptions()
        case "TransitionFlipFromLeft":
            return .transitionFlipFromLeft
        case "TransitionFlipFromRight":
            return .transitionFlipFromRight
        case "TransitionCurlUp":
            return .transitionCurlUp
        case "TransitionCurlDown":
            return .transitionCurlDown
        case "TransitionCrossDissolve":
            return .transitionCrossDissolve
        case "TransitionFlipFromTop":
            return .transitionFlipFromTop
        case "TransitionFlipFromBottom":
            return .transitionFlipFromBottom
        default:
            return UIViewAnimationOptions()
        }
    }
}

class TrainsitionViewController: UIViewController {
    
    enum CurrentView: Int {
        case redView
        case blueView
    }
    
    fileprivate var animatePicker:UIPickerView? {
        
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
    
    fileprivate var currentView: UIView?
    
    lazy fileprivate var transitionOptions: UIViewAnimationOptions? = {
        return UIViewAnimationOptions()
    }()
    
    let kCurlCurrentView: String = "CurlCurrentView"
    static let kCurlCurrentView: String = "CurlCurrentView"
    
    lazy fileprivate var containerView: UIView = {
        var tempContainerView = UIView(frame: CGRect(x: 60, y: 60, width: 200, height: 200))
        return tempContainerView
    }()
    
    lazy fileprivate var redSquare: ColoredView = {
        var tempContainerView = ColoredView(frame: CGRect(x: 0, y: 0, width: 200, height: 200))
        tempContainerView.backgroundColor = UIColor.red
        return tempContainerView
    }()
    
    lazy fileprivate var blueSquare: ColoredView = {
        var tempContainerView = ColoredView(frame: CGRect(x: 0, y: 0, width: 200, height: 200))
        tempContainerView.backgroundColor = UIColor.blue
        return tempContainerView
    }()
    
    lazy fileprivate var currentValue:ColoredView? = {
        let userDefault: UserDefaults = UserDefaults.standard
        let encodedObject: Data? = userDefault.object(forKey: kCurlCurrentView) as? Data
        if encodedObject == nil {
            let currentView = ColoredView()
            currentView.backgroundColor = UIColor.red
            return currentView
        } else {
            return NSKeyedUnarchiver.unarchiveObject(with: encodedObject!) as? ColoredView
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
    
    func animate(_ sender: AnyObject) {
        
        let button: UIBarButtonItem = sender as! UIBarButtonItem
        button.isEnabled = false
        
        let views = viewsTuple()
        UIView.transition(with: containerView, duration: 1.0, options: transitionOptions!, animations: { () -> Void in
            views.frontView.removeFromSuperview()
            self.containerView.addSubview(views.backView)
            })
            { (finish: Bool) -> Void in
                button.isEnabled = true
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
        let userDefault: UserDefaults = UserDefaults.standard
        var saveValue: AnyObject?
        if (currentValue!.isEqual(redSquare)) {
            saveValue = NSKeyedArchiver.archivedData(withRootObject: redSquare) as AnyObject?
        } else {
            saveValue = NSKeyedArchiver.archivedData(withRootObject: blueSquare) as AnyObject?
        }
        
        
        userDefault.set(saveValue, forKey: kCurlCurrentView)
        userDefault.synchronize()
    }
    
    lazy fileprivate var trainsitions: NSArray = {
        let finalPath = Bundle.main.path(forResource: "Trainsitions", ofType: "json")
        let jsonData = try? Data(contentsOf: URL(fileURLWithPath: finalPath!))
        var jsonDic: NSDictionary?
        var trainsitions: NSArray?
        do {
            jsonDic = try JSONSerialization.jsonObject(with: jsonData!, options: .mutableContainers) as? NSDictionary
            trainsitions = jsonDic!["trainsitions"] as? NSArray
        } catch {
            print("error")
        }
        return trainsitions!
    }()
    
// MARK: PickerViewControllerProtocol
    
    func numberOfComponentsInPickerView(_ pickerView: UIPickerView) -> NSNumber {
        return NSNumber(value: 1 as Int)
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: NSNumber) -> NSNumber {
        return NSNumber(value: trainsitions.count as Int)
    }
    
    func pickerViewAttributedTitleForRow(_ row: NSNumber, forComponent component: NSNumber) -> NSAttributedString? {
        return NSAttributedString(string: trainsitions[row.intValue] as! String, attributes: [NSFontAttributeName:UIFont(name: "Avenir-Roman", size: 20.0)!])
    }
    
    func pickerViewDidSelectRow(_ row: NSNumber, inComponent component: NSNumber) {
        transitionOptions = UIViewAnimationOptions.animationForKey(trainsitions[row.intValue] as! String)
    }
}
