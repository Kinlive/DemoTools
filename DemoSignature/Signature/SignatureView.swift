//
//  SignatureView.swift
//  DemoSignature
//
//  Created by Thinkpower on 2019/7/8.
//  Copyright © 2019 Thinkpower. All rights reserved.
//

import UIKit


let topToSigningLineRatio: CGFloat = 0.6

// MARK: - Signature gesture recognizer.
protocol SignatureGestureRecognizerDelegate: class {
    func gestureTouchesBegan(_ touches: Set<UITouch>, withEvent event: UIEvent)
    func gestureTouchesMoved(_ touches: Set<UITouch>, withEvent event: UIEvent)
    func gestureTouchesEnded(_ touches: Set<UITouch>, withEvent event: UIEvent)

}

class SignatureGestureRecognizer: UIGestureRecognizer {
    weak var eventDelgate: SignatureGestureRecognizerDelegate?
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent) {
        if touches.count > 1 || numberOfTouches > 1 {
            for touch in touches {
                ignore(touch, for: event)
            }
        } else {
            state = .began
            eventDelgate?.gestureTouchesBegan(touches, withEvent: event)
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent) {
        eventDelgate?.gestureTouchesMoved(touches, withEvent: event)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent) {
        state = .ended
        eventDelgate?.gestureTouchesEnded(touches, withEvent: event)
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent) {
        state = .failed
    }
    
    override func shouldBeRequiredToFail(by otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        if otherGestureRecognizer.isKind(of: UIPanGestureRecognizer.self) || otherGestureRecognizer.isKind(of: UISwipeGestureRecognizer.self) {
            return true
        }
        
        return false
    }
    
}

let pointMinDistance: CGFloat = 5
var pointMinDistanceSquared: CGFloat {
    return pointMinDistance * pointMinDistance
}
let defaultLineWidth: CGFloat = 1
let defaultLineWidthVariation: CGFloat = 3
let maxPressureForStrokeVelocity: CGFloat = 9
let lineWidthStepValue: CGFloat = 0.25

// MARK: - Signature view
protocol SignatureViewDelegate: class {
    func signatureViewDidEditImage(_ signatureView: SignatureView)
    func whenSigning(on rect: CGRect)
}

class SignatureView: UIView {
    
    // public properties.
    var lineColor: UIColor = .darkGray
    var lineWidth: CGFloat = 1
    var lineWidthVariation: CGFloat = 1
    let placeholderPoint: CGPoint = .zero
    
    weak var delegate: SignatureViewDelegate?
    var signatureGestureRecgnizer: SignatureGestureRecognizer!
    var signaturePath: [UIBezierPath] = []
    
    var signatureExists: Bool {
        return paths.count > 0
    }
    var isStopDraw: Bool = false

    // private properties
    private var currentPoint: CGPoint = .zero
    private var previousPoint1: CGPoint = .zero
    private var previousPoint2: CGPoint = .zero
    // Pressure scale based on if using force or speed of stroke.
    private var minPressure: CGFloat = .zero
    private var maxPressure: CGFloat = .zero
    // Time used only to calculate speed when force isn't available on the device.
    private var previousTouchTime: TimeInterval = .zero
    
    private var currentPath: UIBezierPath?
    private var paths: [UIBezierPath] = []
    private var backgroundLines: [UIBezierPath] {
        
        let width = bounds.width
        let height = bounds.height
        
        let path = UIBezierPath()
        path.move(to: CGPoint(x: 0, y: height * topToSigningLineRatio))
        path.addLine(to: CGPoint(x: width, y: height * topToSigningLineRatio))
        
        return [path]
        
    }
    
    private var pathWithRoundedStyle: UIBezierPath {
        let path = UIBezierPath()
        path.lineCapStyle = .round
        path.lineWidth = lineWidth
        path.lineJoinStyle = .round
        
        return path
    }
    
    // Self layout constraints. unuse
    var heightConstraint: NSLayoutConstraint!
    var widthConstraint: NSLayoutConstraint!
    
