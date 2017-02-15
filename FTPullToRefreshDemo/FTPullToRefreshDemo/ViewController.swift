//
//  ViewController.swift
//  FTPullToRefreshDemo
//
//  Created by liufengting https://github.com/liufengting on 16/8/11.
//  Copyright © 2016年 liufengting. All rights reserved.
//

import UIKit

class ViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        
        self.tableView.addPullRefreshHeaderWithRefreshBlock {
            
            self.stopRefreshAfter3Seconds()

        };
        
        self.tableView.addPullRefreshFooterWithRefreshBlock {
            
            self.stopRefreshAfter3Seconds()
            
        };

        
        
    }


    func stopRefreshAfter3Seconds() {
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(Int64(3.0 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC), execute: {
            self.tableView.stopRefreshing()
        })
    }
    
    
    
    
    
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 20
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView .dequeueReusableCell(withIdentifier: "FTPullToRefreshCellIdentifier", for: indexPath)
        
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
 
    
    }
    
    
    

}

