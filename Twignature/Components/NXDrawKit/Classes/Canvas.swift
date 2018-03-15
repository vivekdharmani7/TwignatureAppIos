//
//  Canvas.swift
//  NXDrawKit
//
//  Created by Nicejinux on 7/14/16.
//  Copyright © 2016 Nicejinux. All rights reserved.
//

import UIKit
import AVFoundation

@objc public protocol CanvasDelegate
{
    @objc optional func canvas(_ canvas: Canvas, didUpdateDrawing drawing: Drawing, mergedImage image: UIImage?)
    @objc optional func canvas(_ canvas: Canvas, didSaveDrawing drawing: Drawing, mergedImage image: UIImage?)
    
    func brush(forTouch touch: UITouch?) -> Brush?
}


open class Canvas: UIView, UITableViewDelegate
{
    @objc open weak var delegate: CanvasDelegate?
    
    fileprivate var canvasId: String?
    
    fileprivate var mainImageView = UIImageView()
    fileprivate var tempImageView = UIImageView()
    fileprivate(set) var backgroundImageView = UIImageView()
    
    fileprivate var brush = Brush()
    fileprivate let session = DrawSession()
    fileprivate var drawing = Drawing()
    fileprivate let path = UIBezierPath()
    fileprivate let scale = UIScreen.main.scale

    fileprivate var saved = false
    fileprivate var pointMoved = false
    fileprivate var pointIndex = 0
    fileprivate var points = [CGPoint?](repeating: CGPoint.zero, count: 5)

    private let tiltThreshold = CGFloat.pi/6  // 30º
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    @objc public init(canvasId: String? = nil, backgroundImage image: UIImage? = nil) {
        super.init(frame: CGRect.zero)
        self.path.lineCapStyle = .round
        self.canvasId = canvasId
        self.backgroundImageView.image = image
        self.mainImageView.contentMode = .scaleAspectFit
        if image != nil {
            session.appendBackground(Drawing(stroke: nil, background: image))
        }
        self.initialize()
    }
    
    // MARK: - Private Methods
    fileprivate func initialize() {
        self.backgroundColor = UIColor.white
        
        self.addSubview(self.backgroundImageView)
        self.backgroundImageView.contentMode = .scaleAspectFill
        self.backgroundImageView.autoresizingMask = [.flexibleHeight ,.flexibleWidth]
        
        self.addSubview(self.mainImageView)
        self.mainImageView.autoresizingMask = [.flexibleHeight ,.flexibleWidth]

        self.addSubview(self.tempImageView)
        self.tempImageView.autoresizingMask = [.flexibleHeight ,.flexibleWidth]
    }
    
    fileprivate func compare(_ image1: UIImage?, isEqualTo image2: UIImage?) -> Bool {
        if (image1 == nil && image2 == nil) {
            return true
        } else if (image1 == nil || image2 == nil) {
            return false
        }
        
        let data1 = UIImagePNGRepresentation(image1!)
        let data2 = UIImagePNGRepresentation(image2!)

        if (data1 == nil || data2 == nil) {
            return false
        }

        return (data1! == data2)
    }
    
    fileprivate func currentDrawing() -> Drawing {
        return Drawing(stroke: self.mainImageView.image, background: self.backgroundImageView.image)
    }
    
    fileprivate func updateByLastSession() {
        let lastSession = self.session.lastSession()
        self.mainImageView.image = lastSession?.stroke
        self.backgroundImageView.image = lastSession?.background
    }
    
    fileprivate func didUpdateCanvas() {
        let mergedImage = self.mergePathsAndImages()
        let currentDrawing = self.currentDrawing()
        self.delegate?.canvas?(self, didUpdateDrawing: currentDrawing, mergedImage: mergedImage)
    }
    
    fileprivate func didSaveCanvas() {
        let mergedImage = self.mergePathsAndImages()
        self.delegate?.canvas?(self, didSaveDrawing: self.drawing, mergedImage: mergedImage)
    }
    
    fileprivate func isStrokeEqual() -> Bool {
        return self.compare(self.drawing.stroke, isEqualTo: self.mainImageView.image)
    }
    
