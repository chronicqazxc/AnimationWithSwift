//
//  FishSwim1.swift
//  AnimationWithSwift
//
//  Created by Wayne Hsiao on 4/13/16.
//  Copyright © 2016 Wayne Hsiao. -ND. All rights reserved.
//

import UIKit

class FishSwim1ViewController: UIViewController {
    
//    var numberOfFishSlider: UISlider?
    
    let kSliderValueKey = "sliderValueKey"
    
    @IBOutlet weak var numberOfFishLabel: UILabel!

    private var currentValue: NSNumber?
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        let userDefault: NSUserDefaults = NSUserDefaults.standardUserDefaults()
        currentValue = userDefault.objectForKey(kSliderValueKey) as? NSNumber
    }
    
    deinit {
        saveCurrentValue()
    }
    
//    override func didMoveToParentViewController(parent: UIViewController?) {
//        for childViewController in parent!.childViewControllers {
//            if NSStringFromClass(childViewController.classForCoder) == "AnimationWithSwift.WANSliderController" {
//                let vc: WANSliderController = childViewController as! WANSliderController
//                
//                vc.delegate = self
//                numberOfFishSlider = vc.numberOfFishSlider
//                
//                if let sliderValue = currentValue {
//                    numberOfFishSlider?.setValue(sliderValue.floatValue, animated: true)
//                } else {
//                    numberOfFishSlider?.setValue(10.0, animated: true)
//                }
//                setNumberOfFishLabelWithValue(numberOfFishSlider?.value)
//            }
//        }
//    }
    
    func adjustSlider(sender: UISlider) {
        sender.setValue(Float(currentValue!), animated: true)
        setNumberOfFishLabelWithValue(currentValue!.floatValue)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let childViewControllers = self.childViewControllers
        print(childViewControllers)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func sliderValueChange(sender: UISlider) {
        setNumberOfFishLabelWithValue(sender.value)
        currentValue = NSNumber(integer: Int(sender.value))
    }
    
    func saveCurrentValue() {
        let userDefault: NSUserDefaults = NSUserDefaults.standardUserDefaults()
        let value = NSNumber(integer: currentValue!.integerValue)
        userDefault.setObject(value, forKey: kSliderValueKey)
        userDefault.synchronize()
    }
    
    func animate(sender: AnyObject?) {
        for _ in 1...currentValue!.integerValue {
            fishSwim()
        }
    }
    
    func fishSwim() {
        let size:CGFloat = CGFloat(arc4random_uniform(40)+20)
        let yPosition: CGFloat = CGFloat(arc4random_uniform(200)+64)
        
        let fish = fishViewWithRect(CGRect(x:0-size, y: yPosition, width: size, height: size))
        self.view.addSubview(fish)
        
        let delay = NSTimeInterval(900 + arc4random_uniform(1000)) / 1000  // 1 - 1.9
        
        UIView.animateWithDuration(1.0,
            delay:delay,
            options:[UIViewAnimationOptions.CurveLinear],
            animations: { () -> Void in
                fish.frame = CGRect(x:CGRectGetWidth(UIScreen.mainScreen().bounds)+size, y: yPosition, width: size, height: size)
            },
            completion:
            { (bool: Bool) -> Void in
                fish.removeFromSuperview()
            }
        )
    }
    
    func setNumberOfFishLabelWithValue(var value: Float?) {
        value = value ?? 0
        let attributedText = NSAttributedString(string: "Number of fishes: \(Int(value!))", attributes: [NSFontAttributeName:UIFont(name: numberOfFishLabel.font.fontName, size: 25.0)!])
        numberOfFishLabel.attributedText = attributedText
    }
    
    func fishViewWithRect(rect: CGRect) -> UIImageView {
        let fishView = UIImageView(image: UIImage.init(named: "blue-fish"))
        fishView.frame = rect
        return fishView
    }
}