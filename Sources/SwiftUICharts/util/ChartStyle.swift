//
//  ChartStyle.swift
//  
//
//  Created by Vincent Young on 6/15/21.
//

import Foundation
import SwiftUI

#if os(iOS) || os(watchOS)

// MARK: - GradientColor

public struct GradientColor {
    
    public let start: Color
    public let end: Color
    
    public init(start: Color, end: Color) {
        self.start = start
        self.end = end
    }
    
    public func getGradient() -> Gradient {
        return Gradient(colors: [start, end])
    }
    
}

// MARK: - ChartStyle

public class ChartStyle {
    
    public var backgroundColor: Color = Color.clear
    public var accentColor: Color
    public var gradientColor: GradientColor
    public var textColor: Color
    public var dropShadowColor: Color // Drop shadow for entire graph
    
    convenience init(backgroundColor: Color = .clear, accentColor: Color, secondGradientColor: Color, textColor: Color, dropShadowColor: Color) {
        self.init(backgroundColor: backgroundColor, accentColor: accentColor, gradientColor: GradientColor(start: accentColor, end: secondGradientColor), textColor: textColor, dropShadowColor: dropShadowColor)
    }
    
    public init(backgroundColor: Color = .clear, accentColor: Color, gradientColor: GradientColor, textColor: Color, dropShadowColor: Color) {
        self.backgroundColor = backgroundColor
        self.accentColor = accentColor
        self.gradientColor = gradientColor
        self.textColor = textColor
        self.dropShadowColor = dropShadowColor
    }
    
}

public class LineChartStyle: ChartStyle {

    public var axisColor: Color

    public init(backgroundColor: Color = .clear, accentColor: Color, gradientColor: GradientColor, textColor: Color, dropShadowColor: Color, axisColor: Color) {
        self.axisColor = axisColor
        super.init(backgroundColor: backgroundColor, accentColor: accentColor, gradientColor: gradientColor, textColor: textColor, dropShadowColor: dropShadowColor)
    }
    
    public init(chartStyle: ChartStyle, axisColor: Color) {
        self.axisColor = axisColor
        super.init(backgroundColor: chartStyle.backgroundColor, accentColor: chartStyle.accentColor, gradientColor: chartStyle.gradientColor, textColor: chartStyle.textColor, dropShadowColor: chartStyle.dropShadowColor)
    }

}

#endif