    fileprivate func isBackgroundEqual() -> Bool {
        return self.compare(self.drawing.background, isEqualTo: self.backgroundImageView.image)
    }
    

    // MARK: - Override Methods
    open override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.saved = false
        self.pointMoved = false
        self.pointIndex = 0
        self.brush = (self.delegate?.brush(forTouch: touches.first))!
        
        let touch = touches.first!
        self.points[0] = touch.location(in: self)
    }
    
    open override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        /*
         * Smooth Freehand Drawing on iOS
         * http://code.tutsplus.com/tutorials/ios-sdk_freehand-drawing--mobile-13164
         *
         */

        guard let touch = touches.first else { return }

        // 1
        var touches = [UITouch]()

        // Coalesce Touches
        // 2
        if let coalescedTouches = event?.coalescedTouches(for: touch) {
            touches = coalescedTouches
        } else {
            touches.append(touch)
        }

        drawStroke(touches: touches)
        // 4
//        for touch in touches {
//            drawStroke(context: context, touch: touch)
//        }

        // 1
        //tempImageView.image = UIGraphicsGetImageFromCurrentImageContext()
        // 2
//        if let predictedTouches = event?.predictedTouches(for: touch) {
//            for touch in predictedTouches {
//                drawStroke(context: context, touch: touch)
//            }
//        }
    }
    
    open override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.touchesEnded(touches, with: event)
    }
    
    open override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
//        if !self.pointMoved {   // touchesBegan -> touchesEnded : just touched
//            self.path.move(to: self.points[0]!)
//            self.path.addLine(to: self.points[0]!)
//            self.strokePath()
//        }
		
       	self.mergePaths()      // merge all paths
        self.didUpdateCanvas()
