//
//  FishRotate.swift
//  AnimationWithSwift
//
//  Created by Wayne Hsiao on 4/14/16.
//  Copyright © 2016 Wayne Hsiao. -ND. All rights reserved.
//

import UIKit

class FishRotateViewController: UIViewController {
    
    lazy fileprivate var fishView: UIImageView = {
        
        let size = 50
        let point = CGPoint(x: 100, y: 100)
        let rect = CGRect(x: Int(point.x), y: Int(point.y), width: size, height: size)
        
        func fishViewWithRect(_ rect: CGRect) -> UIImageView {
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

    func animate(_ sender: AnyObject) {
        let fullRotation = CGFloat(M_PI * 2)
        let duration = 2.0
        let delay = 0.0
        let options = UIViewKeyframeAnimationOptions.calculationModePaced
        
        UIView.animateKeyframes(withDuration: duration, delay: delay, options: options, animations: { () -> Void in
            UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 0, animations: { () -> Void in
                self.fishView.transform = CGAffineTransform(rotationAngle: 1/3 * fullRotation)
            })
            UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 0, animations: { () -> Void in
                self.fishView.transform = CGAffineTransform(rotationAngle: 2/3 * fullRotation)
            })
            UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 0, animations: { () -> Void in
                self.fishView.transform = CGAffineTransform(rotationAngle: 3/3 * fullRotation)
            })
            },
            completion: nil)
        
    }
}
