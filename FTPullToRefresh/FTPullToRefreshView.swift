//
//  FTPullToRefreshView.swift
//  FTPullToRefreshDemo
//
//  Created by liufengting https://github.com/liufengting on 16/8/11.
//  Copyright © 2016年 liufengting. All rights reserved.
//

import UIKit

enum FTPullingState {
    case None
    case Pulling
    case Triggered
    case Loading
    case Success
    case Failed
}

class FTPullToRefreshView: UIView {

    
    internal var pullingPercentage : CGFloat = CGFloat.NaN {
        didSet{
            self.setNeedsDisplay()
        }
    }
    
    internal var pullingState : FTPullingState = .None {
        didSet {
            if pullingState != oldValue {
                self.setNeedsDisplay()
             }
        }
    }
    
    var levelHeight : CGFloat = 10
    
    
    
    override func drawRect(rect: CGRect) {
        super.drawRect(rect)
        
        switch self.pullingState {
        case .Pulling:
            
            
            if  pullingPercentage < 1 {
                print(pullingPercentage)
                
                let roundCenter = self.getRoundCenter(pullingPercentage)
                let roundRadius = self.getRoundRadius(pullingPercentage)
                let roundAngle = self.getRoundAngle(pullingPercentage)
//                let roundAngle = self.getRoundAngle(pullingPercentage)

                let centerX : CGFloat = self.bounds.width/2;
                let bottomY : CGFloat = self.bounds.height;
 
                let roundMarginX = roundRadius*sin(roundRadius)
                let roundMarginY = roundRadius*cos(roundRadius)
 
                
                let ctx = UIGraphicsGetCurrentContext()
                CGContextSetFillColorWithColor(ctx, UIColor.redColor().CGColor)

                CGContextMoveToPoint(ctx, centerX - 60, bottomY)
                

                CGContextAddLineToPoint(ctx, centerX - roundMarginX, bottomY - roundMarginY)
                CGContextAddLineToPoint(ctx, centerX + roundMarginX, bottomY - roundMarginY)
 
                CGContextAddLineToPoint(ctx, centerX + 60, bottomY)
                CGContextClosePath(ctx)
                CGContextFillPath(ctx)
                
                
                
                
                
                
            }else{
                
                print("nothing")
            }


        default: break
            
        }


    }
    
    func getRoundCenter(pullPercent: CGFloat) -> CGPoint {
        if pullPercent <= 0.1 {
            return CGPointMake(self.bounds.width/2, self.bounds.height + self.levelHeight * pullPercent * 10)
        }
        return CGPointZero
    }
    
    func getRoundRadius(pullPercent: CGFloat) -> CGFloat {
        if pullPercent <= 0.1 {
            return 20
        }
        return 20
    }
    func getRoundAngle(pullPercent: CGFloat) -> CGFloat {
        if pullPercent <= 0.1 {
            return 120
        }
        return 120
    }
    func getConvertPoint(pullPercent: CGFloat) -> CGPoint {
        return CGPointZero
    }
    func getRoundMargin(pullPercent: CGFloat) -> CGFloat {
        return 0
    }
    func getLeftRoundPoint(pullPercent: CGFloat) -> CGPoint {
        return CGPointZero
    }
    func getRightRoundPoint(pullPercent: CGFloat) -> CGPoint {
        return CGPointZero
    }
    
    
    
}
