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
    
    let totalSteps: Int = 4
    let stepLineWidth: CGFloat = 2
    static let legendOffset: CGFloat = 50
    
    @Binding var hideHorizontalLines: Bool
    @ObservedObject var data: ChartData
    
    var min: CGFloat {
        return CGFloat(self.data.onlyPoints().min()!)
    }
    
    var max: CGFloat {
        return CGFloat(self.data.onlyPoints().max()!)
    }
    
    /**
     Returns the y-axis value of a specific step.
     Given the `ChartData` and total number of y-axis steps, returns the y-value that a specific step is to be assigned.
     - parameter step: The step for which to return the y-value for. Possible values = [0 ... `totalSteps`]
     - returns: The y-value for the provided step.
     */
    func getStepYValue(step: Int) -> CGFloat {
        let stepHeight = (max - min) / CGFloat(totalSteps)
        return min + (CGFloat(step) * stepHeight)
    }
    
    /**
     Gets the offset of a step from the center of its parent view.
     - parameter step: The step for which to return the y-offset from the center for.
     - parameter totalHeight: The total height of the parent view that the step would be drawn in.
     - returns: The y-offset from the parent view's center that the step line should be drawn on.
     */
    func getOffsetFromCenter(step: Int, totalHeight: CGFloat) -> CGFloat {
        let diff = max - min
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
        let yValue = ((atHeight - min) / (max - min)) * totalHeight
        hLine.move(to: CGPoint(x: 0, y: yValue))
        hLine.addLine(to: CGPoint(x: length, y: yValue))
        return hLine
    }
    
    var body: some View {
        
        GeometryReader { gr in
            
            ZStack(alignment: .topLeading) {
                
                // Step lines
                ForEach(0 ... totalSteps, id: \.self) { stepIdx in
                    HStack(alignment: .center, spacing: 0) {
                        Text("\(self.getStepYValue(step: stepIdx), specifier: "%.2f")")
                            .frame(width: Legend.legendOffset)
                            .offset(x: 0, y: self.getOffsetFromCenter(step: stepIdx, totalHeight: gr.size.height))
                            .foregroundColor(Colors.LegendText)
                            .font(.caption)
                        self.line(atHeight: self.getStepYValue(step: stepIdx), length: gr.size.width - Legend.legendOffset, totalHeight: gr.size.height)
                            .stroke(self.colorScheme == .dark ? Colors.LegendDarkColor : Colors.LegendColor,
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
                if max >= 0 && min <= 0 {
                    self.line(atHeight: 0, length: gr.size.width - Legend.legendOffset, totalHeight: gr.size.height)
                        .offset(x: Legend.legendOffset)
                        .stroke(Color.red,
                                style: StrokeStyle(lineWidth: self.stepLineWidth,
                                                   lineCap: .round))
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
