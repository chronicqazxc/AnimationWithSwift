//
//  ViewController.swift
//  AnimationWithSwift
//
//  Created by Wayne Hsiao on 4/11/16.
//  Copyright © 2016 Wayne Hsiao. -ND. All rights reserved.
//

import UIKit

protocol BaseViewControllerProtocol {
    mutating func animate(sender: AnyObject)
}

class BaseViewController: UIViewController, BaseViewControllerProtocol {
    
    private var toolbar: UIToolbar?
    private var animateButton: UIButton?
    private var currentViewControllerString: String?
    private var currentViewController: UIViewController?
    
    func destination(destination: UIViewController, let currentViewControllerString: String) {
            self.currentViewControllerString = currentViewControllerString
        
            currentViewController = destination
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        toolbar = UIToolbar(frame: CGRectZero)
        let backButton = UIBarButtonItem(barButtonSystemItem: .Stop, target: self, action: Selector("back"))
        let animateButton = UIBarButtonItem(barButtonSystemItem: .Play, target: self, action: Selector("animate:"))
        let space = UIBarButtonItem(barButtonSystemItem: .FlexibleSpace, target: nil, action: nil)
        
        toolbar!.items = [space, backButton, space, animateButton, space]
        self.toolbar!.frame = CGRect(x: 0, y: 0, width: CGRectGetWidth(UIScreen.mainScreen().bounds), height: 44)        
        self.view.addSubview(toolbar!)
    }
    
