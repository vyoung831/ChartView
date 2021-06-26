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
    
    /**.
     Returns a partial copy of this Path centered at `at`% of this Path's total distance , including linearly interpolated points at -/+0.05% of the path's distance.
     - parameter at: A number between 0 and 1 (non-inclusive) that indicates the percent distance of the path to center the partial copy at.
     - returns: A partial copy of this Path containing the linearly interpolated Path starting and ending at  -/+0.05% of `at`.
     */
    func trimmedPath(at percent: CGFloat) -> Path {
        
        // `boundsDistance` defines the percent delta
        let trimmedPathDistance: CGFloat = 0.001
        let upperBounds: CGFloat = 1 - trimmedPathDistance
        let lowerBounds: CGFloat = trimmedPathDistance
        
        let center = percent > 1 ? 0 : (percent < 0 ? 1 : percent)
        if center >= upperBounds {
            return trimmedPath(from: upperBounds, to: 1)
        } else if center <= lowerBounds {
            return trimmedPath(from: 0, to: lowerBounds)
        } else {
            return trimmedPath(from: center - (trimmedPathDistance/2), to: center + (trimmedPathDistance/2))
        }
        
    }
    
    func point(for percent: CGFloat) -> CGPoint {
        let path = trimmedPath(at: percent)
        return CGPoint(x: path.boundingRect.midX, y: path.boundingRect.midY)
    }
    
    func point(until maxX: CGFloat) -> CGPoint {
        let subpathLength = length(until: maxX)
        let percent = subpathLength / length
        return point(for: percent)
    }
    
    /**
     Iterates over Path Elements and finds the total length of this Path until (and including) the first element whose x-value exceeds the provided value.
     If all Elements' x-values are less than `until`, this function returns the total length of this Path.
     - parameter until: The x-value after which to stop counting the length to more elements.
     - returns: The total length of this Path up until (inclusive) the first Element whose x-value exceeds `until`.
     */
    func length(until maxX: CGFloat) -> CGFloat {

        var ret: CGFloat = 0.0
        var point = CGPoint.zero
        var finished = false
        
        forEach { ele in
            
            // Stop processing for rest of Path.Elements
            if finished { return }
            
            switch ele {
            case .move(let to):
                if to.x > maxX {
                    finished = true
                    return
                }
                point = to
                return
            case .line(let to):
                if to.x > maxX {
                    finished = true
                    ret += point.distanceToPointOnLine(dest: to, x: maxX)
                    return
                }
                ret += point.distance(to: to)
                point = to
                return
            case .quadCurve(let to, let control):
                // TO-DO: Review code for this case
                if to.x > maxX {
                    finished = true
                    ret += point.quadCurve(to: to, control: control, x: maxX)
                    return
                }
                ret += point.quadCurve(to: to, control: control)
                point = to
                return
            case .curve(let to, let control1, let control2):
                // TO-DO: Review code for this case
                if to.x > maxX {
                    finished = true
                    ret += point.curve(to: to, control1: control1, control2: control2, x: maxX)
                    return
                }
                ret += point.curve(to: to, control1: control1, control2: control2)
                point = to
                return
            case .closeSubpath:
                // TO-DO: Review code for this case
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
