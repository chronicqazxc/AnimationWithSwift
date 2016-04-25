//
//  FishRotate.swift
//  AnimationWithSwift
//
//  Created by Wayne Hsiao on 4/14/16.
//  Copyright © 2016 Wayne Hsiao. -ND. All rights reserved.
//

import UIKit

class FishRotateViewController: UIViewController {
    
    lazy private var fishView: UIImageView = {
        
        let size = 50
        let point = CGPoint(x: 100, y: 100)
        let rect = CGRect(x: Int(point.x), y: Int(point.y), width: size, height: size)
        
        func fishViewWithRect(rect: CGRect) -> UIImageView {
            let fishView = UIImageView(image: UIImage.init(named: "blue-fish"))
            fishView.frame = rect
            return fishView
        }
        
        return fishViewWithRect(rect)
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.addSubview(fishView)
    }

    func animate(sender: AnyObject) {
        let fullRotation = CGFloat(M_PI * 2)
        let duration = 2.0
        let delay = 0.0
        let options = UIViewKeyframeAnimationOptions.CalculationModePaced
        
        UIView.animateKeyframesWithDuration(duration, delay: delay, options: options, animations: { () -> Void in
            UIView.addKeyframeWithRelativeStartTime(0, relativeDuration: 0, animations: { () -> Void in
                self.fishView.transform = CGAffineTransformMakeRotation(1/3 * fullRotation)
            })
            UIView.addKeyframeWithRelativeStartTime(0, relativeDuration: 0, animations: { () -> Void in
                self.fishView.transform = CGAffineTransformMakeRotation(2/3 * fullRotation)
            })
            UIView.addKeyframeWithRelativeStartTime(0, relativeDuration: 0, animations: { () -> Void in
                self.fishView.transform = CGAffineTransformMakeRotation(3/3 * fullRotation)
            })
            },
            completion: nil)
        
    }
}
