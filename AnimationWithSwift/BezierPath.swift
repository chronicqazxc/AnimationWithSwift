//
//  BezierPath.swift
//  AnimationWithSwift
//
//  Created by Wayne Hsiao on 4/15/16.
//  Copyright © 2016 Wayne Hsiao. -ND. All rights reserved.
//

import UIKit

class BezierPathViewController: UIViewController, PickerViewControllerProtocol {
    
    private let demos = ["Fish swim", "Draw circle"]
    private var picker: UIPickerView?
    lazy private var ovalView: UIView = {
        let selfView = self.view
        let ovalView:UIView = UIView(frame: selfView.frame)
        ovalView.backgroundColor = UIColor.whiteColor()
        return ovalView
    }()
    
    private func fishesByAmount(amount: Int) -> [UIImageView?] {
        var fishes = [UIImageView?](count: amount, repeatedValue: nil)
        var fishIndex = 0
        for _ in 0...amount-1 {
            let size:CGFloat = CGFloat(arc4random_uniform(40)+20)
            let yPosition: CGFloat = CGFloat(arc4random_uniform(200)+64)
            fishes[fishIndex] = fishViewWithRect(CGRect(x:0-size, y: yPosition, width: size, height: size))
            fishIndex += 1
        }
        return fishes
    }
    
    private func fishViewWithRect(rect: CGRect) -> UIImageView {
        let fishView = UIImageView(image: UIImage.init(named: "blue-fish"))
        fishView.frame = rect
        return fishView
    }
    
    private var fishes: [UIImageView?] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fishes = fishesByAmount(10)
        for fish in fishes {
            self.view.addSubview(fish!)
        }
        self.view.layer.contents = UIImage(named: "ocean.jpg")!.CGImage
    }
    
    func animate(sender: AnyObject) {
        if picker != nil {
            let selectedRow = picker!.selectedRowInComponent(0)
            if selectedRow == 0 {
                for fish in fishes {
                    swimFish(fish!)
                }
            } else if selectedRow == 1 {
                drawOval()
            }
        } else {
            for fish in fishes {
                swimFish(fish!)
            }
        }
    }
    
    private func swimFish(fish: UIImageView) {
        let path = UIBezierPath()
        path.moveToPoint(CGPoint(x: CGRectGetMinX(fish.frame), y: CGRectGetMinY(fish.frame)))
        path.addCurveToPoint(CGPoint(x: CGRectGetWidth(self.view.bounds)+CGRectGetWidth(fish.bounds), y: 239), controlPoint1: CGPoint(x: 136, y: 373), controlPoint2: CGPoint(x: 178, y: 110))
        
        let anim = CAKeyframeAnimation(keyPath: "position")
        anim.path = path.CGPath
        anim.duration = Double(arc4random_uniform(40) + 30) / 10
        anim.timeOffset = Double(arc4random_uniform(290))
        anim.rotationMode = kCAAnimationRotateAuto
        anim.repeatCount = Float.infinity
        
        fish.layer.addAnimation(anim, forKey: "animate position along path")
    }
    
    private func drawOval() {
        let ovalStartAngle = CGFloat(90.01 * M_PI/180)
        let ovalEndAngle = CGFloat(90 * M_PI/180)
        let ovalRect = CGRectMake(200, 200, 125, 125)
        
        let ovalPath = UIBezierPath()
        ovalPath.addArcWithCenter(CGPointMake(CGRectGetMidX(ovalRect), CGRectGetMidY(ovalRect)), radius: CGRectGetWidth(ovalRect) / 2, startAngle: ovalStartAngle, endAngle: ovalEndAngle, clockwise: true)
        
        let progressLine = CAShapeLayer()
        progressLine.path = ovalPath.CGPath
        progressLine.strokeColor = UIColor ( red: 0.2472, green: 0.3113, blue: 0.9965, alpha: 1.0 ).CGColor
        progressLine.fillColor = UIColor.clearColor().CGColor
        progressLine.lineWidth = 10.0
        progressLine.lineCap = kCALineCapRound
        
        ovalView.layer.addSublayer(progressLine)
        
        let animateStrokeEnd = CABasicAnimation(keyPath: "strokeEnd")
        animateStrokeEnd.duration = 3.0
        animateStrokeEnd.fromValue = 0.0
        animateStrokeEnd.toValue = 1.0
        
        progressLine.addAnimation(animateStrokeEnd, forKey: "animate stroke")
        
    }
    
    private func stopFish(fish: UIImageView) {
        fish.layer.removeAnimationForKey("animate position along path")
    }
    
// MARK: PickerViewControllerProtocol
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> NSNumber {
        return NSNumber(integer: 1)
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: NSNumber) -> NSNumber {
        return NSNumber(integer: 2)
    }
    
    func pickerViewAttributedTitleForRow(row: NSNumber, forComponent component: NSNumber) -> NSAttributedString {
        return NSAttributedString(string: demos[row.integerValue] , attributes: [NSFontAttributeName:UIFont(name: "Avenir-Roman", size: 20.0)!])
    }
    
    func pickerViewDidSelectRow(row: NSNumber, inComponent component: NSNumber) {
        if row == 0 {
            configureForFish()
        } else {
            configureForDraw()
        }
    }
    
    func getPickerView(pickerView: UIPickerView) {
        picker = pickerView
    }
    
    func configureForFish() {
        let theAnim = CABasicAnimation(keyPath: "contents")
        theAnim.fromValue = self.view.layer.contents
        theAnim.toValue = UIImage(named: "ocean.jpg")!.CGImage
        theAnim.duration = 2.0;
        self.view.layer.addAnimation(theAnim, forKey: "AnimateFrame")
        
        UIView.performSystemAnimation(.Delete, onViews: [ovalView], options: UIViewAnimationOptions.AllowAnimatedContent, animations: { () -> Void in
            
            }) { (bool: Bool) -> Void in
                
        }
    }
    
    func configureForDraw() {
        for fish in fishes {
            stopFish(fish!)
        }
        ovalView = UIView(frame: self.view.frame)
        ovalView.backgroundColor = UIColor.whiteColor()
        view.addSubview(ovalView)
    }
}