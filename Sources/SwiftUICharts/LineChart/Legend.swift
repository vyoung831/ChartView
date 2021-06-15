//
//  Legend.swift
//  LineChart
//
//  Created by András Samu on 2019. 09. 02..
//  Copyright © 2019. András Samu. All rights reserved.
//

import SwiftUI

struct Legend: View {
    
    @Environment(\.colorScheme) var colorScheme: ColorScheme
    
    let totalSteps: Int = 4
    let stepLineWidth: CGFloat = 2
    static let legendOffset: CGFloat = 50
    
    @Binding var frame: CGRect
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
     Gets the offset of a step from the center of `frame`.
     - parameter step: The step for which to return the y-offset from the center for.
     - returns: The y-offset from `frame`'s center that the step line should be drawn on.
     */
    func getOffsetFromCenter(step: Int) -> CGFloat {
        let diff = max - min
        let stepHeight = diff/CGFloat(totalSteps)
        let yValue = CGFloat(stepHeight * CGFloat(step))
        let offsetFromBottom = yValue / CGFloat(diff)
        
        return self.frame.height/2 - (offsetFromBottom * self.frame.height)
    }
    
    /**
     Returns a horizontal line, drawn at a specified height.
     - parameter atHeight: The height at which to draw the line
     - parameter length: The length of the line to be drawn.
     - returns: Horizontal line drawn at the specified height and with the specified length.
     */
    func line(atHeight: CGFloat, length: CGFloat) -> Path {
        var hLine = Path()
        let yValue = ((atHeight - min) / (max - min)) * self.frame.height
        hLine.move(to: CGPoint(x: 0, y: yValue))
        hLine.addLine(to: CGPoint(x: length, y: yValue))
        return hLine
    }
    
    var body: some View {
        
        ZStack(alignment: .topLeading){
            ForEach(0 ... totalSteps, id: \.self) { stepIdx in
                HStack(alignment: .center, spacing: 0){
                    Text("\(self.getStepYValue(step: stepIdx), specifier: "%.2f")")
                        .frame(width: Legend.legendOffset)
                        .offset(x: 0, y: self.getOffsetFromCenter(step: stepIdx))
                        .foregroundColor(Colors.LegendText)
                        .font(.caption)
                    self.line(atHeight: self.getStepYValue(step: stepIdx), length: self.frame.width - Legend.legendOffset)
                        .stroke(self.colorScheme == .dark ? Colors.LegendDarkColor : Colors.LegendColor,
                                style: StrokeStyle(lineWidth: self.stepLineWidth,
                                                   lineCap: .round, dash: [5, stepIdx == 0 ? 0 : 10]))
                        .opacity((self.hideHorizontalLines && stepIdx != 0) ? 0 : 1)
                        .rotationEffect(.degrees(180), anchor: .center)
                        .rotation3DEffect(.degrees(180), axis: (x: 0, y: 1, z: 0))
                        .animation(.easeOut(duration: 0.2))
                        .clipped()
                }
            }
        }
        
    }
    
}
