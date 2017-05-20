//
//  BezierPath.swift
//  AnimationWithSwift
//
//  Created by Wayne Hsiao on 4/15/16.
//  Copyright © 2016 Wayne Hsiao. -ND. All rights reserved.
//

import UIKit

class BezierPathViewController: UIViewController, PickerViewControllerProtocol {
    
    fileprivate let demos = ["Fish swim", "Draw circle"]
    fileprivate var picker: UIPickerView?
    lazy fileprivate var ovalView: UIView = {
        let selfView = self.view
        let ovalView:UIView = UIView(frame: selfView!.frame)
        ovalView.backgroundColor = UIColor.white
        return ovalView
    }()
    
    fileprivate func fishesByAmount(_ amount: Int) -> [UIImageView?] {
        var fishes = [UIImageView?](repeating: nil, count: amount)
        var fishIndex = 0
        for _ in 0...amount-1 {
            let size:CGFloat = CGFloat(arc4random_uniform(40)+20)
            let yPosition: CGFloat = CGFloat(arc4random_uniform(200)+64)
            fishes[fishIndex] = fishViewWithRect(CGRect(x:0-size, y: yPosition, width: size, height: size))
            fishIndex += 1
        }
        return fishes
    }
    
    fileprivate func fishViewWithRect(_ rect: CGRect) -> UIImageView {
        let fishView = UIImageView(image: UIImage.init(named: "blue-fish"))
        fishView.frame = rect
        return fishView
    }
    
    fileprivate var fishes: [UIImageView?] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fishes = fishesByAmount(10)
        for fish in fishes {
            self.view.addSubview(fish!)
        }
        self.view.layer.contents = UIImage(named: "ocean.jpg")!.cgImage
    }
    
    func animate(_ sender: AnyObject) {
        if picker != nil {
            let selectedRow = picker!.selectedRow(inComponent: 0)
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
    
    fileprivate func swimFish(_ fish: UIImageView) {
        let path = UIBezierPath()
        path.move(to: CGPoint(x: fish.frame.minX, y: fish.frame.minY))
        path.addCurve(to: CGPoint(x: self.view.bounds.width+fish.bounds.width, y: 239), controlPoint1: CGPoint(x: 136, y: 373), controlPoint2: CGPoint(x: 178, y: 110))
        
        let anim = CAKeyframeAnimation(keyPath: "position")
        anim.path = path.cgPath
        anim.duration = Double(arc4random_uniform(40) + 30) / 10
        anim.timeOffset = Double(arc4random_uniform(290))
        anim.rotationMode = kCAAnimationRotateAuto
        anim.repeatCount = Float.infinity
        
        fish.layer.add(anim, forKey: "animate position along path")
    }
    
    fileprivate func drawOval() {
        let ovalStartAngle = CGFloat(90.01 * M_PI/180)
        let ovalEndAngle = CGFloat(90 * M_PI/180)
        let ovalRect = CGRect(x: 200, y: 200, width: 125, height: 125)
        
        let ovalPath = UIBezierPath()
        ovalPath.addArc(withCenter: CGPoint(x: ovalRect.midX, y: ovalRect.midY), radius: ovalRect.width / 2, startAngle: ovalStartAngle, endAngle: ovalEndAngle, clockwise: true)
        
        let progressLine = CAShapeLayer()
        progressLine.path = ovalPath.cgPath
        progressLine.strokeColor = UIColor ( red: 0.2472, green: 0.3113, blue: 0.9965, alpha: 1.0 ).cgColor
        progressLine.fillColor = UIColor.clear.cgColor
        progressLine.lineWidth = 10.0
        progressLine.lineCap = kCALineCapRound
        
        ovalView.layer.addSublayer(progressLine)
        
        let animateStrokeEnd = CABasicAnimation(keyPath: "strokeEnd")
        animateStrokeEnd.duration = 3.0
        animateStrokeEnd.fromValue = 0.0
        animateStrokeEnd.toValue = 1.0
        
        progressLine.add(animateStrokeEnd, forKey: "animate stroke")
        
    }
    
    fileprivate func stopFish(_ fish: UIImageView) {
        fish.layer.removeAnimation(forKey: "animate position along path")
    }
    
// MARK: PickerViewControllerProtocol
    func numberOfComponentsInPickerView(_ pickerView: UIPickerView) -> NSNumber {
        return NSNumber(value: 1 as Int)
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: NSNumber) -> NSNumber {
        return NSNumber(value: 2 as Int)
    }
    
    func pickerViewAttributedTitleForRow(_ row: NSNumber, forComponent component: NSNumber) -> NSAttributedString {
        return NSAttributedString(string: demos[row.intValue] , attributes: [NSFontAttributeName:UIFont(name: "Avenir-Roman", size: 20.0)!])
    }
    
    func pickerViewDidSelectRow(_ row: NSNumber, inComponent component: NSNumber) {
        if row == 0 {
            configureForFish()
        } else {
            configureForDraw()
        }
    }
    
    func getPickerView(_ pickerView: UIPickerView) {
        picker = pickerView
    }
    
    func configureForFish() {
        let theAnim = CABasicAnimation(keyPath: "contents")
        theAnim.fromValue = self.view.layer.contents
        theAnim.toValue = UIImage(named: "ocean.jpg")!.cgImage
        theAnim.duration = 2.0;
        self.view.layer.add(theAnim, forKey: "AnimateFrame")
        
        UIView.perform(.delete, on: [ovalView], options: UIViewAnimationOptions.allowAnimatedContent, animations: { () -> Void in
            
            }) { (bool: Bool) -> Void in
                
        }
    }
    
    func configureForDraw() {
        for fish in fishes {
            stopFish(fish!)
        }
        ovalView = UIView(frame: self.view.frame)
        ovalView.backgroundColor = UIColor.white
        view.addSubview(ovalView)
    }
}
