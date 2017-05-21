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

    fileprivate var currentValue: NSNumber?
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        let userDefault: UserDefaults = UserDefaults.standard
        currentValue = userDefault.object(forKey: kSliderValueKey) as? NSNumber
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
    
    func adjustSlider(_ sender: UISlider) {
        guard let currentValue = currentValue else {
            sender.setValue(Float(0), animated: true)
            setNumberOfFishLabelWithValue(Float(0))
            return
        }
        sender.setValue(Float(currentValue), animated: true)
        setNumberOfFishLabelWithValue(currentValue.floatValue)
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
    
    func sliderValueChange(_ sender: UISlider) {
        setNumberOfFishLabelWithValue(sender.value)
        currentValue = NSNumber(value: Int(sender.value) as Int)
    }
    
    func saveCurrentValue() {
        let userDefault: UserDefaults = UserDefaults.standard
        let value = NSNumber(value: currentValue!.intValue as Int)
        userDefault.set(value, forKey: kSliderValueKey)
        userDefault.synchronize()
    }
    
    func animate(_ sender: AnyObject?) {
        for _ in 1...currentValue!.intValue {
            fishSwim()
        }
    }
    
    func fishSwim() {
        let size:CGFloat = CGFloat(arc4random_uniform(40)+20)
        let yPosition: CGFloat = CGFloat(arc4random_uniform(200)+64)
        
        let fish = fishViewWithRect(CGRect(x:0-size, y: yPosition, width: size, height: size))
        self.view.addSubview(fish)
        
        let delay = TimeInterval(900 + arc4random_uniform(1000)) / 1000  // 1 - 1.9
        
        UIView.animate(withDuration: 1.0,
            delay:delay,
            options:[UIViewAnimationOptions.curveLinear],
            animations: { () -> Void in
                fish.frame = CGRect(x:UIScreen.main.bounds.width+size, y: yPosition, width: size, height: size)
            },
            completion:
            { (bool: Bool) -> Void in
                fish.removeFromSuperview()
            }
        )
    }
    
    func setNumberOfFishLabelWithValue(_ value: Float?) {
        var value = value
        value = value ?? 0
        let attributedText = NSAttributedString(string: "Number of fishes: \(Int(value!))", attributes: [NSFontAttributeName:UIFont(name: numberOfFishLabel.font.fontName, size: 25.0)!])
        numberOfFishLabel.attributedText = attributedText
    }
    
    func fishViewWithRect(_ rect: CGRect) -> UIImageView {
        let fishView = UIImageView(image: UIImage.init(named: "blue-fish"))
        fishView.frame = rect
        return fishView
    }
}
