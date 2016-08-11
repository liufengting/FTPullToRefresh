//
//  FTPullToRefreshView.swift
//  FTPullToRefreshDemo
//
//  Created by liufengting on 16/8/11.
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

    
    var pullingPercentage : Float = 0
    
    
    
    var pullingState : FTPullingState = .None {
        didSet {
            self.setNeedsDisplay()
        }

    }
    
    
    
    override func drawRect(rect: CGRect) {
        super.drawRect(rect)
        
        switch self.pullingState {
        case .Pulling:
            
            print(pullingPercentage)
            
            let originY = self.bounds.height*CGFloat(1 - pullingPercentage)
            let centerX = self.bounds.width/2


            print(originY)
            print("ss")
 
            
            let ctx = UIGraphicsGetCurrentContext()
            CGContextSetFillColorWithColor(ctx, UIColor.redColor().CGColor)
//            CGContextSetLineWidth(ctx, 0.75)
            CGContextMoveToPoint(ctx, centerX - 60, originY)
            CGContextAddQuadCurveToPoint(ctx, centerX, self.bounds.height, centerX + 60, originY)
            CGContextClosePath(ctx)
            CGContextFillPath(ctx)
        default: break
            
        }
//        let ctx = UIGraphicsGetCurrentContext()
//        CGContextSetFillColorWithColor(ctx, UIColor.redColor().CGColor)
//        CGContextSetLineWidth(ctx, 0.75)
//        CGContextMoveToPoint(ctx, 60, 0)
//        CGContextAddQuadCurveToPoint(ctx, 130, self.bounds.height, 200, 0)
//        CGContextClosePath(ctx)
//        CGContextFillPath(ctx)

    }
    
    
}
