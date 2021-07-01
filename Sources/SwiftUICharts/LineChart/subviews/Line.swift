//
//  Line.swift
//  LineChart
//
//  Created by András Samu on 2019. 08. 30..
//  Copyright © 2019. András Samu. All rights reserved.
//

import SwiftUI

#if os(iOS) || os(watchOS)

public struct Line: View {
    
    @ObservedObject var data: ChartData
    
    var gradient: GradientColor
    var index: Int = 0
    var curvedLines: Bool
    
    @State var fillGraph: Bool
    
    @State private var showFull: Bool = false
    
    @Binding var touchLocation: CGPoint
    @Binding var showIndicator: Bool
    @Binding var minDataValue: Double?
    @Binding var maxDataValue: Double?
    
    /**
     Calculates and returns the horizontal spacing between each point in `data`.
     - parameter totalWidth: The total width available for this view to be drawn in.
     - returns: The horizontal spacing to set between each point in `data`.
     */
    func stepWidth(totalWidth: CGFloat) -> CGFloat {
        if data.points.count < 2 {
            return 0
        }
        return totalWidth / CGFloat(data.points.count-1)
    }
    
    /**
     Calculates and returns the number of pixels that each y-axis increment of value +1 takes up.
     - parameter totalHeight: The total height available for this view to be drawn in
     - returns: The number of pixels that each y-axis increment of value +1 takes up.
     */
    func stepHeight(totalHeight: CGFloat) -> CGFloat {
        var min: Double?
        var max: Double?
        let points = self.data.onlyPoints()
        if minDataValue != nil && maxDataValue != nil {
            min = minDataValue!
            max = maxDataValue!
        } else if let minPoint = points.min(), let maxPoint = points.max(), minPoint != maxPoint {
            min = minPoint
            max = maxPoint
        } else {
            return 0
        }
        if let min = min, let max = max, min != max {
            if min <= 0 {
                return totalHeight / CGFloat(max - min)
            } else {
                return totalHeight / CGFloat(max - min)
            }
        }
        return 0
    }
    
    /**
     Given the number of values in `data`, calculates and returns the X offset from the center that an element in `data` should be drawn at.
     - parameter idx: The index of the element in `data` for which to calculate the X offset from.
     - parameter totalWidth: The total width of the view that this Line is drawn in.
     - returns: The x-offset from the center for the element in `data` at index `idx`.
     */
    private func getXOffsetFromCenter(idx: Int, totalWidth: CGFloat) -> CGFloat {
        let xRatio = CGFloat(idx) / (CGFloat(data.onlyPoints().count) - 1)
        let scaledX = totalWidth * xRatio
        return scaledX - (totalWidth/2)
    }
    
    /**
     Given the min and max values  in `data`, calculates and returns the Y offset from the center that an element in `data` should be drawn at.
     - parameter idx: The index of the element in `data` for which to calculate the Y offset from.
     - parameter totalHeight: The total height of the view that this Line is drawn in.
     - returns: (Optional) The y-offset from the center for the element in `data` at index `idx`.
     */
    private func getYOffsetFromCenter(idx: Int, totalHeight: CGFloat) -> CGFloat? {
        
        guard let minDouble = data.onlyPoints().min(), let maxDouble = data.onlyPoints().max() else {
            return nil
        }
        
        let min = CGFloat(minDouble), max = CGFloat(maxDouble)
        let yDiff = max - min
        let yHeight = CGFloat(data.onlyPoints()[idx]) - min
        let yRatio = yHeight / yDiff
        let scaledY = totalHeight * yRatio
        return (totalHeight/2) - scaledY
        
    }
    
    /**
     Given a touch location, returns the estimated coordinates of the point on the line at the touch gesture's x-location.
     - parameter touchLocation: Location of touch gesture.
     - parameter totalSize: The total size of the touch gesture's parent View.
     - returns: The point on the line that's horizontally closest to the touch gesture.
     */
    private func getClosestPointOnPath(touchLocation: CGPoint, totalSize: CGSize) -> CGPoint {
        return self.path(totalSize: totalSize).point(at: touchLocation.x)
    }
    
