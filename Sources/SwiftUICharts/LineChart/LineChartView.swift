//
//  LineCard.swift
//  LineChart
//
//  Created by András Samu on 2019. 08. 31..
//  Copyright © 2019. András Samu. All rights reserved.
//

import SwiftUI

#if os(iOS) || os(watchOS)

public struct LineChartView: View {
    
    @Environment(\.colorScheme) var colorScheme: ColorScheme
    @ObservedObject var data: LineChartData
    public var title: String
    public var legend: String?
    public var curvedLines: Bool
    public var fillGraph: Bool
    public var style: ChartStyle
    
    public var formSize: CGSize
    public var dropShadow: Bool
    public var valueSpecifier: String
    
    @State private var touchLocation: CGPoint = .zero
    @State private var showIndicatorDot: Bool = false
    @State private var currentValue: Double = 2 {
        didSet{
            if (oldValue != self.currentValue && showIndicatorDot) {
                HapticFeedback.playSelection()
            }
            
        }
    }
    var frame = CGSize(width: 180, height: 120)
    private var rateValue: Int?
    
    public init(data: LineChartData,
                title: String,
                legend: String? = nil,
                curvedLines: Bool,
                fillGraph: Bool,
                style: ChartStyle = Styles.lineChartStyleOne,
                form: CGSize? = ChartForm.medium,
                rateValue: Int? = 14,
                dropShadow: Bool? = true,
                valueSpecifier: String? = "%.1f") {
        self.data = data
        self.title = title
        self.legend = legend
        self.style = style
        self.curvedLines = curvedLines
        self.fillGraph = fillGraph
        self.formSize = form!
        frame = CGSize(width: self.formSize.width, height: self.formSize.height/2)
        self.dropShadow = dropShadow!
        self.valueSpecifier = valueSpecifier!
        self.rateValue = rateValue
    }
    
    public var body: some View {
        ZStack(alignment: .center){
            RoundedRectangle(cornerRadius: 20)
                .fill(self.style.backgroundColor)
                .frame(width: frame.width, height: 240, alignment: .center)
                .shadow(color: self.style.dropShadowColor, radius: self.dropShadow ? 8 : 0)
            VStack(alignment: .leading){
                if(!self.showIndicatorDot){
                    VStack(alignment: .leading, spacing: 8){
                        Text(self.title)
                            .font(.title)
                            .bold()
                            .foregroundColor(self.style.textColor)
                        if (self.legend != nil){
                            Text(self.legend!)
                                .font(.callout)
                                .foregroundColor(self.style.accentColor)
                        }
                        HStack {
                            
                            if (self.rateValue ?? 0 != 0)
                            {
                                if (self.rateValue ?? 0 >= 0){
                                    Image(systemName: "arrow.up")
                                }else{
                                    Image(systemName: "arrow.down")
                                }
                                Text("\(self.rateValue!)%")
                            }
                        }
                    }
                    .transition(.opacity)
                    .animation(.easeIn(duration: 0.1))
                    .padding([.leading, .top])
                }else{
                    HStack{
                        Spacer()
                        Text("\(self.currentValue, specifier: self.valueSpecifier)")
                            .font(.system(size: 41, weight: .bold, design: .default))
                            .offset(x: 0, y: 30)
                        Spacer()
                    }
                    .transition(.scale)
                }
                Spacer()
                GeometryReader{ geometry in
                    Line(data: self.data,
                         gradient: self.style.gradientColor,
                         curvedLines: self.curvedLines,
                         fillGraph: self.fillGraph,
                         touchLocation: self.$touchLocation,
                         showIndicator: self.$showIndicatorDot
                    )
                }
                .frame(width: frame.width, height: frame.height + 30)
                .clipShape(RoundedRectangle(cornerRadius: 20))
                .offset(x: 0, y: 0)
            }.frame(width: self.formSize.width, height: self.formSize.height)
        }
        .gesture(DragGesture()
                    .onChanged({ value in
                        self.touchLocation = value.location
                        self.showIndicatorDot = true
                        self.getClosestDataPoint(toPoint: value.location, width:self.frame.width, height: self.frame.height)
                    })
                    .onEnded({ value in
                        self.showIndicatorDot = false
                    })
        )
    }
    
    @discardableResult func getClosestDataPoint(toPoint: CGPoint, width:CGFloat, height: CGFloat) -> CGPoint {
        let points = self.data.onlyPoints()
        let stepWidth: CGFloat = width / CGFloat(points.count-1)
        let stepHeight: CGFloat = height / CGFloat(points.max()! + points.min()!)
        
        let index:Int = Int(round((toPoint.x)/stepWidth))
        if (index >= 0 && index < points.count){
            self.currentValue = points[index]
            return CGPoint(x: CGFloat(index)*stepWidth, y: CGFloat(points[index])*stepHeight)
        }
        return .zero
    }
}

struct WidgetView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            LineChartView(data: LineChartData(points: [8,23,54,32,12,37,7,23,43],
                                              minY: 0,
                                              maxY: 75,
                                              getColor: { value in
                                                if value > 30 {
                                                    return .green
                                                } else {
                                                    return .red
                                                }
                                              }),
                          title: "Line chart",
                          legend: "Basic",
                          curvedLines: false,
                          fillGraph: false)
                .environment(\.colorScheme, .light)
            
            LineChartView(data: LineChartData(points: [282.502, 284.495, 283.51, 285.019, 285.197, 286.118, 288.737, 288.455, 289.391, 287.691, 285.878, 286.46, 286.252, 284.652, 284.129, 284.188],
                                              minY: 280,
                                              maxY: 300,
                                              getColor: { value in
                                                if value > 285.5 {
                                                    return .green
                                                } else {
                                                    return .red
                                                }
                                              }),
                          title: "Line chart",
                          legend: "Basic",
                          curvedLines: true,
                          fillGraph: true)
                .environment(\.colorScheme, .light)
        }
    }
}

#endif
