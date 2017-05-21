//
//  MainTableViewController.swift
//  AnimationWithSwift
//
//  Created by Wayne Hsiao on 4/13/16.
//  Copyright © 2016 Wayne Hsiao. -ND. All rights reserved.
//

import UIKit

class MainTableViewController: UITableViewController {
    
    typealias DemoList = [[AnyHashable : Any]]
    
    fileprivate var demoList: DemoList?
    
    override func viewDidLoad() {
        tableView.dataSource = self
        tableView.delegate = self
        
        let globalQueue = DispatchQueue.global()
        globalQueue.async { [weak self] in
            guard let strongself = self else { return }
            guard let finalPath = Bundle.main.path(forResource: "DemoList", ofType: "plist") else { return }
            guard let dictionaryResult = NSDictionary(contentsOfFile: finalPath) else { return }
            guard let demoList = dictionaryResult["Demos"] as? DemoList else { return }
            strongself.demoList = demoList
            strongself.tableView.reloadData()
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let demoList = demoList else { return 0 }
        return demoList.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: UITableViewCell! = tableView.dequeueReusableCell(withIdentifier: "Cell")
        if cell == nil {
            cell = UITableViewCell(style: .default, reuseIdentifier: "Cell")
        }
        
        cell.textLabel!.attributedText = NSAttributedString(string: (demoList![indexPath.row]["Display"] as! String), attributes: [NSFontAttributeName:UIFont(name: "Avenir-Roman", size: 25.0)!,
            NSForegroundColorAttributeName:UIColor ( red: 0.1789, green: 0.2242, blue: 1.0, alpha: 1.0 )])

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let title = demoList![indexPath.row]["Display"] as! String
        print("\(title) clicked!")
        tableView.deselectRow(at: indexPath, animated: true)
        let viewControllerIdentifier = demoList![indexPath.row]["Container"] as? String
        let currentViewControllerIdentifier = demoList![indexPath.row]["Controller"] as? String
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier: viewControllerIdentifier!) as! BaseViewController
        viewController.destination(viewController, currentViewControllerString: currentViewControllerIdentifier!)

        present(viewController, animated: true, completion: nil)
    }
    
    //override var prefersStatusBarHidden : Bool {
    //    return true
    //}
}
