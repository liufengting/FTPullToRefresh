//
//  FTPullToRefresh.swift
//  FTPullToRefreshDemo
//
//  Created by liufengting https://github.com/liufengting on 16/8/11.
//  Copyright © 2016年 liufengting. All rights reserved.
//

import UIKit
import ObjectiveC

private let FTPullToRefreshViewHeight : CGFloat = 60

private let FTPullToRefreshKeyPathContentOffset = "contentOffset"
private let FTPullToRefreshKeyPathContentSize = "contentSize"
private let FTPullToRefreshKeyPathPanGestureState = "state"

extension UIScrollView {

    private struct AssociatedKeys {
        static var refreshViewAssociateKey = "FTPullToRefreshRefreshViewAssociateKey"
    }
    
    var refreshView : FTPullToRefreshView? {
        get {
            return objc_getAssociatedObject(self, &AssociatedKeys.refreshViewAssociateKey) as? FTPullToRefreshView
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.refreshViewAssociateKey, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN)
        }
    }

    public func addPullRefreshHeaderWithRefreshBlock(_ refreshingBlock: @escaping (()->())) {
        self.addObservers()
        
        self.createRefreshViewIfNeeded()

        self.refreshView?.topRefreshingBlock = refreshingBlock
 
    }

    public func addPullRefreshFooterWithRefreshBlock(_ refreshingBlock: @escaping (()->())) {
        self.addObservers()

        self.createRefreshViewIfNeeded()

        self.refreshView?.bottomRefreshingBlock = refreshingBlock

    }
    
    open override func willMove(toSuperview newSuperview: UIView?) {
        super.willMove(toSuperview: newSuperview)

        self.refreshView?.originalContentInset = self.contentInset
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
    
    
    func createRefreshViewIfNeeded() {
        if self.refreshView == nil {
            self.refreshView = FTPullToRefreshView(frame : CGRect(x: 0, y: self.contentOffset.y - FTPullToRefreshViewHeight, width: self.bounds.size.width, height: FTPullToRefreshViewHeight))
            self.addSubview(self.refreshView!)
        }
    }
    

    public func stopRefreshing(){
        if self.refreshView?.pullingState == .refreshing {
            if self.refreshView?.position == .top {
                self.contentInset.top = (self.refreshView?.originalContentInset.top)!
                self.setContentOffset(CGPoint(x: 0, y: -(self.refreshView?.originalContentInset.top)!), animated: true)
            }else{
                if self.contentSize.height > self.bounds.size.height {
                    self.contentInset.bottom = 0
                    self.setContentOffset(CGPoint(x: 0, y: self.contentSize.height - self.bounds.size.height), animated: true)
                }
            }
            self.refreshView?.stopRefreshing()
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
                self.repositionRefreshView()
        }
    }
    
    func scrollViewDidScrollWithContentOffset(_ contentOffset: CGPoint) {
        
        if self.refreshView?.pullingState == .refreshing {
            return
        }
        
        print(self.contentInset)
        
        if !self.isDragging {
            self.refreshView?.originalContentInset = self.contentInset
        }
        
        var pullingPercentage : CGFloat = 0
        if contentOffset.y < 0 - (self.refreshView?.originalContentInset.top)! {
            if contentOffset.y < -self.contentInset.top {
                pullingPercentage = CGFloat(fabsf(Float((self.contentInset.top + contentOffset.y)/FTPullToRefreshViewHeight)))
                self.prepareRefreshView(.top, percentage: pullingPercentage)
            }
        }else if self.contentSize.height > self.bounds.size.height {
            if contentOffset.y > self.contentSize.height - self.bounds.size.height {
                pullingPercentage = CGFloat(fabsf(Float((contentOffset.y - (self.contentSize.height - self.bounds.size.height))/FTPullToRefreshViewHeight)))
                self.prepareRefreshView(.bottom, percentage: pullingPercentage)
            }
        }else if self.contentSize.height < self.bounds.size.height {
            if contentOffset.y > self.contentSize.height - self.bounds.size.height {
                pullingPercentage = CGFloat(fabsf(Float(((self.refreshView?.originalContentInset.top)! + contentOffset.y)/FTPullToRefreshViewHeight)))
                self.prepareRefreshView(.bottom, percentage: pullingPercentage)
            }
        }
    }

    func prepareRefreshView(_ position: FTPullToRefreshViewPosition, percentage: CGFloat) {
        if self.refreshView?.position != position {
            self.refreshView?.position = position
            self.repositionRefreshView()
        }
        self.refreshView?.pullingPercentage = percentage
    }
    
    
    
    func scrollViewDidChangePanGestureState(_ state: UIGestureRecognizerState) {
        
        switch state {
        case .ended:
            if self.refreshView?.position == .top {
                if self.refreshView?.pullingState == .triggered {
                    self.contentInset.top = FTPullToRefreshViewHeight + (self.refreshView?.originalContentInset.top)!
                    self.setContentOffset(CGPoint(x: 0, y: -(FTPullToRefreshViewHeight + (self.refreshView?.originalContentInset.top)!)), animated: true)
                    self.refreshView?.startRefreshing()
                }
            }else{
                if self.refreshView?.pullingState == .triggered {
                    if self.contentSize.height > self.bounds.size.height {
                        self.contentInset.bottom = FTPullToRefreshViewHeight
                        self.setContentOffset(CGPoint(x: 0, y: self.contentSize.height - self.bounds.size.height + FTPullToRefreshViewHeight), animated: true)
                        self.refreshView?.startRefreshing()
                    }else{
                        self.refreshView?.startRefreshing()
                    }
                }
            }
        default:
            break
        }
    }
    
    func repositionRefreshView() {
        if self.refreshView?.position == .top {
            self.refreshView?.frame = CGRect(x: 0, y: 0 - FTPullToRefreshViewHeight, width: self.bounds.size.width, height: FTPullToRefreshViewHeight)
        }else{
            self.refreshView?.frame = CGRect(x: 0, y: self.contentSize.height, width: self.bounds.size.width, height: FTPullToRefreshViewHeight)
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
