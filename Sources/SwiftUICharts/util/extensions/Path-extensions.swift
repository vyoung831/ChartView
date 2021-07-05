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
     Returns a partial copy of this Path centered at `at`% of this Path's total distance from the start, including linearly interpolated points at -/+0.05% of the path's distance.
     - parameter at: A number from 0 to 1 (inclusive) that indicates the percent distance of the path to center the partial copy at.
     - returns: A partial copy of this Path containing the linearly interpolated Path starting and ending at  -/+0.05% of `at`.
     */
    func trimmedPath(at percent: CGFloat) -> Path {
        
        let trimmedPathDistance: CGFloat = 0.001
        let upperBounds: CGFloat = 1 - trimmedPathDistance
        let lowerBounds: CGFloat = trimmedPathDistance
        
        let center = percent > 1 ? 1 : (percent < 0 ? 0 : percent)
        if center >= upperBounds + (trimmedPathDistance/2) {
            return trimmedPath(from: upperBounds, to: 1)
        } else if center <= lowerBounds - (trimmedPathDistance/2) {
            return trimmedPath(from: 0, to: lowerBounds)
        } else {
            return trimmedPath(from: center - (trimmedPathDistance/2), to: center + (trimmedPathDistance/2))
        }
        
    }
    
    /**
     Returns estimated coordinates of a point on this path.
     Instead of finding the exact coordinates, a partial copy of this path is obtained (centered at the provided x-value) and the center of that partial Path's bounding rectangle is returned.
     - parameter at: The x-value for which to get the estimated coordinates of the point on the line.
     - returns: The center of the rectangle that bounds the partial path returned by `trimmedPath(at:)`.
     */
    func point(at maxX: CGFloat) -> CGPoint {
        let subpathLength = length(until: maxX)
        let percent = subpathLength / length
        
        let trimmedSubPath = trimmedPath(at: percent)
        return CGPoint(x: trimmedSubPath.boundingRect.midX,
                       y: trimmedSubPath.boundingRect.midY)
    }
    
    /**
     Iterates over Path Elements and finds the total length of this Path up to the provided max x-value.
     This function assumes that the x-values of this Path's elements are in ascending order.
     - parameter until: The x-value to count the length of this Path up until.
     - returns: The total length of this Path up until (inclusive) `until`.
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
     - parameter data: Instance of `LineChartData` containing data's y-values and graph's min/max y-values.
     - parameter size: The total size of the parent View that the Path is to be drawn in.
     - returns: Non-curved path that takes up the entire size of the parent View, with even horizontal spacing.
     */
    static func straightPath(data: LineChartData, size: CGSize) -> Path {
        
        let points = data.onlyPoints()
        let diff = data.maxY - data.minY
        
        // TO-DO: Handle insufficient point count more gracefully
        var path = Path()
        if (points.count < 2){
            return path
        }
        
        // Move Path to starting point
        let p1 = CGPoint(x: 0, y: CGFloat((points[0] - data.minY) / diff) * size.height)
        path.move(to: p1)
        
        let xStep = size.width / (CGFloat(points.count - 1))
        for idx in 1 ..< points.count {
            let p2 = CGPoint(x: xStep * CGFloat(idx), y: CGFloat((points[idx] - data.minY) / diff) * size.height)
            path.addLine(to: p2)
        }
        return path
        
    }
    
    /**
     Returns the path returned by `Path.straightPath()`, closed at either the top, bottom, or x-axis.
     Given that `size` is the total size of the parent View that this Path is drawn in, the height at which the Path is closed depends on the provided `LineChartData`'s data values and min/max y-values.
     - parameter data: Instance of `LineChartData` containing data's y-values and graph's min/max y-values.
     - parameter size: The total size of the parent View that the Path is to be drawn in.
     - returns: Path returned by `Path.straightPath()`, closed at a height determined by `data`'s points and min/max y-values.
     */
    static func closedStraightPath(data: LineChartData, size: CGSize) -> Path {
        
        var path = straightPath(data: data, size: size)
        
        // Find height in `size` to close path at.
        var closeHeight: CGFloat = 0
        if data.minY <= 0 && data.maxY >= 0 {
            // y=0 falls within the graph's min and max y-values. Close path at x-axis.
            let xAxisHeight = 0 - data.minY
            let diff = data.maxY - data.minY
            closeHeight = CGFloat(xAxisHeight/diff) * size.height
        } else {
            if data.minY > 0 {
                // All points and min y-value are non-negative. Close path at bottom of graph
                closeHeight = 0
            } else {
                // All points and max y-value are negative. Close path at top of graph
                closeHeight = size.height
            }
        }
        
        path.addLine(to: CGPoint(x: size.width, y: closeHeight))
        path.addLine(to: CGPoint(x: 0, y: closeHeight))
        path.closeSubpath()
        return path
        
    }
    
}

