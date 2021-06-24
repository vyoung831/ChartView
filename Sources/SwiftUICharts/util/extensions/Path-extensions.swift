//
//  Path-extensions.swift
//  
//
//  Created by Vincent Young on 5/30/21.
//

import SwiftUI

// MARK: - Class functions

extension Path {
    
    // Returns the total length of this Path
    var length: CGFloat {
        
        var totalLength: CGFloat = 0.0
        var start: CGPoint?
        var point = CGPoint.zero
        
        // Iterates over the elements of type `Path.Element` that this Path contains
        forEach { ele in
            switch ele {
            case .move(let to):
                if start == nil {
                    start = to
                }
                point = to
                break
            case .line(let to):
                totalLength += point.distance(to: to)
                point = to
                break
            case .quadCurve(let to, let control):
                totalLength += point.quadCurve(to: to, control: control)
                point = to
                break
            case .curve(let to, let control1, let control2):
                totalLength += point.curve(to: to, control1: control1, control2: control2)
                point = to
                break
            case .closeSubpath:
                if let to = start {
                    totalLength += point.distance(to: to)
                    point = to
                }
                start = nil
                break
            }
        }
        return totalLength
    }
    
    func trimmedPath(for percent: CGFloat) -> Path {
        // percent difference between points
        let boundsDistance: CGFloat = 0.001
        let completion: CGFloat = 1 - boundsDistance
        
        let pct = percent > 1 ? 0 : (percent < 0 ? 1 : percent)
        
        let start = pct > completion ? completion : pct - boundsDistance
        let end = pct > completion ? 1 : pct + boundsDistance
        return trimmedPath(from: start, to: end)
    }
    
    func point(for percent: CGFloat) -> CGPoint {
        let path = trimmedPath(for: percent)
        return CGPoint(x: path.boundingRect.midX, y: path.boundingRect.midY)
    }
    
    func point(to maxX: CGFloat) -> CGPoint {
        let total = length
        let sub = length(to: maxX)
        let percent = sub / total
        return point(for: percent)
    }
    
    func length(to maxX: CGFloat) -> CGFloat {
        var ret: CGFloat = 0.0
        var start: CGPoint?
        var point = CGPoint.zero
        var finished = false
        
        forEach { ele in
            if finished {
                return
            }
            switch ele {
            case .move(let to):
                if to.x > maxX {
                    finished = true
                    return
                }
                if start == nil {
                    start = to
                }
                point = to
                break
            case .line(let to):
                if to.x > maxX {
                    finished = true
                    ret += point.line(to: to, x: maxX)
                    return
                }
                ret += point.distance(to: to)
                point = to
                break
            case .quadCurve(let to, let control):
                if to.x > maxX {
                    finished = true
                    ret += point.quadCurve(to: to, control: control, x: maxX)
                    return
                }
                ret += point.quadCurve(to: to, control: control)
                point = to
                break
            case .curve(let to, let control1, let control2):
                if to.x > maxX {
                    finished = true
                    ret += point.curve(to: to, control1: control1, control2: control2, x: maxX)
                    return
                }
                ret += point.curve(to: to, control1: control1, control2: control2)
                point = to
                break
            case .closeSubpath:
                fatalError("Can't include closeSubpath")
            }
        }
        return ret
    }
    
}

// MARK: - Static functions (Straight Paths)

// TO-DO: Update functions to protect against division by 0
extension Path {
    
    /**
     Returns a non-curved, non-closed path that takes up the entirety of the provided size, represented as a straight line graph.
     - parameter points: Y-values of points to draw.
     - parameter size: The total size of the parent View that the Path is to be drawn in.
     - returns: Non-curved path that takes up the entire size of the parent View, with even horizontal spacing.
     */
    static func straightPath(points: [Double], size: CGSize) -> Path {
        
        // TO-DO: Handle insufficient point count more gracefully
        var path = Path()
        if (points.count < 2){
            return path
        }
        
        // TO-DO: Return optional or signal to caller that func found nil in required optionals
        guard let min = points.min(), let max = points.max() else { return path }
        let diff = max - min
        
        // Move Path to starting point
        let p1 = CGPoint(x: 0, y: CGFloat((points[0] - min) / diff) * size.height)
        path.move(to: p1)
        
        let xStep = size.width / (CGFloat(points.count - 1))
        for idx in 1 ..< points.count {
            let p2 = CGPoint(x: xStep * CGFloat(idx), y: CGFloat((points[idx] - min) / diff) * size.height)
            path.addLine(to: p2)
        }
        return path
        
    }
    
