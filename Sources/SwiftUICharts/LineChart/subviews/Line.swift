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
    
    @ObservedObject var data: LineChartData
    
    var style: LineChartStyle
    @State var index: Int = 0
    @State var curvedLines: Bool
    @State var fillGraph: Bool
    @State var showFull: Bool = false
    
    @Binding var touchLocation: CGPoint
    @Binding var showIndicator: Bool
    
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
        let min = CGFloat(data.minY), max = CGFloat(data.maxY)
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
     - parameter data: The `LineChartData` that is supplied to the Line.
     - parameter touchLocation: Location of touch gesture.
     - parameter totalSize: The total size of the touch gesture's parent View (and that the Line is drawn in).
     - returns: The point in `data` that's horizontally closest to the touch gesture.
     */
    static func getClosestPointInData(data: LineChartData, touchLocation: CGPoint, totalSize: CGSize) -> (coordinates: CGPoint,
                                                                                                      x: String,
                                                                                                      y: Double) {
        // TO-DO: Update function to protect against division by 0
        // TO-DO: Return optional or signal to caller that func found nil in required optionals
        let points = data.onlyPoints()

        let diff = CGFloat(data.maxY - data.minY)
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
        
        return (CGPoint(x: CGFloat(idx) * stepWidth, y: (CGFloat(points[idx] - data.minY) * stepHeight)),
                data.points[idx].x,
                data.points[idx].y)
        
    }
    
    private func path(totalSize: CGSize) -> Path {
        if curvedLines {
            return Path.quadCurvedPath(data: self.data, size: totalSize)
        } else {
            return Path.straightPath(data: data, size: totalSize)
        }
    }
    
    private func closedPath(totalSize: CGSize) -> Path {
        if curvedLines {
            return Path.quadClosedCurvedPath(data: data, size: totalSize)
        } else {
            return Path.closedStraightPath(data: data, size: totalSize)
        }
    }
    
    public var body: some View {
        
        GeometryReader { gr in
            
            ZStack {
                
                if(self.showFull && self.fillGraph){
                    self.closedPath(totalSize: gr.size)
                        .fill(LinearGradient(gradient: self.style.gradientColor.getGradient(), startPoint: .leading, endPoint: .trailing))
                        .rotationEffect(.degrees(180), anchor: .center)
                        .rotation3DEffect(.degrees(180), axis: (x: 0, y: 1, z: 0))
                        .transition(.opacity)
                        .animation(.easeIn(duration: 1.6))
                }
                
                self.path(totalSize: gr.size)
                    .trim(from: 0, to: self.showFull ? 1:0)
                    .stroke(self.style.accentColor, style: StrokeStyle(lineWidth: 3, lineJoin: .round))
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
                            .foregroundColor(data.getColor(data.onlyPoints()[idx]))
                    }
                }
                
                if(self.showIndicator) {
                    
                    Circle()
                        .frame(width: 10, height: 10)
                        .foregroundColor(self.style.textColor)
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
