//
//  FTPullToRefreshView.swift
//  FTPullToRefreshDemo
//
//  Created by liufengting https://github.com/liufengting on 16/8/11.
//  Copyright © 2016年 liufengting. All rights reserved.
//

import UIKit

public enum FTPullingState {
    case none
    case pulling
    case triggered
    case refreshing
    case succeed
    case failed
}

public enum FTPullToRefreshViewPosition {
    case top
    case bottom
}


public class FTPullToRefreshView: UIView {

    public var originalContentInset: UIEdgeInsets = UIEdgeInsets.zero
    public var topRefreshingBlock: (()->())? = nil
    public var bottomRefreshingBlock: (()->())? = nil
    
    public var position : FTPullToRefreshViewPosition = .top
    
    public var pullingPercentage : CGFloat = CGFloat.nan {
        didSet{
            if pullingPercentage == 0 {
                self.pullingState = .none
            }else if abs(pullingPercentage) >= 1 {
                self.pullingState = .triggered
            }else{
                self.pullingState = .pulling
            }
            self.updateStateLabel()
        }
    }
    
    public var pullingState : FTPullingState = .none {
        didSet {
            self.updateStateLabel()
        }
    }
    
    public func startRefreshing() {
        self.pullingState = .refreshing
        
        if self.position == .top {
            self.topRefreshingBlock?()
        }else{
            self.bottomRefreshingBlock?()
        }
    }
    
    public func stopRefreshing(){
        
        self.pullingState = .succeed
    }

    lazy var displayLabel: UILabel = {
        let label : UILabel = UILabel(frame: self.bounds)
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 15)
        self.addSubview(label)
        return label
    }()
    
    
    
    func updateStateLabel() {
        switch self.pullingState {
        case .pulling:
            self.displayLabel.text = "\(Int(abs(pullingPercentage*100)))%"
        case .triggered:
            self.displayLabel.text = "可以松手了。。"
        case .refreshing:
            self.displayLabel.text = "正在刷新。。"
        case .succeed:
            self.displayLabel.text = "刷新成功！！"
        case .failed:
            self.displayLabel.text = "刷新失败！！"
        default:
            self.displayLabel.text = ""
        }
    }
    
    
    
}