    /**
     Returns the path returned by `Path.straightPath()`, closed at either the top, bottom, or x-axis.
     Given that `size` is the total size of the parent View that this Path is drawn in, the height at which the Path is closed depends on the values in `points`.
     - If all points are non-negative, the path is closed at the bottom of the View.
     - If all points are negative, the path is closed at the top of the View.
     - If points are both negative and non-negative, the path is closed at the x-axis.
     - parameter points: Y-values of points to draw.
     - parameter size: The total size of the parent View that the Path is to be drawn in.
     - returns: Path returned by `Path.straightPath()`, closed at a height determined by `points`' values.
     */
    static func closedStraightPath(points: [Double], size: CGSize) -> Path {
        
        // TO-DO: Return optional or signal to caller that func found nil in required optionals
        var path = straightPath(points: points, size: size)
        guard let min = points.min(), let max = points.max() else { return path }
        
        var closedHeight: CGFloat = 0
        if !points.contains(where: { $0 < 0.0 }) {
            // All points are non-negative. Move path to minimum value in `points`
            closedHeight = 0
        } else if !points.contains(where: { $0 > 0.0 }) {
            // All points are negative. Move path to maximum value in `points`
            closedHeight = size.height
        } else {
            // All points are mixed positive and negative. Move path to x-axis
            let xAxisHeight = 0 - min
            let diff = max - min
            closedHeight = CGFloat(xAxisHeight/diff) * size.height
        }
        
        path.addLine(to: CGPoint(x: size.width, y: closedHeight))
        path.addLine(to: CGPoint(x: 0, y: closedHeight))
        path.closeSubpath()
        return path
        
    }
    
}

// MARK: - Static functions (Quad curved Paths)

extension Path {
    
    static func quadCurvedPathWithPoints(points: [Double], step: CGPoint, globalOffset: Double? = nil) -> Path {
        var path = Path()
        if (points.count < 2){
            return path
        }
        let offset = globalOffset ?? points.min()!
//        guard let offset = points.min() else { return path }
        
        // Draw the path
        var p1 = CGPoint(x: 0, y: CGFloat(points[0]-offset)*step.y)
        path.move(to: p1)
        for pointIndex in 1..<points.count {
            let p2 = CGPoint(x: step.x * CGFloat(pointIndex), y: step.y*CGFloat(points[pointIndex]-offset))
            let midPoint = CGPoint.midPointForPoints(p1: p1, p2: p2)
            path.addQuadCurve(to: midPoint, control: CGPoint.controlPointForPoints(p1: midPoint, p2: p1))
            path.addQuadCurve(to: p2, control: CGPoint.controlPointForPoints(p1: midPoint, p2: p2))
            p1 = p2
        }
        return path
    }
    
    static func quadClosedCurvedPathWithPoints(points:[Double], step:CGPoint, globalOffset: Double? = nil) -> Path {
        var path = Path()
        if (points.count < 2){
            return path
        }
        let offset = globalOffset ?? points.min()!

//        guard let offset = points.min() else { return path }
        path.move(to: .zero)
        var p1 = CGPoint(x: 0, y: CGFloat(points[0]-offset)*step.y)
        path.addLine(to: p1)
        for pointIndex in 1..<points.count {
            let p2 = CGPoint(x: step.x * CGFloat(pointIndex), y: step.y*CGFloat(points[pointIndex]-offset))
            let midPoint = CGPoint.midPointForPoints(p1: p1, p2: p2)
            path.addQuadCurve(to: midPoint, control: CGPoint.controlPointForPoints(p1: midPoint, p2: p1))
            path.addQuadCurve(to: p2, control: CGPoint.controlPointForPoints(p1: midPoint, p2: p2))
            p1 = p2
        }
        path.addLine(to: CGPoint(x: p1.x, y: 0))
        path.closeSubpath()
        return path
    }
    
}
