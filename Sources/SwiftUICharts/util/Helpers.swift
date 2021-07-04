//
//  Helpers.swift
//
//
//  Created by András Samu on 2019. 07. 19..
//

import Foundation
import SwiftUI

#if os(iOS) || os(watchOS)

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
    
    /*
     - getColor: Used for deciding what a plotted point should be colored.
     - minY: minimum y-value to extend graph to show
     - maxY: maximum y-value to extend graph to show
     */
    var getColor: (Double) -> Color
    private var _minY: Double
    private var _maxY: Double
    
    var minY: Double {
        get {
            if let pointsMin = self.onlyPoints().min() {
                return self._minY < pointsMin ? _minY : pointsMin
            } else {
                return _minY
            }
        }
    }
    
    var maxY: Double {
        get {
            if let pointsMax = self.onlyPoints().max() {
                return self._maxY > pointsMax ? _maxY : pointsMax
            } else {
                return _maxY
            }
        }
    }
    
    public init<N: BinaryFloatingPoint>(points: [N], minY: Double, maxY: Double, getColor: @escaping (Double) -> Color) {
        self._minY = minY
        self._maxY = maxY
        self.getColor = getColor
        super.init(points: points)
    }
    
    public init<N: BinaryInteger>(values: [(String, N)], minY: Double, maxY: Double, getColor: @escaping (Double) -> Color) {
        self._minY = minY
        self._maxY = maxY
        self.getColor = getColor
        super.init(values: values)
    }
    
    public init<N: BinaryFloatingPoint>(values: [(String, N)], minY: Double, maxY: Double, getColor: @escaping (Double) -> Color) {
        self._minY = minY
        self._maxY = maxY
        self.getColor = getColor
        super.init(values: values)
    }
    
    public init<N: BinaryInteger>(numberValues: [(N, N)], minY: Double, maxY: Double, getColor: @escaping (Double) -> Color) {
        self._minY = minY
        self._maxY = maxY
        self.getColor = getColor
        super.init(numberValues: numberValues)
    }
    
    public init<N: BinaryFloatingPoint & LosslessStringConvertible>(numberValues: [(N, N)], minY: Double, maxY: Double, getColor: @escaping (Double) -> Color) {
        self._minY = minY
        self._maxY = maxY
        self.getColor = getColor
        super.init(numberValues: numberValues)
    }
    
}

public class MultiLineChartViewData: LineChartData {
    
    var gradient: GradientColor
    
    public init<N: BinaryFloatingPoint>(points: [N], minY: Double, maxY: Double, gradient: GradientColor, getColor: @escaping (Double) -> Color) {
        self.gradient = gradient
        super.init(points: points, minY: minY, maxY: maxY, getColor: getColor)
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
