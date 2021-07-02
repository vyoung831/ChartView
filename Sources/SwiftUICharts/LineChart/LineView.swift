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
    
    @ObservedObject var data: LineChartData
    @Environment(\.colorScheme) var colorScheme: ColorScheme
    
    public var title: String?
    public var subtext: String?
    public var curvedLines: Bool = false
    public var fillGraph: Bool
    public var style: ChartStyle
    public var valueSpecifier: String
    
    // `graphInsets` provides insets for graph's ZStack to draw Line and Legend in.
    let graphInsets: EdgeInsets = EdgeInsets(top: 45, leading: 0, bottom: 45, trailing: 0)
    let titleAndSubtextHeight: CGFloat = 75
    let mainVStackSpacing: CGFloat = 5
    
    // Drag gesture and magnifier rectangle vars
    @State private var showLegend = false
    @State private var touchLocation: CGPoint = .zero
    @State private var dragged: Bool = false
    @State private var closestX: String = ""
    @State private var closestY: Double = 0
    @State private var hideHorizontalLines: Bool = false
    
    public init(data: LineChartData,
                title: String?,
                subtext: String?,
                fillGraph: Bool,
                style: ChartStyle,
                valueSpecifier: String = "%.1f") {
        self.data = data
        self.title = title
        self.subtext = subtext
        self.fillGraph = fillGraph
        self.style = style
        self.valueSpecifier = valueSpecifier
    }
    
    /**
     - parameter totalHeight: The total height available for LineView to be drawn in.
     - returns: The height available for the entire graph - `Line`, `Legend`, and `MagnifierRect` -  to be drawn in (Line and Legend are further inset).
     */
    private func getGraphHeight(_ totalHeight: CGFloat) -> CGFloat {
        return totalHeight - mainVStackSpacing - titleAndSubtextHeight
    }
    
    public var body: some View {
        
        GeometryReader { geometry in
            
            VStack(alignment: .leading, spacing: self.mainVStackSpacing) {
                
                VStack(alignment: .leading, spacing: 5) {
                    
                    if let titleString = self.title {
                        Text(titleString)
                            .bold()
                            .font(.title)
                            .foregroundColor(self.style.textColor)
                    }
                    
                    if let subtextString = self.subtext {
                        Text(subtextString)
                            .font(.callout)
                            .foregroundColor(self.style.accentColor)
                    }
                    
                }
                .frame(height: titleAndSubtextHeight)
                
                // ZStack containing graph (MagnifierRect, and further inset Line + Legend so that MagnifierRect appears larger than graph)
                ZStack(alignment: Alignment(horizontal: .leading, vertical: .bottom)) {
                    
                    Rectangle()
                        .foregroundColor(self.style.backgroundColor)
                    
                    Group {
                        
                        if self.showLegend {
                            Legend(hideHorizontalLines: self.$hideHorizontalLines, data: self.data)
                                .frame(width: geometry.size.width - (MagnifierRect.width/2))
                                .transition(.opacity)
                                .animation(Animation.easeOut(duration: 1))
                        }
                        
                        Line(data: self.data,
                             gradient: self.style.gradientColor,
                             curvedLines: self.curvedLines,
                             fillGraph: self.fillGraph,
                             touchLocation: self.$touchLocation,
                             showIndicator: self.$hideHorizontalLines,
                             minDataValue: .constant(nil),
                             maxDataValue: .constant(nil)
                        )
                        .frame(width: geometry.size.width - Legend.legendOffset - (MagnifierRect.width/2))
                        .offset(x: Legend.legendOffset)
                        .onAppear(){
                            self.showLegend = true
                        }
                        .onDisappear(){
                            self.showLegend = false
                        }
                        
                    }
                    .padding(self.graphInsets)
                    
                    MagnifierRect(valueSpecifier: self.valueSpecifier,
                                  x: self.$closestX,
                                  y: self.$closestY)
                        .opacity(self.dragged ? 1 : 0)
                        .offset(x: self.touchLocation.x + Legend.legendOffset - (MagnifierRect.width/2) )
                        .frame(height: getGraphHeight(geometry.size.height))
                    
                }
                .frame(width: geometry.size.width, height: getGraphHeight(geometry.size.height))
                .gesture(DragGesture()
                            .onChanged({ value in
                                self.dragged = true
                                self.hideHorizontalLines = true
                                
                                let offsettedX = value.location.x - Legend.legendOffset
                                self.touchLocation = CGPoint(x: offsettedX, y: value.location.y)
                                let closestPoint = Line.getClosestPointInData(data: self.data,
                                                                              touchLocation: self.touchLocation,
                                                                              totalSize: CGSize(width: geometry.size.width - Legend.legendOffset - MagnifierRect.width/2,
                                                                                                height: geometry.size.height - titleAndSubtextHeight - mainVStackSpacing))
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