    // some is
    private var isForceTouchAvailable: Bool {
        var available = false
        if self.traitCollection.responds(to: #selector(getter: UITraitCollection.forceTouchCapability)) && self.traitCollection.forceTouchCapability == .available {
            available = true
        }
        return available
    }
    
    // initialize
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        configure()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func updateConstraints() {
        super.updateConstraints()
    }
    
    override func draw(_ rect: CGRect) {
        UIColor.clear.setFill()
        guard let context = UIGraphicsGetCurrentContext(), !isStopDraw else { return }
        
        context.fill(rect)
    
        for path in paths {
            lineColor.setStroke()
            path.stroke()
        }
        
        lineColor.setStroke()
        currentPath?.stroke()
    }
    
    
    // private functions ===============================================================================
    private func configure() {
        lineWidth = defaultLineWidth
        lineWidthVariation = defaultLineWidthVariation
        makeSignatureGestureRecognizer()
        backgroundColor = UIColor.gray.withAlphaComponent(0.3)
        isUserInteractionEnabled = true
        
//        setupConstraints()
        
    }
    
    private func makeSignatureGestureRecognizer() {
        guard signatureGestureRecgnizer == nil else { return }
        signatureGestureRecgnizer = SignatureGestureRecognizer()
        signatureGestureRecgnizer.eventDelgate = self
        addGestureRecognizer(signatureGestureRecgnizer)
    }
    
    private func setupConstraints() {
        heightConstraint = NSLayoutConstraint(item: self, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 0)
        widthConstraint = NSLayoutConstraint(item: self, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 0)
        
        NSLayoutConstraint.activate([heightConstraint, widthConstraint])
    }
    
    private func isTouchTypesStylus(_ touch: UITouch) -> Bool {
        return touch.type == .stylus
    }
    
    private func commitCurrentPath() {
        guard let currentPath = currentPath, !currentPath.bounds.equalTo(.zero), !isStopDraw else { return }
        paths.append(currentPath)
        
        delegate?.signatureViewDidEditImage(self)

    }
    
    // public functions ===============================================================================
    func signatureImage() -> UIImage? {
        let imageContextSize: CGSize = bounds.width == 0 || bounds.height == 0 ? CGSize(width: 200, height: 200) : bounds.size
        
        UIGraphicsBeginImageContext(imageContextSize)
        for path in paths {
            lineColor.setStroke()
            path.stroke()
        }
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return image
    }
    
    func clear() {
        if paths.isEmpty {
           return
        }
        
        if currentPath != nil {
            currentPath = pathWithRoundedStyle
        }
        
        paths.removeAll()
        
        setNeedsDisplay(bounds)
    }
    
    
}

/*
extension SignatureView: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if (touch.view?.isKind(of: SignatureView.self))! {
            return true
        }
        return false
    }
 
    // ============= OR ===============
    return touch.view == gestureRecognizer.view
}
*/

// MARK: - SignatureGestureRecognizer Delegate
extension SignatureView: SignatureGestureRecognizerDelegate {
    func gestureTouchesBegan(_ touches: Set<UITouch>, withEvent event: UIEvent) {
        
        guard let touch = touches.first else { return }
        
        currentPath = pathWithRoundedStyle
        // Trigger full redraw - whether there's a path has changed
        setNeedsDisplay()
        
        previousPoint1 = touch.previousLocation(in: self)
        previousPoint2 = touch.previousLocation(in: self)
        currentPoint = touch.location(in: self)
        
        if isForceTouchAvailable || isTouchTypesStylus(touch) {
             // This is a scale based on true force on the screen.
            minPressure = .zero
            maxPressure = touch.maximumPossibleForce * 0.5
        } else {
            // This is a scale based on the speed of the stroke
            // (scaled down logarithmically).
            minPressure = .zero
            maxPressure = maxPressureForStrokeVelocity
            previousTouchTime = touch.timestamp
        }
        
        currentPath?.move(to: currentPoint)
        currentPath?.addArc(withCenter: currentPoint, radius: 0.1, startAngle: 0.0, endAngle: 2.0 * .pi, clockwise: true)
        
        gestureTouchesMoved(touches, withEvent: event)

    }
    
