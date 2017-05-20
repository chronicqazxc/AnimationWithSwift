//
//  ViewController.swift
//  AnimationWithSwift
//
//  Created by Wayne Hsiao on 4/11/16.
//  Copyright © 2016 Wayne Hsiao. -ND. All rights reserved.
//

import UIKit

protocol BaseViewControllerProtocol {
    mutating func animate(_ sender: AnyObject)
}

class BaseViewController: UIViewController, BaseViewControllerProtocol {
    
    fileprivate var toolbar: UIToolbar?
    fileprivate var animateButton: UIButton?
    fileprivate var currentViewControllerString: String?
    fileprivate var currentViewController: UIViewController?
    
    func destination(_ destination: UIViewController, currentViewControllerString: String) {
            self.currentViewControllerString = currentViewControllerString
        
            currentViewController = destination
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        toolbar = UIToolbar(frame: CGRect.zero)
        let backButton = UIBarButtonItem(barButtonSystemItem: .stop, target: self, action: #selector(BaseViewController.back))
        let animateButton = UIBarButtonItem(barButtonSystemItem: .play, target: self, action: #selector(BaseViewController.animate(_:)))
        let space = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        
        toolbar!.items = [space, backButton, space, animateButton, space]
        self.toolbar!.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 44)        
        self.view.addSubview(toolbar!)
    }
    
    func back() {
        self.dismiss(animated: true, completion: nil)
    }
    
    func animate(_ sender: AnyObject) {
        
    }
    
    override var prefersStatusBarHidden : Bool {
        return true
    }
}

protocol WANSliderControllerDelegateProtocol {
    mutating func sliderValueChange(_ sender: AnyObject)
}

class WANSliderController: UIViewController {
    fileprivate weak var _delegate: AnyObject?
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
    
    @IBAction func sliderValueChange(_ sender: AnyObject) {
        delegate?.sliderValueChange(sender)
    }
}

class SliderViewController: BaseViewController, WANSliderControllerDelegateProtocol {
    
    fileprivate var slider: UISlider?
    @IBOutlet weak var containerView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier: currentViewControllerString!)
        viewController.view.frame = containerView.bounds
        containerView.addSubview(viewController.view)
        self.addChildViewController(viewController)
        viewController.didMove(toParentViewController: self)
        
        for childViewController in childViewControllers {
            if NSStringFromClass(childViewController.classForCoder).components(separatedBy: ".").last! == "WANSliderController" {
                let sliderViewController = childViewController as? WANSliderController
                sliderViewController!.delegate = self
                slider = sliderViewController!.numberOfFishSlider
                break
            }
        }
        
