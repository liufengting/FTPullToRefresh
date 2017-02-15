//
//  FTPullToRefresh.swift
//  FTPullToRefreshDemo
//
//  Created by liufengting https://github.com/liufengting on 16/8/11.
//  Copyright © 2016年 liufengting. All rights reserved.
//

import UIKit
import ObjectiveC

private let FTPullToRefreshHeaderViewHeight : CGFloat = 60

private let FTPullToRefreshKeyPathContentOffset = "contentOffset"
private let FTPullToRefreshKeyPathContentSize = "contentSize"
private let FTPullToRefreshKeyPathPanGestureState = "state"

extension UIScrollView {

    private struct AssociatedKeys {
        static var headerViewAssociateKey = "FTPullToRefreshHeaderViewAssociateKey"
        static var footerViewAssociateKey = "FTPullToRefreshFooterViewAssociateKey"
    }
    
    var headerView : FTPullToRefreshView? {
        get {
            return objc_getAssociatedObject(self, &AssociatedKeys.headerViewAssociateKey) as? FTPullToRefreshView
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.headerViewAssociateKey, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN)
        }
    }
    
    var footerView : FTPullToRefreshView? {
        get {
            return objc_getAssociatedObject(self, &AssociatedKeys.footerViewAssociateKey) as? FTPullToRefreshView
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.footerViewAssociateKey, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN)
        }
    }
 
    public func addPullRefreshHeaderWithRefreshBlock(_ refreshingBlock: @escaping (()->())) {
        self.addObservers()
        
        self.headerView = FTPullToRefreshView(frame : CGRect(x: 0, y: self.contentOffset.y - FTPullToRefreshHeaderViewHeight, width: self.bounds.size.width, height: FTPullToRefreshHeaderViewHeight))
        self.headerView?.refreshingBlock = refreshingBlock
        self.addSubview(self.headerView!)
    }

    public func addPullRefreshFooterWithRefreshBlock(_ refreshingBlock: @escaping (()->())) {
        self.addObservers()

        self.footerView = FTPullToRefreshView(frame : CGRect(x: 0, y: self.contentSize.height, width: self.bounds.size.width, height: FTPullToRefreshHeaderViewHeight))
        self.footerView?.backgroundColor = UIColor.red
        self.footerView?.refreshingBlock = refreshingBlock
        self.addSubview(self.footerView!)
    }
    
    func addObservers() {
        DispatchQueue.once(token: "com.ftpullrefresh.createonce") {
            self.addObserver(self, forKeyPath: FTPullToRefreshKeyPathContentOffset, options: .new, context: nil)
            self.addObserver(self, forKeyPath: FTPullToRefreshKeyPathContentSize, options: .new, context: nil)
            self.panGestureRecognizer.addObserver(self, forKeyPath: FTPullToRefreshKeyPathPanGestureState, options: .new, context: nil)
        }
    }
    
    func removeObservers() {
        DispatchQueue.once(token: "com.ftpullrefresh.removeonce") {
            self.removeObserver(self, forKeyPath: FTPullToRefreshKeyPathContentOffset)
            self.removeObserver(self, forKeyPath: FTPullToRefreshKeyPathContentSize)
            self.panGestureRecognizer.removeObserver(self, forKeyPath: FTPullToRefreshKeyPathPanGestureState)
        }
    }

    public func stopRefreshing(){
        if self.headerView?.pullingState == .refreshing {
            self.headerView?.stopRefreshing()
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(Int64(1.0 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC), execute: {
                self.contentInset.top = 64
                self.setContentOffset(CGPoint(x: 0, y: -64), animated: true)
            })
        }
        if self.footerView?.pullingState == .refreshing {
            self.footerView?.stopRefreshing()
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(Int64(1.0 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC), execute: {
                self.contentInset.bottom = 0
                self.setContentOffset(CGPoint(x: 0, y: self.contentSize.height - self.bounds.size.height), animated: true)
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
                self.scrollViewDidChangePanGestureState(UIGestureRecognizerState(rawValue: newValue)!)
            }
        }else if keyPath == FTPullToRefreshKeyPathContentSize {
            self.footerView?.frame = CGRect(x: 0, y: self.contentSize.height, width: self.bounds.size.width, height: FTPullToRefreshHeaderViewHeight)
        }
    }
    
    func scrollViewDidScrollWithContentOffset(_ contentOffset: CGPoint) {

        if contentOffset.y < -self.contentInset.top {
            if self.isDragging {
                self.headerView?.pullingPercentage = CGFloat(fabsf(Float((self.contentInset.top + contentOffset.y)/FTPullToRefreshHeaderViewHeight)))
            }
        }
        
        if contentOffset.y > self.contentSize.height - self.bounds.size.height {
            self.footerView?.pullingPercentage = CGFloat(fabsf(Float((contentOffset.y - (self.contentSize.height - self.bounds.size.height))/FTPullToRefreshHeaderViewHeight)))
        }
    }
    
    func scrollViewDidChangePanGestureState(_ state: UIGestureRecognizerState) {
        
        switch state {
        case .ended:
            if self.headerView?.pullingState == .triggered {
                self.contentInset.top = FTPullToRefreshHeaderViewHeight + 64
                self.setContentOffset(CGPoint(x: 0, y: -(FTPullToRefreshHeaderViewHeight + 64)), animated: true)
                self.headerView?.startRefreshing()
            }
            if self.footerView?.pullingState == .triggered {
                self.contentInset.bottom = FTPullToRefreshHeaderViewHeight
                self.setContentOffset(CGPoint(x: 0, y: self.contentSize.height - self.bounds.size.height + FTPullToRefreshHeaderViewHeight), animated: true)
                self.footerView?.startRefreshing()
            }
            
        default:
            break
        }
    }
}


public extension DispatchQueue {
    
    private static var _onceTracker = [String]()
    
    /**
     Executes a block of code, associated with a unique token, only once.  The code is thread safe and will
     only execute the code once even in the presence of multithreaded calls.
     
     - parameter token: A unique reverse DNS style name such as com.vectorform.<name> or a GUID
     - parameter block: Block to execute once
     */
    public class func once(token: String, block: (Void)->Void) {
        objc_sync_enter(self); defer { objc_sync_exit(self) }
        if _onceTracker.contains(token) {
            return
        }
        _onceTracker.append(token)
        block()
    }
}
