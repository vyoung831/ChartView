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
    @Environment(\.colorScheme) var colorScheme: ColorScheme
    
    public var title: String?
    public var legend: String?
    public var style: ChartStyle
    public var valueSpecifier: String
    
    // Constants for the zStack that the Legend and Line are drawn in.
    let zStackHeight: CGFloat = 240
    
    // Drag gesture and magnifier rectangle vars
    @State private var showLegend = false
    @State private var touchLocation: CGPoint = .zero
    @State private var dragged: Bool = false
    @State private var closestX: String = ""
    @State private var closestY: Double = 0
    @State private var hideHorizontalLines: Bool = false
    
    public init(data: [(String,Double)],
                title: String?,
                legend: String?,
                style: ChartStyle,
                valueSpecifier: String = "%.1f") {
        self.data = ChartData(values: data)
        self.title = title
        self.legend = legend
        self.style = style
        self.valueSpecifier = valueSpecifier
    }
    
    public var body: some View {
        GeometryReader { geometry in
            VStack(alignment: .leading, spacing: 25) {
                
                VStack(alignment: .leading, spacing: 12) {
                    
                    if let titleString = self.title {
                        Text(titleString)
                            .font(.title)
                            .bold()
                            .foregroundColor(self.style.textColor)
                    }
                    
                    if let legendString = self.legend {
                        Text(legendString)
                            .font(.callout)
                            .foregroundColor(self.style.legendTextColor)
                    }
                    
                }
                
                ZStack(alignment: Alignment(horizontal: .leading, vertical: .bottom)) {
                    
                    Rectangle()
                        .foregroundColor(self.style.backgroundColor)
                    
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
                                  x: self.$closestX,
                                  y: self.$closestY)
                        .opacity(self.dragged ? 1 : 0)
                        .offset(x: self.touchLocation.x + Legend.legendOffset - (MagnifierRect.width/2) )
                        .frame(width: MagnifierRect.width, height: zStackHeight)
                }
                .frame(width: geometry.size.width, height: zStackHeight)
                .gesture(DragGesture()
                            .onChanged({ value in
                                self.dragged = true
                                self.hideHorizontalLines = true
                                
                                let offsettedX = value.location.x - Legend.legendOffset
                                self.touchLocation = CGPoint(x: offsettedX, y: value.location.y)
                                let closestPoint = Line.getClosestPointInData(data: self.data,
                                                                              touchLocation: self.touchLocation,
                                                                              totalSize: CGSize(width: geometry.size.width - Legend.legendOffset - MagnifierRect.width/2,
                                                                                                height: zStackHeight))
                                self.closestX = closestPoint.x
                                self.closestY = closestPoint.y
                            })
                            .onEnded({ value in
                                self.dragged = false
                                self.hideHorizontalLines = false
                            })
                )
            }
        }
    }
    
}

#endif
