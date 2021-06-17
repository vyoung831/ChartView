//
//  UI-Constants.swift
//  
//
//  Created by Vincent Young on 6/15/21.
//

import Foundation
import SwiftUI

public struct Styles {
    public static let lineChartStyleOne = ChartStyle(
        backgroundColor: Color.white,
        accentColor: Colors.OrangeStart,
        secondGradientColor: Colors.OrangeEnd,
        textColor: Color.black,
        legendTextColor: Color.gray,
        dropShadowColor: Color.gray)
    
    public static let barChartStyleOrangeLight = ChartStyle(
        backgroundColor: Color.white,
        accentColor: Colors.OrangeStart,
        secondGradientColor: Colors.OrangeEnd,
        textColor: Color.black,
        legendTextColor: Color.gray,
        dropShadowColor: Color.gray)
    
    public static let barChartStyleOrangeDark = ChartStyle(
        backgroundColor: Color.black,
        accentColor: Colors.OrangeStart,
        secondGradientColor: Colors.OrangeEnd,
        textColor: Color.white,
        legendTextColor: Color.gray,
        dropShadowColor: Color.gray)
    
    public static let barChartStyleNeonBlueLight = ChartStyle(
        backgroundColor: Color.white,
        accentColor: Colors.GradientNeonBlue,
        secondGradientColor: Colors.GradientPurple,
        textColor: Color.black,
        legendTextColor: Color.gray,
        dropShadowColor: Color.gray)
    
    public static let barChartStyleNeonBlueDark = ChartStyle(
        backgroundColor: Color.black,
        accentColor: Colors.GradientNeonBlue,
        secondGradientColor: Colors.GradientPurple,
        textColor: Color.white,
        legendTextColor: Color.gray,
        dropShadowColor: Color.gray)
    
    public static let barChartMidnightGreenDark = ChartStyle(
        backgroundColor: Color(hexString: "#36534D"), //3B5147, 313D34
        accentColor: Color(hexString: "#FFD603"),
        secondGradientColor: Color(hexString: "#FFCA04"),
        textColor: Color.white,
        legendTextColor: Color(hexString: "#D2E5E1"),
        dropShadowColor: Color.gray)
    
    public static let barChartMidnightGreenLight = ChartStyle(
        backgroundColor: Color.white,
        accentColor: Color(hexString: "#84A094"), //84A094 , 698378
        secondGradientColor: Color(hexString: "#50675D"),
        textColor: Color.black,
        legendTextColor:Color.gray,
        dropShadowColor: Color.gray)
    
    public static let pieChartStyleOne = ChartStyle(
        backgroundColor: Color.white,
        accentColor: Colors.OrangeEnd,
        secondGradientColor: Colors.OrangeStart,
        textColor: Color.black,
        legendTextColor: Color.gray,
        dropShadowColor: Color.gray)
    
    public static let lineViewDarkMode = ChartStyle(
        backgroundColor: Color.black,
        accentColor: Colors.OrangeStart,
        secondGradientColor: Colors.OrangeEnd,
        textColor: Color.white,
        legendTextColor: Color.white,
        dropShadowColor: Color.gray)
}

public struct Colors {
    public static let color1:Color = Color(hexString: "#E2FAE7")
    public static let color1Accent:Color = Color(hexString: "#72BF82")
    public static let color2:Color = Color(hexString: "#EEF1FF")
    public static let color2Accent:Color = Color(hexString: "#4266E8")
    public static let color3:Color = Color(hexString: "#FCECEA")
    public static let color3Accent:Color = Color(hexString: "#E1614C")
    public static let OrangeEnd:Color = Color(hexString: "#FF782C")
    public static let OrangeStart:Color = Color(hexString: "#EC2301")
    public static let LegendText:Color = Color(hexString: "#A7A6A8")
    public static let LegendColor:Color = Color(hexString: "#E8E7EA")
    public static let LegendDarkColor:Color = Color(hexString: "#545454")
    public static let IndicatorKnob:Color = Color(hexString: "#FF57A6")
    public static let GradientUpperBlue:Color = Color(hexString: "#C2E8FF")
    public static let GradinetUpperBlue1:Color = Color(hexString: "#A8E1FF")
    public static let GradientPurple:Color = Color(hexString: "#7B75FF")
    public static let GradientNeonBlue:Color = Color(hexString: "#6FEAFF")
    public static let GradientLowerBlue:Color = Color(hexString: "#F1F9FF")
    public static let DarkPurple:Color = Color(hexString: "#1B205E")
    public static let BorderBlue:Color = Color(hexString: "#4EBCFF")
}

public struct GradientColors {
    public static let orange = GradientColor(start: Colors.OrangeStart, end: Colors.OrangeEnd)
    public static let blue = GradientColor(start: Colors.GradientPurple, end: Colors.GradientNeonBlue)
    public static let green = GradientColor(start: Color(hexString: "0BCDF7"), end: Color(hexString: "A2FEAE"))
    public static let blu = GradientColor(start: Color(hexString: "0591FF"), end: Color(hexString: "29D9FE"))
    public static let bluPurpl = GradientColor(start: Color(hexString: "4ABBFB"), end: Color(hexString: "8C00FF"))
    public static let purple = GradientColor(start: Color(hexString: "741DF4"), end: Color(hexString: "C501B0"))
    public static let prplPink = GradientColor(start: Color(hexString: "BC05AF"), end: Color(hexString: "FF1378"))
    public static let prplNeon = GradientColor(start: Color(hexString: "FE019A"), end: Color(hexString: "FE0BF4"))
    public static let orngPink = GradientColor(start: Color(hexString: "FF8E2D"), end: Color(hexString: "FF4E7A"))
}

public struct ChartForm {
    #if os(watchOS)
    public static let small = CGSize(width:120, height:90)
    public static let medium = CGSize(width:120, height:160)
    public static let large = CGSize(width:180, height:90)
    public static let extraLarge = CGSize(width:180, height:90)
    public static let detail = CGSize(width:180, height:160)
    #else
    public static let small = CGSize(width:180, height:120)
    public static let medium = CGSize(width:180, height:240)
    public static let large = CGSize(width:360, height:120)
    public static let extraLarge = CGSize(width:360, height:240)
    public static let detail = CGSize(width:180, height:120)
    #endif
}

public class TestData{
    static public var data:ChartData = ChartData(points: [37,72,51,22,39,47,66,85,50])
    static public var values:ChartData = ChartData(values: [("2017 Q3",220),
                                                            ("2017 Q4",1550),
                                                            ("2018 Q1",8180),
                                                            ("2018 Q2",18440),
                                                            ("2018 Q3",55840),
                                                            ("2018 Q4",63150), ("2019 Q1",50900), ("2019 Q2",77550), ("2019 Q3",79600), ("2019 Q4",92550)])
    
}