    /**
     Finds and returns the point in `data` that's horizontally closest to a touch gesture.
     - parameter data: The `ChartData` that is supplied to the Line.
     - parameter touchLocation: Location of touch gesture.
     - parameter totalSize: The total size of the touch gesture's parent View (and that the Line is drawn in).
     - returns: The point in `data` that's horizontally closest to the touch gesture.
     */
    static func getClosestPointInData(data: ChartData, touchLocation: CGPoint, totalSize: CGSize) -> (coordinates: CGPoint,
                                                                                                      x: String,
                                                                                                      y: Double) {
        // TO-DO: Update function to protect against division by 0
        // TO-DO: Return optional or signal to caller that func found nil in required optionals
        let points = data.onlyPoints()
        guard let min = points.min(), let max = points.max() else {
            return (CGPoint(), "", 0)
        }

        let diff = CGFloat(max - min)
        let stepWidth: CGFloat = totalSize.width / CGFloat(points.count-1) // The horizontal space between each pair of points.
        let stepHeight: CGFloat = totalSize.height / diff // The vertical space that each y increment of +1 takes up.
        
        // Find the x-distance from each point to the touch gesture location.
        let horizontalDistances = points.enumerated().map({ index, point in
            abs( (CGFloat(index) * stepWidth) - touchLocation.x)
        })
        
        // TO-DO: Return optional or signal to caller that func found nil in required optionals
        guard let minDistance = horizontalDistances.min(),
              let idx = horizontalDistances.firstIndex(of: minDistance) else {
            return (CGPoint(), "", 0)
        }
        
        return (CGPoint(x: CGFloat(idx) * stepWidth, y: (CGFloat(points[idx] - min) * stepHeight)),
                data.points[idx].x,
                data.points[idx].y)
        
    }
    
    private func path(totalSize: CGSize) -> Path {
        let points = self.data.onlyPoints()
        let stepSize = CGPoint(x: stepWidth(totalWidth: totalSize.width), y: stepHeight(totalHeight: totalSize.height))
        if curvedLines {
            return Path.quadCurvedPathWithPoints(points: points, step: stepSize, globalOffset: minDataValue)
        } else {
            return Path.straightPath(points: points, size: totalSize)
        }
    }
    
    private func closedPath(totalSize: CGSize) -> Path {
        let points = self.data.onlyPoints()
        let stepSize = CGPoint(x: stepWidth(totalWidth: totalSize.width), y: stepHeight(totalHeight: totalSize.height))
        if curvedLines {
            return Path.quadClosedCurvedPathWithPoints(points: points, step: stepSize, globalOffset: minDataValue)
        } else {
            return Path.closedStraightPath(points: points, size: totalSize)
        }
    }
    
    public var body: some View {
        
        GeometryReader { gr in
            
            ZStack {
                
                if(self.showFull && self.fillGraph){
                    self.closedPath(totalSize: gr.size)
                        .fill(LinearGradient(gradient: Gradient(colors: [Colors.GradientUpperBlue, .white]), startPoint: .bottom, endPoint: .top))
                        .rotationEffect(.degrees(180), anchor: .center)
                        .rotation3DEffect(.degrees(180), axis: (x: 0, y: 1, z: 0))
                        .transition(.opacity)
                        .animation(.easeIn(duration: 1.6))
                }
                
                self.path(totalSize: gr.size)
                    .trim(from: 0, to: self.showFull ? 1:0)
                    .stroke(LinearGradient(gradient: gradient.getGradient(), startPoint: .leading, endPoint: .trailing),
                            style: StrokeStyle(lineWidth: 3, lineJoin: .round))
                    .rotationEffect(.degrees(180), anchor: .center)
                    .rotation3DEffect(.degrees(180), axis: (x: 0, y: 1, z: 0))
                    .animation(Animation.easeOut(duration: 1.2).delay(Double(self.index)*0.4))
                    .onAppear {
                        self.showFull = true
                    }
                    .onDisappear {
                        self.showFull = false
                    }
                    .drawingGroup()
                
                ForEach(0 ..< data.onlyPoints().count, id: \.self) { idx in
                    // TO-DO: Handle if return from `getYOffsetFromCenter` is nil
                    if let y = getYOffsetFromCenter(idx: idx, totalHeight: gr.size.height) {
                        Circle()
                            .offset(x: getXOffsetFromCenter(idx: idx, totalWidth: gr.size.width),
                                    y: y)
                            .frame(width: 10, height: 10)
                    }
                }
                
                if(self.showIndicator) {
                    
                    Circle()
                        .frame(width: 10, height: 10)
                        .position(self.getClosestPointOnPath(touchLocation: self.touchLocation, totalSize: gr.size))
                        .rotationEffect(.degrees(180), anchor: .center)
                        .rotation3DEffect(.degrees(180), axis: (x: 0, y: 1, z: 0))
                    
                    IndicatorPoint()
                        .position(Line.getClosestPointInData(data: self.data,
                                                             touchLocation: self.touchLocation,
                                                             totalSize: gr.size).coordinates)
                        .rotationEffect(.degrees(180), anchor: .center)
                        .rotation3DEffect(.degrees(180), axis: (x: 0, y: 1, z: 0))
                    
                }
                
            }
            
        }
        
    }
    
}

#endif