//        self.path.removeAllPoints()
//        self.pointIndex = 0
    }

    private func drawStroke(touches: [UITouch]) {
       	guard let touch = touches.first else {
            return
        }


//        if touch.type == .stylus {
//            // Calculate line width for drawing stroke
//            if touch.altitudeAngle < tiltThreshold {
//                lineWidth = lineWidthForShading(context, touch: touch)
//            } else {
//                lineWidth = lineWidthForDrawing(context, touch: touch)
//            }
//            // Set color
//            pencilTexture.setStroke()
//        } else {
//            // Erase with finger
//            lineWidth = touch.majorRadius / 2
//            eraserColor.setStroke()
//        }

        // Configure line
		
//        CGContextSetLineWidth(requiredContext, lineWidth)
//        CGContextSetLineCap(requiredContext, .round)


        // Set up the points
        //requiredContext.move(to: previousLocation)
        //requiredContext.addLine(to: location)
		
		
		let currentPoint = touch.location(in: self)
		self.pointMoved = true
		self.pointIndex += 1
		self.points[self.pointIndex] = currentPoint
		guard self.pointIndex == bezierMaxIndex else {
			return
		}
		
		UIGraphicsBeginImageContextWithOptions(bounds.size, false, 0.0)
		guard let context = UIGraphicsGetCurrentContext() else {
			return
		}
		context.setBlendMode(.destinationAtop)
		// Draw previous image into context
		tempImageView.image?.draw(in: bounds)
		
		drawBezie(context: context, touch: touch)
		
		context.strokePath()
		
		// Update image
		tempImageView.image = UIGraphicsGetImageFromCurrentImageContext()
		UIGraphicsEndImageContext()
    }
	
	private let bezierMaxIndex = 4
	
	private func drawBezie(context: CGContext, touch: UITouch) {
		
		assert(self.pointIndex == bezierMaxIndex)
		
		guard let brush = self.delegate?.brush(forTouch: touch) else {
			return
		}
		
		
	
		let lineWidth: CGFloat
		if #available(iOS 9.1, *) {
			lineWidth = lineWidthForShading(context: context, touch: touch, brush: brush)
		} else {
			lineWidth = lineWidthForDrawing(context: context, touch: touch, brush: brush)
		}
		// Set color
		brush.color.setStroke()
		
		context.setLineWidth(lineWidth)
		context.setLineCap(.round)
		
		// move the endpoint to the middle of the line joining the second control point of the first Bezier segment
		// and the first control point of the second Bezier segment
		self.points[3] = CGPoint(x: (self.points[2]!.x + self.points[4]!.x)/2.0, y: (self.points[2]!.y + self.points[4]!.y) / 2.0)
		
		// add a cubic Bezier from pt[0] to pt[3], with control points pt[1] and pt[2]
		self.brush = (self.delegate?.brush(forTouch: touch))!
		context.move(to: self.points[0]!)
		context.addCurve(to: self.points[3]!, control1: self.points[1]!, control2: self.points[2]!)
		
		
		// replace points and get ready to handle the next segment
		self.points[0] = self.points[3]
		self.points[1] = self.points[4]
		self.pointIndex = 1
	}
	

    private func lineWidthForShading(context: CGContext, touch: UITouch, brush: Brush) -> CGFloat {

        // 1
        let previousLocation = touch.previousLocation(in: self)
        let location = touch.location(in: self)

        // 2 - vector1 is the pencil direction
//        var vector1: CGVector? = nil
//        if #available(iOS 9.1, *) {
//            vector1 = touch.azimuthUnitVector(in: self)
//        }
//
//        // 3 - vector2 is the stroke direction
//        let vector2 = CGPoint(x: location.x - previousLocation.x, y: location.y - previousLocation.y)
//
//        var angle: CGFloat?
//        if let vector1 = vector1 {
//            // 4 - Angle difference between the two vectors
//            var angle = abs(atan2(vector2.y, vector2.x) - atan2(vector1.dy, vector1.dx))
//        }
//
//        // 6
//        let minAngle: CGFloat = 0
//        let maxAngle = CGFloat.pi / 2
//        if let asomeAngle = angle {
//            // 5
//            if asomeAngle > CGFloat.pi {
//                angle = 2 * CGFloat.pi - asomeAngle
//            }
//            if asomeAngle > CGFloat.pi / 2 {
//                angle = CGFloat.pi - asomeAngle
//            }
//        } else {
//            angle = maxAngle
//        }
//
//
//
//        let normalizedAngle = (angle! - minAngle) / (maxAngle - minAngle)
//
//        // 7
        var lineWidth: CGFloat = 0
//
//        // 1 - modify lineWidth by altitude (tilt of the Pencil)
//        // 0.25 radians means widest stroke and TiltThreshold is where shading narrows to line.
//
//        if #available(iOS 9.1, *) {
//            let minAltitudeAngle: CGFloat = 0.25
//            let maxAltitudeAngle = tiltThreshold
//
//            // 2
//            let altitudeAngle = touch.altitudeAngle < minAltitudeAngle
//                    ? minAltitudeAngle : touch.altitudeAngle
//
//            // 3 - normalize between 0 and 1
//            let normalizedAltitude = 1 - ((altitudeAngle - minAltitudeAngle)
//                    / (maxAltitudeAngle - minAltitudeAngle))
//            // 4
//            lineWidth = lineWidth * normalizedAltitude + brush.minLineWidth
//        }

        // Set alpha of shading using force
        let minForce: CGFloat = brush.width
        let maxForce: CGFloat = brush.width * 2

        // Normalize between 0 and 1
//        var normalizedAlpha: CGFloat = 0.5
        if touch.force > 0 {
            lineWidth = (touch.force - minForce) / (maxForce - minForce)
        }

        if #available(iOS 9.1, *), brush.isWidthDynamic {
            lineWidth = (touch.altitudeAngle / (CGFloat.pi/2)) * brush.width
        } else {
            lineWidth = brush.width
        }

