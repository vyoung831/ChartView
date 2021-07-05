//
//  Legend.swift
//  LineChart
//
//  Created by András Samu on 2019. 09. 02..
//  Copyright © 2019. András Samu. All rights reserved.
//

import SwiftUI

#if os(iOS) || os(watchOS)

struct Legend: View {
    
    @Environment(\.colorScheme) var colorScheme: ColorScheme
    
    var minY: CGFloat
    var maxY: CGFloat
    var style: LineChartStyle
    
    let totalSteps: Int = 4
    let stepLineWidth: CGFloat = 2
    let xAxisLineWidth: CGFloat = 8
    static let legendOffset: CGFloat = 50
    
    @Binding var hideHorizontalLines: Bool
    
    /**
     Returns the y-axis value of a specific step.
     Given the `ChartData` and total number of y-axis steps, returns the y-value that a specific step is to be assigned.
     - parameter step: The step for which to return the y-value for. Possible values = [0 ... `totalSteps`]
     - returns: The y-value for the provided step.
     */
    func getStepYValue(step: Int) -> CGFloat {
        let stepHeight = (maxY - minY) / CGFloat(totalSteps)
        return minY + (CGFloat(step) * stepHeight)
    }
    
    /**
     Gets the offset of a step from the center of its parent view.
     - parameter step: The step for which to return the y-offset from the center for.
     - parameter totalHeight: The total height of the parent view that the step would be drawn in.
     - returns: The y-offset from the parent view's center that the step line should be drawn on.
     */
    func getOffsetFromCenter(step: Int, totalHeight: CGFloat) -> CGFloat {
        let diff = maxY - minY
        let stepHeight = diff/CGFloat(totalSteps)
        let yValue = CGFloat(stepHeight * CGFloat(step))
        let offsetFromBottom = yValue / CGFloat(diff)
        
        return totalHeight/2 - (offsetFromBottom * totalHeight)
    }
    
    /**
     Returns a horizontal line, drawn at a specified height.
     - parameter atHeight: The height at which to draw the line
     - parameter length: The length of the line to be drawn.
     - parameter totalHeight: The total height of the parent view that the line is to be drawn in.
     - returns: Horizontal line drawn at the specified height and with the specified length.
     */
    func line(atHeight: CGFloat, length: CGFloat, totalHeight: CGFloat) -> Path {
        var hLine = Path()
        let yValue = ((atHeight - minY) / (maxY - minY)) * totalHeight
        hLine.move(to: CGPoint(x: 0, y: yValue))
        hLine.addLine(to: CGPoint(x: length, y: yValue))
        return hLine
    }
    
    var body: some View {
        
        GeometryReader { gr in
            
            ZStack(alignment: .topLeading) {
                
                // Y-value lines
                ForEach(0 ... totalSteps, id: \.self) { stepIdx in
                    
                    HStack(alignment: .center, spacing: 0) {
                        
                        Text("\(self.getStepYValue(step: stepIdx), specifier: "%.2f")")
                            .frame(width: Legend.legendOffset)
                            .offset(x: 0, y: self.getOffsetFromCenter(step: stepIdx, totalHeight: gr.size.height))
                            .foregroundColor(Colors.LegendText)
                            .font(.caption)
                        
                        self.line(atHeight: self.getStepYValue(step: stepIdx), length: gr.size.width - Legend.legendOffset, totalHeight: gr.size.height)
                            .stroke(self.style.axisColor,
                                    style: StrokeStyle(lineWidth: self.stepLineWidth,
                                                       lineCap: .round,
                                                       dash: [5, stepIdx == 0 ? 0 : 10]))
                            .opacity((self.hideHorizontalLines && stepIdx != 0) ? 0 : 1)
                            .rotationEffect(.degrees(180), anchor: .center)
                            .rotation3DEffect(.degrees(180), axis: (x: 0, y: 1, z: 0))
                            .animation(.easeOut(duration: 0.2))
                            .clipped()
                        
                    }
                    
                }
                
                // x-axis
                if maxY >= 0 && minY <= 0 {
                    self.line(atHeight: 0, length: gr.size.width - Legend.legendOffset, totalHeight: gr.size.height)
                        .offset(x: Legend.legendOffset)
                        .stroke(self.style.axisColor,
                                style: StrokeStyle(lineWidth: self.xAxisLineWidth))
                        .rotationEffect(.degrees(180), anchor: .center)
                        .rotation3DEffect(.degrees(180), axis: (x: 0, y: 1, z: 0))
                        .animation(.easeOut(duration: 0.2))
                        .clipped()
                }
                
            }
            
        }
        
    }
    
}

#endif
