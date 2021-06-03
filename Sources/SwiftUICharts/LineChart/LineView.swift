//
//  LineView.swift
//  LineChart
//
//  Created by András Samu on 2019. 09. 02..
//  Copyright © 2019. András Samu. All rights reserved.
//

import SwiftUI

public struct LineView: View {
    
    @ObservedObject var data: ChartData
    
    public var title: String?
    public var legend: String?
    public var style: ChartStyle
    public var darkModeStyle: ChartStyle
    public var valueSpecifier: String
    
    let offsetForLegend: CGFloat = 40
    
    @Environment(\.colorScheme) var colorScheme: ColorScheme
    @State private var showLegend = false
    @State private var dragLocation: CGPoint = .zero
    @State private var indicatorLocation: CGPoint = .zero
    @State private var closestPoint: CGPoint = .zero
    @State private var opacity: Double = 0
    @State private var currentDataNumber: Double = 0
    @State private var hideHorizontalLines: Bool = false
    
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
    
    func getClosestDataPoint(toPoint: CGPoint, width:CGFloat, height: CGFloat) -> CGPoint {
        let points = self.data.onlyPoints()
        let stepWidth: CGFloat = width / CGFloat(points.count-1)
        let stepHeight: CGFloat = height / CGFloat(points.max()! + points.min()!)
        
        let index:Int = Int(floor((toPoint.x-15)/stepWidth))
        if (index >= 0 && index < points.count){
            self.currentDataNumber = points[index]
            return CGPoint(x: CGFloat(index)*stepWidth, y: CGFloat(points[index])*stepHeight)
        }
        return .zero
    }
    
    public var body: some View {
        GeometryReader{ geometry in
            VStack(alignment: .leading, spacing: 8) {
                
                Group{
                    
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
                .offset(x: 0, y: 20)
                
                ZStack{
                    GeometryReader{ reader in
                        
                        Rectangle()
                            .foregroundColor(.clear)
                        
                        if self.showLegend {
                            Legend(frame: .constant(reader.frame(in: .local)),
                                   hideHorizontalLines: self.$hideHorizontalLines,
                                   data: self.data)
                                .transition(.opacity)
                                .animation(Animation.easeOut(duration: 1))
                        }
                        
                        Line(data: self.data,
                             gradient: self.style.gradientColor,
                             showBackground: false,
                             frame: .constant(CGRect(x: 0, y: 0, width: reader.frame(in: .local).width - offsetForLegend,
                                                     height: reader.frame(in: .local).height)),
                             touchLocation: self.$indicatorLocation,
                             showIndicator: self.$hideHorizontalLines,
                             minDataValue: .constant(nil),
                             maxDataValue: .constant(nil)
                        )
                        .offset(x: offsetForLegend, y: 0)
                        .onAppear(){
                            self.showLegend = true
                        }
                        .onDisappear(){
                            self.showLegend = false
                        }
                        
                    }
                    .frame(width: geometry.frame(in: .local).size.width, height: 240)
                    .offset(x: 0, y: 40 )
                    
                    MagnifierRect(currentNumber: self.$currentDataNumber, valueSpecifier: self.valueSpecifier)
                        .opacity(self.opacity)
                        .offset(x: self.dragLocation.x - geometry.frame(in: .local).size.width/2, y: 36)
                }
                .frame(width: geometry.frame(in: .local).size.width, height: 240)
                .gesture(DragGesture()
                            .onChanged({ value in
                                self.dragLocation = value.location
                                self.indicatorLocation = CGPoint(x: max(value.location.x-30,0), y: 32)
                                self.opacity = 1
                                self.closestPoint = self.getClosestDataPoint(toPoint: value.location, width: geometry.frame(in: .local).size.width-30, height: 240)
                                self.hideHorizontalLines = true
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