    func gestureTouchesMoved(_ touches: Set<UITouch>, withEvent event: UIEvent) {
        guard let touch = touches.first else { return }
        let point = touch.location(in: self)
        
        //check if the point is farther than min dist from previous
        let dx = point.x - currentPoint.x
        let dy = point.y - currentPoint.y
        
        let distanceSquared = dx * dx + dy * dy
        
        guard distanceSquared >= pointMinDistanceSquared else { return }
        
        // Default to the minimum. Will be assigned a real
        // value on all devices.
        
        var pressure = minPressure
        if isForceTouchAvailable || isTouchTypesStylus(touch) {
            pressure = touch.force
        } else {
            // If not, use a heuristic based on the speed of
            // the stroke. Scale this speed logarithmically to
            // require very slow touches to max out the line width.
            
            // This value can become negative because of how it is
            // inverted. It will be clamped right below.
            pressure = maxPressure - CGFloat(logf((Float(sqrt(distanceSquared) / CGFloat(max(0.0001, event.timestamp - previousTouchTime))))))
            
            previousTouchTime = event.timestamp
            
        }
        
        pressure = max(minPressure, pressure)
        pressure = min(maxPressure, pressure)
        
        let previousLineWidth = currentPath?.lineWidth ?? 0
        let proposedLineWidth = ((pressure - minPressure) * lineWidthVariation / (maxPressure - minPressure)) + lineWidth
        
        // Only step the line width up and down by a set value.
        // This prevents the line looking jagged, and adding excessive
        // separate line segments.
        
        if abs(previousLineWidth - proposedLineWidth) >= lineWidthStepValue {
            var lineWidth = previousLineWidth
            
            if proposedLineWidth > previousLineWidth {
                lineWidth = previousLineWidth + lineWidthStepValue
                
            } else if proposedLineWidth < previousLineWidth {
                lineWidth = previousLineWidth - lineWidthStepValue
            }
            
            commitCurrentPath()
            currentPath = pathWithRoundedStyle
            currentPath?.lineWidth = lineWidth
            
            let previousMid2 = CGPoint.mmid_Point(currentPoint, previousPoint1)
            currentPath?.move(to: previousMid2)
        }
        
        previousPoint2 = previousPoint1
        previousPoint1 = touch.previousLocation(in: self)
        currentPoint = touch.location(in: self)
        
        let mid1 = CGPoint.mmid_Point(previousPoint1, previousPoint2)
        let mid2 = CGPoint.mmid_Point(currentPoint, previousPoint1)
        
        let subPath = UIBezierPath()
        subPath.move(to: mid1)
        subPath.addQuadCurve(to: mid2, controlPoint: previousPoint1)
        
        let bounds = subPath.cgPath.boundingBox
        
        currentPath?.addQuadCurve(to: mid2, controlPoint: previousPoint1)
        
        var drawBox = bounds
        drawBox.origin.x -= currentPath?.lineWidth ?? 0 * 2.0
        drawBox.origin.y -= currentPath?.lineWidth ?? 0 * 2.0
        drawBox.size.width += currentPath?.lineWidth ?? 0 * 4.0
        drawBox.size.height += currentPath?.lineWidth ?? 0 * 4.0
        
        setNeedsDisplay(drawBox)
        delegate?.whenSigning(on: drawBox)
    }
    
    func gestureTouchesEnded(_ touches: Set<UITouch>, withEvent event: UIEvent) {
        commitCurrentPath()
        setNeedsDisplay()
    }
    
    
}


// MARK: - CGPoint extensions
extension CGPoint {
    static func mmid_Point(_ lhs: CGPoint, _ rhs: CGPoint) -> CGPoint {
        return CGPoint(x: (lhs.x + rhs.x) * 0.5, y: (lhs.y + rhs.y) * 0.5)
    }
}