//        // Set alpha of shading using force
//        let minForce: CGFloat = 0.0
//        let maxForce: CGFloat = 5
//
//        // Normalize between 0 and 1
//        var normalizedAlpha: CGFloat = 1
//        if touch.force > 0 {
//            normalizedAlpha = (touch.force - minForce) / (maxForce - minForce)
//        }
//        context.setAlpha(normalizedAlpha)
////        CGContextSetAlpha(context, normalizedAlpha)

        return lineWidth
    }


    private func lineWidthForDrawing(context: CGContext, touch: UITouch, brush: Brush) -> CGFloat {

        var lineWidth = brush.defaultLineWidth

        if touch.force > 0 {  // If finger, touch.force = 0
            lineWidth = touch.force * brush.forceSensitivity
        }

        return lineWidth
    }

    
    fileprivate func mergePaths() {
        UIGraphicsBeginImageContextWithOptions(self.frame.size, false, 0)
        
        self.mainImageView.image?.draw(in: AVMakeRect(aspectRatio: self.mainImageView.image!.size, insideRect: self.bounds))
        self.tempImageView.image?.draw(in: self.bounds)
        
        self.mainImageView.image = UIGraphicsGetImageFromCurrentImageContext()
        self.session.append(self.currentDrawing())
        self.tempImageView.image = nil
        
        UIGraphicsEndImageContext()
    }
    
    fileprivate func mergePathsAndImages() -> UIImage {
        UIGraphicsBeginImageContextWithOptions(self.frame.size, false, 0)
        
        if self.backgroundImageView.image != nil {
            let rect = self.centeredBackgroundImageRect()
            self.backgroundImageView.image?.draw(in: rect)            // draw background image
        }
        
        self.mainImageView.image?.draw(in: AVMakeRect(aspectRatio: self.mainImageView.image!.size, insideRect: self.bounds))               // draw stroke
        
        let mergedImage = UIGraphicsGetImageFromCurrentImageContext()   // merge
        
        UIGraphicsEndImageContext()
        
        return mergedImage!
    }
    
    fileprivate func centeredBackgroundImageRect() -> CGRect {
        if self.frame.size.equalTo((self.backgroundImageView.image?.size)!) {
            return self.frame
        }
        
        let selfWidth = self.frame.width
        let selfHeight = self.frame.height
        let imageWidth = self.backgroundImageView.image?.size.width
        let imageHeight = self.backgroundImageView.image?.size.height
        
        let widthRatio = selfWidth / imageWidth!
        let heightRatio = selfHeight / imageHeight!
        let scale = min(widthRatio, heightRatio)
        let resizedWidth = scale * imageWidth!
        let resizedHeight = scale * imageHeight!
        
        var rect = CGRect.zero
        rect.size = CGSize(width: resizedWidth, height: resizedHeight)
        
        if selfWidth > resizedWidth {
            rect.origin.x = (selfWidth - resizedWidth) / 2
        }
        
        if selfHeight > resizedHeight {
            rect.origin.y = (selfHeight - resizedHeight) / 2
        }
        
        return rect
    }
    
    // MARK: - Public Methods
    @objc open func update(_ backgroundImage: UIImage?) {
        self.backgroundImageView.image = backgroundImage
        self.session.append(self.currentDrawing())
        self.saved = self.canSave()
        self.didUpdateCanvas()
    }
    
    @objc open func undo() {
        self.session.undo()
        self.updateByLastSession()
        self.saved = self.canSave()
        self.didUpdateCanvas()
    }

    @objc open func redo() {
        self.session.redo()
        self.updateByLastSession()
        self.saved = self.canSave()
        self.didUpdateCanvas()
    }
    
    @objc open func clear() {
        self.session.clear()
        self.updateByLastSession()
        self.saved = true
        self.didUpdateCanvas()
    }
    
    @objc open func save() {
        self.drawing.stroke = self.mainImageView.image?.copy() as? UIImage
        self.drawing.background = self.backgroundImageView.image
        self.saved = true
        self.didSaveCanvas()
    }
    
    @objc open func canUndo() -> Bool {
        return self.session.canUndo()
    }

    @objc open func canRedo() -> Bool {
        return self.session.canRedo()
    }

    @objc open func canClear() -> Bool {
        return self.session.canReset()
    }

    @objc open func canSave() -> Bool {
        return !(self.isStrokeEqual() && self.isBackgroundEqual())
    }
}