// MARK: - Static functions (Quad curved Paths)

extension Path {
    
    /**
     Returns a path that takes up the entire size provided and draws quadratic bezier curves between each pair of points.
     - parameter data: Instance of `LineChartData` containing data's y-values and graph's min/max y-values.
     - parameter size: The total size of the parent View that the Path is to be drawn in.
     - returns: Bezier quadratically-curved path that takes up the entire size of the parent View, with even horizontal spacing between input points.
     */
    static func quadCurvedPath(data: LineChartData, size: CGSize) -> Path {
        
        let points = data.onlyPoints()
        
        // TO-DO: Handle insufficient point count more gracefully
        var path = Path()
        if (points.count < 2){
            return path
        }
        let diff: CGFloat = CGFloat(data.maxY - data.minY)
        let xStep: CGFloat = size.width / CGFloat(points.count - 1)
        
        // Draw the path
        var p1 = CGPoint(x: 0, y: CGFloat(points[0] - data.minY)/diff * size.height)
        path.move(to: p1)
        
        for idx in 1 ..< points.count {
            let p2 = CGPoint(x: xStep * CGFloat(idx), y: CGFloat(points[idx] - data.minY)/diff * size.height)
            let midPoint = CGPoint.midPoint(p1: p1, p2: p2)
            path.addQuadCurve(to: midPoint, control: CGPoint.controlPointForPoints(p1: midPoint, p2: p1))
            path.addQuadCurve(to: p2, control: CGPoint.controlPointForPoints(p1: midPoint, p2: p2))
            p1 = p2
        }
        return path
    }
    
    /**
     Returns the path returned by `Path.quadCurvedPath()`, closed at either the top, bottom, or x-axis.
     Given that `size` is the total size of the parent View that this Path is drawn in, the height at which the Path is closed depends on the provided `LineChartData`'s data values and min/max y-values.
     - parameter data: Instance of `LineChartData` containing data's y-values and graph's min/max y-values.
     - parameter size: The total size of the parent View that the Path is to be drawn in.
     - returns: Path returned by `Path.quadCurvedPath()`, closed at a height determined by `data`'s points and min/max y-values.
     */
    static func quadClosedCurvedPath(data: LineChartData, size: CGSize) -> Path {
        
        var path = quadCurvedPath(data: data, size: size)
        
        // Find height in `size` to close path at.
        var closeHeight: CGFloat = 0
        if data.minY <= 0 && data.maxY >= 0 {
            // y=0 falls within the graph's min and max y-values. Close path at x-axis.
            let xAxisHeight = 0 - data.minY
            let diff = data.maxY - data.minY
            closeHeight = CGFloat(xAxisHeight/diff) * size.height
        } else {
            if data.minY > 0 {
                // All points and min y-value are non-negative. Close path at bottom of graph
                closeHeight = 0
            } else {
                // All points and max y-value are negative. Close path at top of graph
                closeHeight = size.height
            }
        }
        
        path.addLine(to: CGPoint(x: size.width, y: closeHeight))
        path.addLine(to: CGPoint(x: 0, y: closeHeight))
        path.closeSubpath()
        return path
        
    }
    
}
