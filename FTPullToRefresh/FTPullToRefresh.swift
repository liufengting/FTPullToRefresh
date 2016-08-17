//
//  FTPullToRefresh.swift
//  FTPullToRefreshDemo
//
//  Created by liufengting on 16/8/11.
//  Copyright © 2016年 liufengting. All rights reserved.
//

import UIKit
import ObjectiveC

private let FTPullToRefreshHeaderViewHeight : CGFloat = 64
private var FTPullToRefreshHeaderViewAssociateKey = 0
private var FTPullToRefreshFooterViewAssociateKey = 1

extension UIScrollView {
    

    

    
    var headerView : FTPullToRefreshView! {
        get {
            return objc_getAssociatedObject(self, &FTPullToRefreshHeaderViewAssociateKey) as! FTPullToRefreshView
        }
        set {
            objc_setAssociatedObject(self, &FTPullToRefreshHeaderViewAssociateKey, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN)
        }
    }
    
    var footerView : FTPullToRefreshView! {
        get {
            return objc_getAssociatedObject(self, &FTPullToRefreshFooterViewAssociateKey) as! FTPullToRefreshView
        }
        set {
            objc_setAssociatedObject(self, &FTPullToRefreshFooterViewAssociateKey, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN)
        }
    }
 
    public func addPullRefreshHeaderWithRefreshBlock(i : NSInteger) {
        self.addObserver(self, forKeyPath: "contentOffset", options: .New, context: nil)
     
        self.headerView = FTPullToRefreshView(frame : CGRectMake(0, self.contentOffset.y - FTPullToRefreshHeaderViewHeight, self.bounds.size.width, FTPullToRefreshHeaderViewHeight))
        self.headerView.backgroundColor = UIColor.whiteColor();
        self.addSubview(self.headerView)
        
        
        
    }

    public override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        if keyPath == "contentOffset" {
            if let offset = (change![NSKeyValueChangeNewKey]?.CGPointValue()) {

                self.scrollViewDidScrollWithContentOffset(offset)


            }
        }
    }
    
    func scrollViewDidScrollWithContentOffset(contentOffset: CGPoint) {
        

        if contentOffset.y == self.contentInset.top {
            self.headerView.pullingState = .None
 
        }else if contentOffset.y < self.contentInset.top {
            self.headerView.pullingPercentage = CGFloat(fabsf(Float((self.contentInset.top + contentOffset.y)/FTPullToRefreshHeaderViewHeight)))
            self.headerView.pullingState = .Pulling
        }else if contentOffset.y < FTPullToRefreshHeaderViewHeight + self.contentInset.top {
            self.headerView.pullingState = .None
        }else {
            self.headerView.pullingState = .None
        }
        
    }
    
    
    
    
}