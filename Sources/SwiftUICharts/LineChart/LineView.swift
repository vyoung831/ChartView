//
//  LineView.swift
//  LineChart
//
//  Created by András Samu on 2019. 09. 02..
//  Copyright © 2019. András Samu. All rights reserved.
//

import SwiftUI

#if os(iOS) || os(watchOS)

public struct LineView: View {
    
    @ObservedObject var data: ChartData
    
    public var title: String?
    public var legend: String?
    public var style: ChartStyle
    public var darkModeStyle: ChartStyle
    public var valueSpecifier: String
    
    // Constants for the zStack that the Legend and Line are drawn in.
    let zStackHeight: CGFloat = 240
    let zStackOffset: CGFloat = 40
    
    @Environment(\.colorScheme) var colorScheme: ColorScheme
    @State private var showLegend = false
    @State private var touchLocation: CGPoint = .zero
    @State private var opacity: Double = 0
    
    @State private var currentX: String = ""
    @State private var currentY: Double = 0
    @State private var hideHorizontalLines: Bool = false
    
    public init(data: [(String,Double)],
                title: String? = nil,
                legend: String? = nil,
                style: ChartStyle = Styles.lineChartStyleOne,
                valueSpecifier: String? = "%.1f") {
        self.data = ChartData(values: data)
        self.title = title
        self.legend = legend
        self.style = style
        self.valueSpecifier = valueSpecifier!
        self.darkModeStyle = style.darkModeStyle != nil ? style.darkModeStyle! : Styles.lineViewDarkMode
    }
    
    public init(data: [Double],
                title: String? = nil,
                legend: String? = nil,
                style: ChartStyle = Styles.lineChartStyleOne,
                valueSpecifier: String? = "%.1f") {
        self.data = ChartData(points: data)
        self.title = title
        self.legend = legend
        self.style = style
        self.valueSpecifier = valueSpecifier!
        self.darkModeStyle = style.darkModeStyle != nil ? style.darkModeStyle! : Styles.lineViewDarkMode
    }
    
    public var body: some View {
        GeometryReader { geometry in
            VStack(alignment: .leading, spacing: 25) {
                
                VStack(alignment: .leading, spacing: 12) {
                    
                    if let titleString = self.title {
                        Text(titleString)
                            .font(.title)
                            .bold()
                            .foregroundColor(self.colorScheme == .dark ? self.darkModeStyle.textColor : self.style.textColor)
                    }
                    
                    if let legendString = self.legend {
                        Text(legendString)
                            .font(.callout)
                            .foregroundColor(self.colorScheme == .dark ? self.darkModeStyle.legendTextColor : self.style.legendTextColor)
                    }
                    
                }
                
                ZStack(alignment: Alignment(horizontal: .leading, vertical: .bottom)) {
                    
                    Rectangle()
                        .foregroundColor(.clear)
                    
                    if self.showLegend {
                        Legend(hideHorizontalLines: self.$hideHorizontalLines, data: self.data)
                            .transition(.opacity)
                            .animation(Animation.easeOut(duration: 1))
                    }
                    
                    Line(data: self.data,
                         gradient: self.style.gradientColor,
                         showBackground: false,
                         touchLocation: self.$touchLocation,
                         showIndicator: self.$hideHorizontalLines,
                         minDataValue: .constant(nil),
                         maxDataValue: .constant(nil)
                    )
                    .frame(width: geometry.size.width - Legend.legendOffset - (MagnifierRect.width/2),
                           height: zStackHeight)
                    .offset(x: Legend.legendOffset)
                    .onAppear(){
                        self.showLegend = true
                    }
                    .onDisappear(){
                        self.showLegend = false
                    }
                    
                    MagnifierRect(valueSpecifier: self.valueSpecifier,
                                  x: self.$currentX,
                                  y: self.$currentY)
                        .opacity(self.opacity)
                        .offset(x: self.touchLocation.x + Legend.legendOffset - (MagnifierRect.width/2) )
                        .frame(width: MagnifierRect.width, height: zStackHeight)
                }
                .frame(width: geometry.size.width, height: zStackHeight)
                .gesture(DragGesture()
                            .onChanged({ value in
                                self.opacity = 1
                                self.hideHorizontalLines = true
                                
                                let offsettedX = value.location.x - Legend.legendOffset
                                
                                self.touchLocation = CGPoint(x: offsettedX, y: value.location.y)
                                let closestPoint =
                                    Line.getClosestPointInData(data: self.data,
                                                               touchLocation: self.touchLocation,
                                                               totalSize: CGSize(width: geometry.size.width - Legend.legendOffset - MagnifierRect.width/2,
                                                                                 height: zStackHeight))
                                self.currentX = closestPoint.x
                                self.currentY = closestPoint.y
                                
                            })
                            .onEnded({ value in
                                self.opacity = 0
                                self.hideHorizontalLines = false
                            })
                )
            }
        }
    }
    
}

#endif