        for childViewController in childViewControllers {
            let childViewControllerString = NSStringFromClass(childViewController.classForCoder).components(separatedBy: ".").last!
            if childViewControllerString == currentViewControllerString {
                currentViewController = childViewController
                
                if childViewController.responds(to: Selector("adjustSlider:")) {
                    currentViewController!.performSelector(onMainThread: Selector("adjustSlider:"), with: slider, waitUntilDone: false)
                } else {
                    slider!.isHidden = true
                }
                
                break
            }
        }
    }
    
    override func animate(_ sender: AnyObject) {
        if currentViewController!.responds(to: #selector(BaseViewController.animate(_:))) {
            currentViewController!.performSelector(onMainThread: #selector(BaseViewController.animate(_:)), with: sender, waitUntilDone: false)
        }
    }
    
    func sliderValueChange(_ sender: AnyObject) {
        if currentViewController!.responds(to: #selector(WANSliderController.sliderValueChange(_:))) {
            currentViewController!.performSelector(onMainThread: #selector(WANSliderController.sliderValueChange(_:)), with: sender, waitUntilDone: false)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

    }
}

class WANPickerViewController: UIViewController {
    @IBOutlet weak var animatePicker: UIPickerView!
}

protocol PickerViewControllerProtocol {
    mutating func numberOfComponentsInPickerView(_ pickerView: UIPickerView) -> NSNumber
    mutating func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: NSNumber) -> NSNumber
    mutating func pickerViewAttributedTitleForRow(_ row: NSNumber, forComponent component: NSNumber) -> NSAttributedString
    mutating func pickerViewDidSelectRow(_ row: NSNumber, inComponent component: NSNumber)
    mutating func getPickerView(_ pickerView: UIPickerView)
}

class PickerViewController: BaseViewController, UIPickerViewDataSource, UIPickerViewDelegate {
    @IBOutlet weak var animateViewContainer: UIView!
    var picker: UIPickerView?
    fileprivate weak var _delegate: AnyObject?
    
    var delegate: AnyObject? {
        get {
            return _delegate
        }
        
        set {
            _delegate = newValue
            if newValue!.responds(to: Selector("getPickerView:")) {
                newValue!.perform(Selector("getPickerView:"), with: picker)
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier: currentViewControllerString!)
        viewController.view.frame = animateViewContainer.bounds
        animateViewContainer.addSubview(viewController.view)
        self.addChildViewController(viewController)
        viewController.didMove(toParentViewController: self)
        
        for childViewController in childViewControllers {
            if NSStringFromClass(childViewController.classForCoder).components(separatedBy: ".").last! == "WANPickerViewController" {
                let pickerViewController = childViewController as? WANPickerViewController
                picker = pickerViewController!.animatePicker
                picker!.dataSource = self
                picker!.delegate = self
                break
            }
        }
        
        for childViewController in childViewControllers {
            let childViewControllerString = NSStringFromClass(childViewController.classForCoder).components(separatedBy: ".").last!
            if childViewControllerString == currentViewControllerString {
                currentViewController = childViewController
                delegate = currentViewController
                break
            }
        }
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        if currentViewController!.responds(to: #selector(UIPickerViewDataSource.numberOfComponents(in:))) {
            let value: Unmanaged<AnyObject> = currentViewController!.perform(#selector(UIPickerViewDataSource.numberOfComponents(in:)), with: pickerView)
            let valueNumber = value.takeUnretainedValue() as! NSNumber
            return valueNumber.intValue
        } else {
            return 0
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if currentViewController!.responds(to: #selector(UIPickerViewDataSource.pickerView(_:numberOfRowsInComponent:))) {
            let value: Unmanaged<AnyObject> = currentViewController!.perform(#selector(UIPickerViewDataSource.pickerView(_:numberOfRowsInComponent:)), with: pickerView, with:NSNumber(value: component as Int))
            let valueNumber = value.takeUnretainedValue() as! NSNumber
            return valueNumber.intValue
        } else {
            return 0
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        if currentViewController!.responds(to: Selector("pickerViewAttributedTitleForRow:forComponent:")) {
            let value: Unmanaged<AnyObject> = currentViewController!.perform(Selector("pickerViewAttributedTitleForRow:forComponent:"), with: NSNumber(value: row as Int), with: NSNumber(value: component as Int))
            let title = value.takeUnretainedValue() as? NSAttributedString
            print(title)
            return title
        } else {
            return NSAttributedString(string: "", attributes: [NSFontAttributeName:UIFont(name: "Avenir-Roman", size: 25.0)!])
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if currentViewController!.responds(to: Selector("pickerViewDidSelectRow:inComponent:")) {
            currentViewController!.perform(Selector("pickerViewDidSelectRow:inComponent:"), with: NSNumber(value: row as Int), with: NSNumber(value: component as Int))
        }
    }
    
    override func animate(_ sender: AnyObject) {
        if currentViewController!.responds(to: #selector(BaseViewController.animate(_:))) {
            currentViewController!.performSelector(onMainThread: #selector(BaseViewController.animate(_:)), with: sender, waitUntilDone: false)
        }
    }
}

