//
//  Line.swift
//  LineChart
//
//  Created by András Samu on 2019. 08. 30..
//  Copyright © 2019. András Samu. All rights reserved.
//

import SwiftUI

public struct Line: View {
    
    @ObservedObject var data: ChartData
    
    var gradient: GradientColor = GradientColor(start: Colors.GradientPurple, end: Colors.GradientNeonBlue)
    var index: Int = 0
    var curvedLines: Bool = false
    
    @State var showBackground: Bool = true
    @State private var showFull: Bool = false
    
    @Binding var frame: CGRect
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
            if (min <= 0){
                return totalHeight / CGFloat(max - min)
            }else{
                return totalHeight / CGFloat(max - min)
            }
        }
        return 0
    }
    
    private func path(totalSize: CGSize) -> Path {
        let points = self.data.onlyPoints()
        let stepSize = CGPoint(x: stepWidth(totalWidth: totalSize.width), y: stepHeight(totalHeight: totalSize.height))
        if curvedLines {
            return Path.quadCurvedPathWithPoints(points: points, step: stepSize, globalOffset: minDataValue)
        } else {
            return Path.linePathWithPoints(points: points, step: stepSize)
        }
    }
    
    private func closedPath(totalSize: CGSize) -> Path {
        let points = self.data.onlyPoints()
        let stepSize = CGPoint(x: stepWidth(totalWidth: totalSize.width), y: stepHeight(totalHeight: totalSize.height))
        if curvedLines {
            return Path.quadClosedCurvedPathWithPoints(points: points, step: stepSize, globalOffset: minDataValue)
        } else {
            return Path.closedLinePathWithPoints(points: points, step: stepSize)
        }
    }
    
    func getClosestPointOnPath(touchLocation: CGPoint, totalSize: CGSize) -> CGPoint {
        let closest = self.path(totalSize: totalSize).point(to: touchLocation.x)
        return closest
    }
    
    public var body: some View {
        
        GeometryReader { gr in
            
            ZStack {
                
                if(self.showFull && self.showBackground){
                    self.closedPath(totalSize: gr.size)
                        .fill(LinearGradient(gradient: Gradient(colors: [Colors.GradientUpperBlue, .white]), startPoint: .bottom, endPoint: .top))
                        .rotationEffect(.degrees(180), anchor: .center)
                        .rotation3DEffect(.degrees(180), axis: (x: 0, y: 1, z: 0))
                        .transition(.opacity)
                        .animation(.easeIn(duration: 1.6))
                }
                
                self.path(totalSize: gr.size)
                    .trim(from: 0, to: self.showFull ? 1:0)
                    .stroke(LinearGradient(gradient: gradient.getGradient(), startPoint: .leading, endPoint: .trailing) ,style: StrokeStyle(lineWidth: 3, lineJoin: .round))
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
                
                if(self.showIndicator) {
                    IndicatorPoint()
                        .position(self.getClosestPointOnPath(touchLocation: self.touchLocation, totalSize: gr.size))
                        .rotationEffect(.degrees(180), anchor: .center)
                        .rotation3DEffect(.degrees(180), axis: (x: 0, y: 1, z: 0))
                }
                
            }
            
        }
        
    }
    
}