    func back() {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func animate(sender: AnyObject) {
        
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
}

protocol WANSliderControllerDelegateProtocol {
    mutating func sliderValueChange(sender: AnyObject)
}

class WANSliderController: UIViewController {
    private weak var _delegate: AnyObject?
    var delegate: AnyObject? {
        set {
            if let _ = newValue as? WANSliderControllerDelegateProtocol {
                self._delegate = newValue
            } else {
                _delegate = nil
                print("ChildController Error: delegate must conform WANSliderControllerDelegateProtocol")
            }
        }
        
        get {
            return _delegate
        }
    }
    @IBOutlet weak var numberOfFishSlider: UISlider!
    
    @IBAction func sliderValueChange(sender: AnyObject) {
        delegate?.sliderValueChange(sender)
    }
}

class SliderViewController: BaseViewController, WANSliderControllerDelegateProtocol {
    
    private var slider: UISlider?
    @IBOutlet weak var containerView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let viewController = storyboard.instantiateViewControllerWithIdentifier(currentViewControllerString!)
        viewController.view.frame = containerView.bounds
        containerView.addSubview(viewController.view)
        self.addChildViewController(viewController)
        viewController.didMoveToParentViewController(self)
        
        for childViewController in childViewControllers {
            if NSStringFromClass(childViewController.classForCoder).componentsSeparatedByString(".").last! == "WANSliderController" {
                let sliderViewController = childViewController as? WANSliderController
                sliderViewController!.delegate = self
                slider = sliderViewController!.numberOfFishSlider
                break
            }
        }
        
        for childViewController in childViewControllers {
            let childViewControllerString = NSStringFromClass(childViewController.classForCoder).componentsSeparatedByString(".").last!
            if childViewControllerString == currentViewControllerString {
                currentViewController = childViewController
                
                if childViewController.respondsToSelector(Selector("adjustSlider:")) {
                    currentViewController!.performSelectorOnMainThread(Selector("adjustSlider:"), withObject: slider, waitUntilDone: false)
                } else {
                    slider!.hidden = true
                }
                
                break
            }
        }
    }
    
    override func animate(sender: AnyObject) {
        if currentViewController!.respondsToSelector(Selector("animate:")) {
            currentViewController!.performSelectorOnMainThread(Selector("animate:"), withObject: sender, waitUntilDone: false)
        }
    }
    
    func sliderValueChange(sender: AnyObject) {
        if currentViewController!.respondsToSelector(Selector("sliderValueChange:")) {
            currentViewController!.performSelectorOnMainThread(Selector("sliderValueChange:"), withObject: sender, waitUntilDone: false)
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {

    }
}

class WANPickerViewController: UIViewController {
    @IBOutlet weak var animatePicker: UIPickerView!
}

protocol PickerViewControllerProtocol {
    mutating func numberOfComponentsInPickerView(pickerView: UIPickerView) -> NSNumber
    mutating func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: NSNumber) -> NSNumber
    mutating func pickerViewAttributedTitleForRow(row: NSNumber, forComponent component: NSNumber) -> NSAttributedString
    mutating func pickerViewDidSelectRow(row: NSNumber, inComponent component: NSNumber)
    mutating func getPickerView(pickerView: UIPickerView)
}

class PickerViewController: BaseViewController, UIPickerViewDataSource, UIPickerViewDelegate {
    @IBOutlet weak var animateViewContainer: UIView!
    var picker: UIPickerView?
    private weak var _delegate: AnyObject?
    
    var delegate: AnyObject? {
        get {
            return _delegate
        }
        
        set {
            _delegate = newValue
            if newValue!.respondsToSelector(Selector("getPickerView:")) {
                newValue!.performSelector(Selector("getPickerView:"), withObject: picker)
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let viewController = storyboard.instantiateViewControllerWithIdentifier(currentViewControllerString!)
        viewController.view.frame = animateViewContainer.bounds
        animateViewContainer.addSubview(viewController.view)
        self.addChildViewController(viewController)
        viewController.didMoveToParentViewController(self)
        
        for childViewController in childViewControllers {
            if NSStringFromClass(childViewController.classForCoder).componentsSeparatedByString(".").last! == "WANPickerViewController" {
                let pickerViewController = childViewController as? WANPickerViewController
                picker = pickerViewController!.animatePicker
                picker!.dataSource = self
                picker!.delegate = self
                break
            }
        }
        
        for childViewController in childViewControllers {
            let childViewControllerString = NSStringFromClass(childViewController.classForCoder).componentsSeparatedByString(".").last!
            if childViewControllerString == currentViewControllerString {
                currentViewController = childViewController
                delegate = currentViewController
                break
            }
        }
    }
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        if currentViewController!.respondsToSelector(Selector("numberOfComponentsInPickerView:")) {
            let value: Unmanaged<AnyObject> = currentViewController!.performSelector(Selector("numberOfComponentsInPickerView:"), withObject: pickerView)
            let valueNumber = value.takeUnretainedValue() as! NSNumber
            return valueNumber.integerValue
        } else {
            return 0
        }
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if currentViewController!.respondsToSelector(Selector("pickerView:numberOfRowsInComponent:")) {
            let value: Unmanaged<AnyObject> = currentViewController!.performSelector(Selector("pickerView:numberOfRowsInComponent:"), withObject: pickerView, withObject:NSNumber(integer: component))
            let valueNumber = value.takeUnretainedValue() as! NSNumber
            return valueNumber.integerValue
        } else {
            return 0
        }
    }
    
    func pickerView(pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        if currentViewController!.respondsToSelector(Selector("pickerViewAttributedTitleForRow:forComponent:")) {
            let value: Unmanaged<AnyObject> = currentViewController!.performSelector(Selector("pickerViewAttributedTitleForRow:forComponent:"), withObject: NSNumber(integer: row), withObject: NSNumber(integer: component))
            let title = value.takeUnretainedValue() as? NSAttributedString
            print(title)
            return title
        } else {
            return NSAttributedString(string: "", attributes: [NSFontAttributeName:UIFont(name: "Avenir-Roman", size: 25.0)!])
        }
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if currentViewController!.respondsToSelector(Selector("pickerViewDidSelectRow:inComponent:")) {
            currentViewController!.performSelector(Selector("pickerViewDidSelectRow:inComponent:"), withObject: NSNumber(integer: row), withObject: NSNumber(integer: component))
        }
    }
    
    override func animate(sender: AnyObject) {
        if currentViewController!.respondsToSelector(Selector("animate:")) {
            currentViewController!.performSelectorOnMainThread(Selector("animate:"), withObject: sender, waitUntilDone: false)
        }
    }
}

