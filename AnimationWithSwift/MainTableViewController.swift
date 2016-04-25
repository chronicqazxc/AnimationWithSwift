//
//  MainTableViewController.swift
//  AnimationWithSwift
//
//  Created by Wayne Hsiao on 4/13/16.
//  Copyright © 2016 Wayne Hsiao. -ND. All rights reserved.
//

import UIKit

class MainTableViewController: UITableViewController {
    
    private var demoList: NSArray? = [String]()
    
    override func viewDidLoad() {
        self.tableView.dataSource = self
        self.tableView.delegate = self
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
            let finalPath = NSBundle.mainBundle().pathForResource("DemoList", ofType: "plist")
            let dictionaryResult = NSDictionary(contentsOfFile: finalPath!)
            let demoList: NSArray? = dictionaryResult!["Demos"] as? NSArray
            dispatch_async(dispatch_get_main_queue(), {
                NSNotificationCenter.defaultCenter().postNotificationName("DemoListLoaded", object: nil, userInfo: ["DemoList":dictionaryResult!])
                self.demoList = demoList
                self.tableView.reloadData()
            });
        });
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.demoList!.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell: UITableViewCell! = tableView.dequeueReusableCellWithIdentifier("Cell")
        if cell == nil {
            cell = UITableViewCell(style: .Default, reuseIdentifier: "Cell")
        }
        
        cell.textLabel!.attributedText = NSAttributedString(string: (demoList![indexPath.row]["Display"] as! String), attributes: [NSFontAttributeName:UIFont(name: "Avenir-Roman", size: 25.0)!,
            NSForegroundColorAttributeName:UIColor ( red: 0.1789, green: 0.2242, blue: 1.0, alpha: 1.0 )])

        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let title = demoList![indexPath.row]["Display"] as! String
        print("\(title) clicked!")
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        let viewControllerIdentifier = demoList![indexPath.row]["Container"] as? String
        let currentViewControllerIdentifier = demoList![indexPath.row]["Controller"] as? String
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let viewController = storyboard.instantiateViewControllerWithIdentifier(viewControllerIdentifier!) as! BaseViewController
        viewController.destination(viewController, currentViewControllerString: currentViewControllerIdentifier!)

        self.presentViewController(viewController, animated: true, completion: nil)
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
}