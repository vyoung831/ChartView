//
//  Helpers.swift
//
//
//  Created by András Samu on 2019. 07. 19..
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

// MARK: - ChartData

public class ChartData: ObservableObject {
    
    @Published var points: [(x: String, y: Double)]
    var valuesGiven: Bool = false
    
    public init<N: BinaryFloatingPoint>(points: [N]) {
        self.points = points.map{("", Double($0))}
    }
    
    public init<N: BinaryInteger>(values: [(String, N)]){
        self.points = values.map{($0.0, Double($0.1))}
        self.valuesGiven = true
    }
    
    public init<N: BinaryFloatingPoint>(values: [(String, N)]){
        self.points = values.map{($0.0, Double($0.1))}
        self.valuesGiven = true
    }
    
    public init<N: BinaryInteger>(numberValues: [(N, N)]){
        self.points = numberValues.map{(String($0.0), Double($0.1))}
        self.valuesGiven = true
    }
    
    public init<N: BinaryFloatingPoint & LosslessStringConvertible>(numberValues: [(N, N)]){
        self.points = numberValues.map{(String($0.0), Double($0.1))}
        self.valuesGiven = true
    }
    
    public func onlyPoints() -> [Double] {
        return self.points.map{ $0.1 }
    }
    
}

// MARK: - ChartData subclasses for line charts

public class LineChartData: ChartData {
    
    // Used for deciding what a plotted point should be colored.
    var getColor: (Double) -> Color
    
    public init<N: BinaryFloatingPoint>(points: [N], getColor: @escaping (Double) -> Color) {
        self.getColor = getColor
        super.init(points: points)
    }
    
    public init<N: BinaryInteger>(values: [(String, N)], getColor: @escaping (Double) -> Color) {
        self.getColor = getColor
        super.init(values: values)
    }
    
    public init<N: BinaryFloatingPoint>(values: [(String, N)], getColor: @escaping (Double) -> Color) {
        self.getColor = getColor
        super.init(values: values)
    }
    
    public init<N: BinaryInteger>(numberValues: [(N, N)], getColor: @escaping (Double) -> Color) {
        self.getColor = getColor
        super.init(numberValues: numberValues)
    }
    
    public init<N: BinaryFloatingPoint & LosslessStringConvertible>(numberValues: [(N, N)], getColor: @escaping (Double) -> Color) {
        self.getColor = getColor
        super.init(numberValues: numberValues)
    }
    
}

public class MultiLineChartViewData: LineChartData {
    
    var gradient: GradientColor
    
    public init<N: BinaryFloatingPoint>(points: [N], gradient: GradientColor, getColor: @escaping (Double) -> Color) {
        self.gradient = gradient
        super.init(points: points, getColor: getColor)
    }
    
    public func getGradient() -> GradientColor {
        return self.gradient
    }
    
}

class HapticFeedback {
    #if os(watchOS)
    //watchOS implementation
    static func playSelection() -> Void {
        WKInterfaceDevice.current().play(.click)
    }
    #else
    //iOS implementation
    let selectionFeedbackGenerator = UISelectionFeedbackGenerator()
    static func playSelection() -> Void {
        UISelectionFeedbackGenerator().selectionChanged()
    }
    #endif
}

#endif
