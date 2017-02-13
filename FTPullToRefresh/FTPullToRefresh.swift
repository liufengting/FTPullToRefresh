//
//  FTPullToRefresh.swift
//  FTPullToRefreshDemo
//
//  Created by liufengting https://github.com/liufengting on 16/8/11.
//  Copyright © 2016年 liufengting. All rights reserved.
//

import UIKit
import ObjectiveC

private let FTPullToRefreshHeaderViewHeight : CGFloat = 64
private var FTPullToRefreshHeaderViewAssociateKey = 0
private var FTPullToRefreshFooterViewAssociateKey = 1

private let FTPullToRefreshKeyPathContentOffset = "contentOffset"
private let FTPullToRefreshKeyPathPanGestureState = "state"


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
 
    public func addPullRefreshHeaderWithRefreshBlock(_ refreshingBlock: @escaping (()->())) {
        self.addObservers()
        
        self.headerView = FTPullToRefreshView(frame : CGRect(x: 0, y: self.contentOffset.y - FTPullToRefreshHeaderViewHeight, width: self.bounds.size.width, height: FTPullToRefreshHeaderViewHeight))
        self.headerView.refreshingBlock = refreshingBlock
        self.headerView.originalContentOffset = self.contentOffset.y
        self.addSubview(self.headerView)
    }

    public func addPullRefreshFooterWithRefreshBlock(_ refreshingBlock: @escaping (()->())) {
        self.addObservers()
        
        self.footerView = FTPullToRefreshView(frame : CGRect(x: 0, y: self.contentSize.height, width: self.bounds.size.width, height: FTPullToRefreshHeaderViewHeight))
        self.footerView.backgroundColor = UIColor.black
        self.footerView.refreshingBlock = refreshingBlock
        self.footerView.originalContentOffset = self.contentOffset.y
        self.addSubview(self.footerView)
    }

    
    func addObservers() {
//        self.removeObservers()
        self.addObserver(self, forKeyPath: FTPullToRefreshKeyPathContentOffset, options: .new, context: nil)
        self.panGestureRecognizer.addObserver(self, forKeyPath: FTPullToRefreshKeyPathPanGestureState, options: .new, context: nil)
    }
    func removeObservers() {
        self.removeObserver(self, forKeyPath: FTPullToRefreshKeyPathContentOffset)
        self.panGestureRecognizer.removeObserver(self, forKeyPath: FTPullToRefreshKeyPathPanGestureState)
    }
    
    
    
    
    public func stopRefreshing(){
        if self.headerView.pullingState == .refreshing {
            self.headerView.stopRefreshing()
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(Int64(1.0 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC), execute: {
                self.contentInset.top = 64
                self.setContentOffset(CGPoint(x: 0, y: -64), animated: true)
            })
        }
    }

    
    override open func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {

        if keyPath == FTPullToRefreshKeyPathContentOffset {
            if let newValue = change?[.newKey] as? NSValue {
                self.scrollViewDidScrollWithContentOffset(newValue.cgPointValue)
            }
        }else if keyPath == FTPullToRefreshKeyPathPanGestureState {
            if let newValue = change?[.newKey] as? Int {
                
                
                print(newValue)
                
                self.scrollViewDidChangePanGestureState(UIGestureRecognizerState(rawValue: newValue)!)
            }
        }
    }
    
    func scrollViewDidScrollWithContentOffset(_ contentOffset: CGPoint) {
        
        print(contentOffset)

        if contentOffset.y == self.contentInset.top {
            self.headerView.pullingState = .none
        }else if contentOffset.y < self.contentInset.top {
            if self.isDragging {
                self.headerView.pullingPercentage = CGFloat(fabsf(Float((self.contentInset.top + contentOffset.y)/FTPullToRefreshHeaderViewHeight)))
            }
        }
        
        
        
        print(self.contentSize.height,self.contentInset.top)
        if contentOffset.y == self.contentSize.height + self.contentInset.top {


        }else if contentOffset.y > self.contentSize.height - self.bounds.size.height + FTPullToRefreshHeaderViewHeight {

        }
        
    }
    
    func scrollViewDidChangePanGestureState(_ state: UIGestureRecognizerState) {
        
        print(state)
        
        switch state {
        case .ended:
            if self.headerView.pullingState == .triggered {
                self.contentInset = UIEdgeInsetsMake(FTPullToRefreshHeaderViewHeight + 64, 0, 0, 0)
                self.setContentOffset(CGPoint(x: 0, y: -(FTPullToRefreshHeaderViewHeight + 64)), animated: true)
                self.headerView.startRefreshing()
            }
        default:
            break
        }
        

    }
    
    
    
}
