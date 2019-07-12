//
//  ConnectOtherViewMove.swift
//  DemoSignature
//
//  Created by Thinkpower on 2019/7/12.
//  Copyright © 2019 Thinkpower. All rights reserved.
//

import UIKit

protocol MoveTogetherDelegate: class {
    /// implement this need move together view when scroll to bottom.
    func onDirectScrollToBottom(_ moveScale: CGFloat, and moveSoming: MoveType)
    /// implement this need move together view when scroll to top.
    func onDirectScrollToTop(_ moveScale: CGFloat, and moveSoming: MoveType)
}

enum MoveType {
    case text(String)
    case any(Any?)
}

class MoveTogether {

    static let instance: MoveTogether = MoveTogether()
    
    private var scrollViewPreviousOffsetY: CGFloat = .zero
    
    weak var delegate: MoveTogetherDelegate?
    
    /** when target moving will move someone together move by the delegate function of ConnectMoveDelegate.
     
    - Parameter target: moving view
    - Parameter parent: moving view's parent view.
    - Parameter scrollView: movinh on which scrollView
    - Parameter actualHeight: if given value for actual height that calculate with it for move scale
                                or nil default will use target's height.
    - Parameter moveValue: which data need to pass that will back from delegate functions.
    */
    func whenScrolling(target: UIView,
                       parent: UIView,
                       scrolling scrollView: UIScrollView,
                       targetActualHeight actualHeight: CGFloat? = nil,
                       needPassValue moveValue: MoveType) {
        
        // need params: target, targetparent, scrollview, target's actual height,
        let targetHeight: CGFloat = target.frame.height
 
        let targetPosY: CGFloat = target.center.y // the center point is from its parent cell.
        var halfHeightOfTarget: CGFloat = targetHeight * 0.5
        if let actualTargetHeight = actualHeight {
            halfHeightOfTarget = actualTargetHeight * 0.5
        }
        
        let yRemainderOfTarget: CGFloat = scrollView.contentOffset.y.truncatingRemainder(dividingBy: parent.frame.height)
        
        // here is the target on center with its superview example.
        let yOfTargetsTop: CGFloat = targetPosY - halfHeightOfTarget
        let yOfTargetsBottom: CGFloat = targetPosY + halfHeightOfTarget
        
        let limitHeight: CGFloat = yOfTargetsBottom - yOfTargetsTop
        let moving: CGFloat = yOfTargetsBottom - yRemainderOfTarget
        let scale: CGFloat = 1 - moving / limitHeight
        
        if scrollViewPreviousOffsetY < scrollView.contentOffset.y { // scroll to bottom.
            delegate?.onDirectScrollToBottom((scale < 1) ? scale : 1, and: moveValue)
            
        } else {
            // scale < 1: target moving, scale >= 1: target leave from current display
            delegate?.onDirectScrollToTop(scale < 1 ? scale : 1, and: moveValue)
            
        }
        
        scrollViewPreviousOffsetY = scrollView.contentOffset.y
    }
    
}
