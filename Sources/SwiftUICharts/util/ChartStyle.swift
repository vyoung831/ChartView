//
//  ChartStyle.swift
//  
//
//  Created by Vincent Young on 6/15/21.
//

import Foundation
import SwiftUI

#if os(iOS) || os(watchOS)

public class ChartStyle {
    
    public var backgroundColor: Color = Color.clear
    public var accentColor: Color
    public var gradientColor: GradientColor
    public var textColor: Color
    public var legendTextColor: Color
    public var dropShadowColor: Color // Drop shadow for entire graph
    
    public init(backgroundColor: Color = .clear, accentColor: Color, secondGradientColor: Color, textColor: Color, legendTextColor: Color, dropShadowColor: Color) {
        self.backgroundColor = backgroundColor
        self.accentColor = accentColor
        self.gradientColor = GradientColor(start: accentColor, end: secondGradientColor)
        self.textColor = textColor
        self.legendTextColor = legendTextColor
        self.dropShadowColor = dropShadowColor
    }
    
    public init(backgroundColor: Color = .clear, accentColor: Color, gradientColor: GradientColor, textColor: Color, legendTextColor: Color, dropShadowColor: Color) {
        self.backgroundColor = backgroundColor
        self.accentColor = accentColor
        self.gradientColor = gradientColor
        self.textColor = textColor
        self.legendTextColor = legendTextColor
        self.dropShadowColor = dropShadowColor
    }
    
    public init(formSize: CGSize) {
        self.backgroundColor = Color.white
        self.accentColor = Colors.OrangeStart
        self.gradientColor = GradientColors.orange
        self.legendTextColor = Color.gray
        self.textColor = Color.black
        self.dropShadowColor = Color.gray
    }
    
}

#endif
