//
//  ViewController.swift
//  FTPullToRefreshDemo
//
//  Created by liufengting on 16/8/11.
//  Copyright © 2016年 liufengting. All rights reserved.
//

import UIKit

class ViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        
        self.tableView.addPullRefreshHeaderWithRefreshBlock(0);
        
    }

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 4
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView .dequeueReusableCellWithIdentifier("FTPullToRefreshCellIdentifier", forIndexPath: indexPath)
        
        
        return cell
    }

}

